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

namespace ValveReport/Main {

    use GetOpt.{ArgDescr, OptionDescr};
    use GetOpt.ArgDescr.{NoArg, ReqArg, OptArg};

    use AssetLib/AibFacts/Relations.{AibFactGroup, AibStringValue, AibIntValue, AibFloatValue};
    use AssetLib/GenS4.XlsxSource;
    use AssetLib/AibFacts/HierarchyFacts.{RootNode, AibFloc, AibEquipment};
    use AssetLib/GenS4/UxlRelations.{EquiSortOrder};
    use AssetLib/GenS4/MemoLines.{MemoText};
    use ValveReport/Relations.{ValveWorkItem, ValveAttribs};



    type alias ProgramArguments = 
        { uxlTemplate: System.FilePath
        , aibHierarchyExport: XlsxSource
        , aibValveExport: XlsxSource
        , aibAgaspExport: XlsxSource
        , aibMemosExport: XlsxSource
        , worklist: XlsxSource
        , solutionId: String
        , changeRequestName: String
        , outpath: System.FilePath
        }

    type alias UpdateProgramArguments = ProgramArguments -> ProgramArguments

    def defaultProgramArguments(): ProgramArguments = 
        { uxlTemplate = System/FilePath.new("")
        , aibHierarchyExport = {file = System/FilePath.new(""), sheet = "Sheet1"}
        , aibValveExport = {file = System/FilePath.new(""), sheet = "Sheet1"}
        , aibAgaspExport = {file = System/FilePath.new(""), sheet = "Sheet1"}
        , aibMemosExport = {file = System/FilePath.new(""), sheet = "Sheet1"}
        , worklist = {file = System/FilePath.new(""), sheet = "Sheet1"}
        , solutionId = ""
        , changeRequestName = "Valve Change Request"
        , outpath = System/FilePath.new("") 
        }  

    def makeCmdLineOptions(): List[OptionDescr[UpdateProgramArguments]] = 
           {optionIds = Nil,    optionNames = "uxl_template" :: Nil,            argDescriptor = ReqArg(setUxlTemplate, "FILE"),                 explanation = "path to UXL template"}
        :: {optionIds = Nil,    optionNames = "aib_hierarchy_export" :: Nil,    argDescriptor = ReqArg(setAibHierarchyExport, "FILE##Sheet"),   explanation = "path to AI2 hierarchy export and sheet name"}
        :: {optionIds = Nil,    optionNames = "aib_valve_export" :: Nil,        argDescriptor = ReqArg(setAibValveExport, "FILE##Sheet"),       explanation = "path to AI2 valve export"}
        :: {optionIds = Nil,    optionNames = "aib_agasp_export" :: Nil,        argDescriptor = ReqArg(setAibAgaspExport, "FILE##Sheet"),       explanation = "path to AI2 AGASP export"}
        :: {optionIds = Nil,    optionNames = "aib_memos_export" :: Nil,        argDescriptor = ReqArg(setAibMemosExport, "FILE##Sheet"),       explanation = "path to AI2 memo lines export"}
        :: {optionIds = Nil,    optionNames = "worklist" :: Nil,                argDescriptor = ReqArg(setWorklist, "FILE##Sheet"),             explanation = "path to worklist and sheet name"}
        :: {optionIds = Nil,    optionNames = "solution_id" :: Nil,             argDescriptor = ReqArg(setSolutionId, "TEXT"),                  explanation = "Solution Id, blank for none"}
        :: {optionIds = Nil,    optionNames = "change_request_name" :: Nil,     argDescriptor = ReqArg(setChangeRequestName, "TEXT"),           explanation = "Name for Change Request"}
        :: {optionIds = Nil,    optionNames = "outpath" :: Nil,                 argDescriptor = ReqArg(setOutpath, "FILE"),                     explanation = "path to UXL output"}
        :: Nil

    def setUxlTemplate(s: String): Option[UpdateProgramArguments] = 
        Some(opts -> {uxlTemplate = System/FilePath.new(s) | opts})
    
    def setAibHierarchyExport(s: String): Option[UpdateProgramArguments] = 
        Some(opts -> {aibHierarchyExport = AssetLib/GenS4/XlsxSource.fromString(s) | opts})
    
    def setAibValveExport(s: String): Option[UpdateProgramArguments] = 
        Some(opts -> {aibValveExport = AssetLib/GenS4/XlsxSource.fromString(s) | opts})
    
