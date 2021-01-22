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

/// TODO use GetOpt
def main(_args: Array[String]): Int32 & Impure =  
    use NewLiftingItems/Base/ReportMonad.{runReportMonad};
    use NewLiftingItems/MakeReport.{mainHelper};
    let dbpath          = System/FilePath.new("G:/work/assets/lifting-equipment-2021/lifting_db.sqlite");
    let uxlTemplate     = System/FilePath.new("G:/work/assets/lifting-equipment-reports/MMOP_uXL.xlsx");
    let worklistPaths =     
        { worklist          = System/FilePath.new("G:/work/assets/lifting-equipment-2021/LINTON MEADOWS MOD SPS.xlsx")
        , attributesExport  = System/FilePath.new("G:/work/assets/lifting-equipment-2021/linton-attribs-export.xlsx")
        , memosExport       = System/FilePath.new("G:/work/assets/lifting-equipment-2021/linton-memos-export.xlsx")
        };
    Console.printLine("Running...");
    match runReportMonad(mainHelper(worklistPaths, uxlTemplate), dbpath) {
        case Ok(ans) => {let (x,y) = ans; Console.printLine("Good - see ${x} ${y}"); 0}
        case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
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
