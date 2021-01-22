/*
 * Copyright 2021 Stephen Tetley
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
 
use GetOpt.{ArgDescr, OptionDescr};
use GetOpt.ArgDescr.{NoArg, ReqArg, OptArg};


/// --dbpath=%dbpath% --uxltemplate=%uxltemplate% --worklist=%worklist% --attribs=%attribs% --memos=%memos%"

type alias InputPaths = 
    { dbpath: System.FilePath
    , uxltemplate: System.FilePath
    , worklist: System.FilePath
    , attribs: System.FilePath
    , memos: System.FilePath    
    }

def defaultInputPaths(): InputPaths = 
    { dbpath = System/FilePath.new("")
    , uxltemplate = System/FilePath.new("")
    , worklist = System/FilePath.new("")
    , attribs = System/FilePath.new("")
    , memos = System/FilePath.new("")
    }    

type alias UpdateOptions = InputPaths -> InputPaths    


def makeCmdLineOptions(): List[OptionDescr[UpdateOptions]] = 
       {optionIds = Nil,    optionNames = "dbpath" :: Nil,          argDescriptor = ReqArg(setDbpath, "FILE"),      explanation = "path to SQLite database"}
    :: {optionIds = Nil,    optionNames = "uxltemplate" :: Nil,     argDescriptor = ReqArg(setUxltemplate, "FILE"), explanation = "path to Excel UXL template"}
    :: {optionIds = Nil,    optionNames = "worklist" :: Nil,        argDescriptor = ReqArg(setWorklist, "FILE"),    explanation = "path to input worklist"}
    :: {optionIds = Nil,    optionNames = "attribs" :: Nil,         argDescriptor = ReqArg(setAttribs, "FILE"),    explanation = "path to AI2 attributes export"}
    :: {optionIds = Nil,    optionNames = "memos" :: Nil,           argDescriptor = ReqArg(setMemos, "FILE"),     explanation = "path to AI2 memo lines export" }
    :: Nil

def setDbpath(s: String): Option[UpdateOptions] = Some(opts -> {dbpath = System/FilePath.new(s) | opts})
def setUxltemplate(s: String): Option[UpdateOptions] = Some(opts -> {uxltemplate = System/FilePath.new(s) | opts})
def setWorklist(s: String): Option[UpdateOptions] = Some(opts -> {worklist = System/FilePath.new(s) | opts})
def setAttribs(s: String): Option[UpdateOptions] = Some(opts -> {attribs = System/FilePath.new(s) | opts})
def setMemos(s: String): Option[UpdateOptions] = Some(opts -> {memos = System/FilePath.new(s) | opts})


def main(args: Array[String]): Int32 & Impure =  
    use GetOpt.ArgOrder.{Permute};
    use GetOpt.{getOpt, usageInfo};
    use NewLiftingItems/Base/ReportMonad.{runReportMonad};
    use NewLiftingItems/MakeReport.{mainHelper};
    Console.printLine("Running...");
    let options1 = makeCmdLineOptions();
    let header = "Usage: <make-report> [OPTION...]";
    let args2 = GetOpt.preprocess({quoteOpen = "'", quoteClose = "'", stripQuoteMarks = true}, args);
    match getOpt(Permute, options1, args2) {
        case Failure(errs)  => {Console.printLine("Errors: ${errs}");  Console.printLine(usageInfo(header, options1)); 1}
        case Success(updates) => {
            let r1 = List.foldLeft((ac, f) -> f(ac), defaultInputPaths(), updates.options);
            let worklistPaths =     
                { worklist          = r1.worklist
                , attributesExport  = r1.attribs
                , memosExport       = r1.memos
                };
            match runReportMonad(mainHelper(worklistPaths, r1.uxltemplate), r1.dbpath) {
                case Ok(ans) => {let (x,y) = ans; Console.printLine("Good - see ${x} ${y}"); 0}
                case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
            }
        }
    }

namespace NewLiftingItems/MakeReport {


    use BasicDb.DbMonad;
    use BasicDb.PreparedStatement;
    use BasicDb.RowEvaluator;

    use AssetLib/S4Lite/CreateNew/Datatypes.{S4Equipment};
    use AssetLib/S4Lite/CreateNew/EquipmentBuilder.{TableNames};
    
    use NewLiftingItems/Base/Datatypes.{LiftingEquipment};
    use NewLiftingItems/Base.ReportMonad;
    use NewLiftingItems/MakeReport/ChildNew.{ChildNewPreparedStatements}; 

    type alias WorklistPaths = 
        { worklist: System.FilePath
        , attributesExport: System.FilePath
        , memosExport: System.FilePath
        }

    pub def mainHelper(worklistPaths: WorklistPaths, uxlTemplate: System.FilePath): ReportMonad[(System.FilePath, System.FilePath)] = 
        use NewLiftingItems/Base/ReportMonad.{flatMap, return, liftDbMonad, whenTrue, liftAction};        
        let manualOutput    = makeOutputName(worklistPaths.worklist, "_new_kids.xlsx");
        let uxlOutput       = makeOutputName(worklistPaths.worklist, "_new_kids_uxl.xlsx");
        let* _              = liftAction(_ -> Console.printLine("mainHelper.1"));
        let* _              = liftDbMonad(_ -> setupSpecificTables(worklistPaths));
        let* _              = liftAction(_ -> Console.printLine("makeReport..."));
        let* _              = makeReport("Lifting Update", uxlTemplate, manualOutput, uxlOutput);
        return((manualOutput, uxlOutput))
        

    def makeOutputName(path: System.FilePath, newSuffix: String): System.FilePath = 
        let s = Option.getWithDefault(System/FilePath.getBaseName(path), "");
        let s1 = s + newSuffix;
        System/FilePath.replaceFileName(path, s1)



    def setupSpecificTables(worklistPaths: WorklistPaths):  DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, liftAction};
        let* _  = NewLiftingItems/SetupDb/Worklist/Worklist.storeWorklist("wl_worklist", worklistPaths.worklist);
        let* _  = NewLiftingItems/SetupDb/Worklist/CommonNames.storeCommonNames("wl_common_names", worklistPaths.attributesExport);
        let* _  = NewLiftingItems/SetupDb/Worklist/AibAttributes.storeAibAttributes("wl_attributes", worklistPaths.attributesExport);
        let* _  = NewLiftingItems/SetupDb/Worklist/MemoLines.storeMemoLines("wl_memo_lines", worklistPaths.memosExport);
        return()

    def makeReport(description: String, uxlTemplate: System.FilePath, manualOut: System.FilePath, uxlOut: System.FilePath): ReportMonad[Unit] = 
        use AssetLib/S4Lite/CreateNew/EmitUxl.{outputUxl};
        use NewLiftingItems/Base/ReportMonad.{return, flatMap, liftActionResult, liftAction, liftDbMonad, mapM};
        use NewLiftingItems/Base/LiftingEquipmentToS4Lite.{translateLiftingEquipment};
        use NewLiftingItems/MakeReport/ChildNew.{cachePreparedStatements => childNewPreparedStatements};
        use NewLiftingItems/MakeReport/ManualOutput.{writeManualReport};
        let* childPsCache   = liftDbMonad(_ -> childNewPreparedStatements());
        let* xs             = liftDbMonad(_ -> getWorklist());
        let news            = List.filter(x -> x.change == "Child New", xs);
        let* newEquis       = mapM(x -> buildNew(childPsCache, x.reference), news);
        let* _              = writeManualReport(newEquis, manualOut);
        let* newEquis2      = mapM(translateLiftingEquipment, newEquis);    
        let* _              = liftActionResult(_ -> outputUxl(description, Nil, newEquis2, uxlTemplate, uxlOut));
        return()



    pub def buildNew(pstmts: ChildNewPreparedStatements, reference: String): ReportMonad[LiftingEquipment] = 
        use NewLiftingItems/Base/ReportMonad.{return, flatMap, genEquiId, liftDbMonad}; 
        use NewLiftingItems/MakeReport/ChildNew.{childNew};
        let* equiId     = genEquiId();
        let* ans        = liftDbMonad(_ -> childNew(pstmts, reference, equiId));
        return(ans)    




    /// Read Worklist

    type alias WorkItem = 
        { reference: String
        , change: String
        }

    pub def getWorklist(): DbMonad[List[WorkItem]] = 
        use BasicDb/DbMonad.{flatMap, return, psExecuteQuery, allRows, rsClose};
        let* pstmt  = prepareWorklistQuery();
        let* rs     = psExecuteQuery(pstmt, BasicDb/PreparedStatementSetter.return());
        let* x1     = allRows(rs, evalWorkItem());
        let* _      = rsClose(rs);
        return(x1)

    pub def prepareWorklistQuery(): DbMonad[PreparedStatement] = 
        let sql = String.unlines(
                "SELECT"
                :: "    t.reference,"
                :: "    t.change"
                :: "FROM" 
                :: "    wl_worklist t"
                :: "ORDER BY"
                :: "    t.orderkey"
                :: Nil
            );
        BasicDb/DbMonad.prepareStatement(sql)


    def evalWorkItem(): RowEvaluator[WorkItem] = 
        use BasicDb/RowEvaluator.{flatMap, return, getStringNamed};
        use BasicDb/RowEvaluator.{<&>, <*>};
        use String.{trim};
        ((x1, x2) ->
                { reference = x1
                , change    = x2
                })
            <&> getStringNamed("reference")
            <*> getStringNamed("change")

}