    def setAibAgaspExport(s: String): Option[UpdateProgramArguments] = 
        Some(opts -> {aibAgaspExport = AssetLib/GenS4/XlsxSource.fromString(s) | opts})
    
    def setAibMemosExport(s: String): Option[UpdateProgramArguments] = 
        Some(opts -> {aibMemosExport = AssetLib/GenS4/XlsxSource.fromString(s) | opts})
    
    def setWorklist(s: String): Option[UpdateProgramArguments] = 
        Some(opts -> {worklist = AssetLib/GenS4/XlsxSource.fromString(s) | opts})
    
    def setSolutionId(s: String): Option[UpdateProgramArguments] = 
        Some(opts -> {solutionId = s | opts})
    
    def setChangeRequestName(s: String): Option[UpdateProgramArguments] = 
        Some(opts -> {changeRequestName = s | opts})
    
    def setOutpath(s: String): Option[UpdateProgramArguments] = 
        Some(opts -> {outpath = System/FilePath.new(s) | opts})


    pub def main1(args: Array[String]): Int32 & Impure = 
        use GetOpt.ArgOrder.{Permute};
        use GetOpt.{getOpt, usageInfo};
        let options1 = makeCmdLineOptions();
        let header = "Usage: <valve-report> [OPTION...]";
        let args2 = GetOpt.preprocess({quoteOpen = "'", quoteClose = "'", stripQuoteMarks = true}, args);
        match getOpt(Permute, options1, args2) {
            case Failure(errs)  => {Console.printLine("Errors: ${errs}");  Console.printLine(usageInfo(header, options1)); 1}
            case Success(updates) => {
                let progArgs = List.foldLeft((ac, f) -> f(ac), defaultProgramArguments(), updates.options);
                match main2(progArgs) {
                    case Ok() => {Console.printLine("Wrote: ${progArgs.outpath}"); 0}
                    case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
                }
            }
        }

    /// Empty string for no solution id.
    pub def main2(args: ProgramArguments): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        use AssetLib/GenS4/Characteristics/AibReference.{uxlEquiAibReference};
        use AssetLib/GenS4/Characteristics/AssetCondition.{uxlAssetCondition};
        use AssetLib/GenS4/Characteristics/EastNorth.{uxlEquiEastNorth};
        use AssetLib/GenS4/Characteristics/SolutionId.{uxlEquiSolutionId};
        use AssetLib/GenS4/MemoLines.{uxlEquiLongText};
        use ValveReport/Rules.{equiVALV, equiOther};
        let* baseRelns = ValveReport/Main.loadRelations(args);
        let today   = Time/LocalDate.now();
        let answers = solve uxlEquiSolutionId(args.solutionId) <+> uxlEquiLongText() 
                                <+> uxlAssetCondition() <+> uxlEquiAibReference() 
                                <+> uxlEquiEastNorth() <+> equiOther(today) 
                                <+> equiVALV(today) <+> baseRelns;
        (project EquiDatum answers) |> unsafeToString |> println;
        (project EquiCharacteristic answers) |> unsafeToString |> println;
        (project EquiLongText answers) |> unsafeToString |> println;
        let* _      = AssetLib/GenS4/EmitUxl.outputUxl(args.changeRequestName, answers, args.uxlTemplate, args.outpath);
        Ok()


    def loadRelations(args: ProgramArguments): Result[#{ValveWorkItem, RootNode, AibFloc, AibEquipment, 
                                                        EquiSortOrder,
                                                        AibFactGroup, AibStringValue, AibIntValue, AibFloatValue | r}, String] & Impure = 
        use Result.{flatMap};
        let* hrelns         = AssetLib/AibFacts/HierarchyFacts.readHierarchyRelations(args.aibHierarchyExport.sheet, args.aibHierarchyExport.file);
        let* valveAttribs   = AssetLib/AibFacts/Attributes/Valve.readValveData(args.aibValveExport.sheet, args.aibValveExport.file);
        let* agasp          = AssetLib/AibFacts/Attributes/AssetCondition.readAgaspData(args.aibAgaspExport.sheet, args.aibAgaspExport.file);
        let* memos          = AssetLib/AibFacts/Attributes/MemoLines.readMemoLinesData(args.aibMemosExport.sheet, args.aibMemosExport.file);
        let* workitems      = ValveReport/Relations.readWorkItemData(args.worklist.sheet, args.worklist.file);
        Ok(hrelns <+> valveAttribs <+> agasp <+> memos <+> workitems)

}
