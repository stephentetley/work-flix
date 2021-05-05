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

namespace ValveReport/Phase1Main {

    use GetOpt.{ArgDescr, OptionDescr};
    use GetOpt.ArgDescr.{NoArg, ReqArg, OptArg};

    use AssetLib/AibFacts/Relations.{AibFactGroup, AibStringValue, AibIntValue, AibFloatValue};
    use AssetLib/GenS4/XlsxSource.{XlsxSource};
    use AssetLib/AibFacts/HierarchyFacts.{AibRootNode, AibFloc, AibEquipment};
    use AssetLib/AibFacts/Attributes/Equipment.{EquipmentAttibutes};
    use AssetLib/GenS4/MemoLines.{MemoText};
    use AssetLib/GenS4/Phase1.{Phase1Arguments};



    type alias UpdateArguments = Phase1Arguments -> Phase1Arguments

    def defaultArguments(): Phase1Arguments = 
        { uxlTemplate = System/FilePath.new("")
        , aibHierarchyExport = {file = System/FilePath.new(""), sheet = "Sheet1"}
        , aibEquipmentExport = {file = System/FilePath.new(""), sheet = "Sheet1"}
        , aibMemosExport = {file = System/FilePath.new(""), sheet = "Sheet1"}
        , aibValvesExport = None
        , phase1Worklist = {file = System/FilePath.new(""), sheet = "Sheet1"}
        , changeRequestName = "Change Request"
        , outpath = System/FilePath.new("") 
        }  

    def makeCmdLineOptions(): List[OptionDescr[UpdateArguments]] = 
           {optionIds = Nil,    optionNames = "uxl_template" :: Nil,            argDescriptor = ReqArg(setUxlTemplate, "FILE"),                 explanation = "path to UXL template"}
        :: {optionIds = Nil,    optionNames = "aib_hierarchy_export" :: Nil,    argDescriptor = ReqArg(setAibHierarchyExport, "FILE##Sheet"),   explanation = "path to AI2 hierarchy export and sheet name"}
        :: {optionIds = Nil,    optionNames = "aib_equipment_export" :: Nil,    argDescriptor = ReqArg(setAibEquipmentExport, "FILE##Sheet"),   explanation = "path to AI2 equipment export and sheet name"}
        :: {optionIds = Nil,    optionNames = "aib_memos_export" :: Nil,        argDescriptor = ReqArg(setAibMemosExport, "FILE##Sheet"),       explanation = "path to AI2 memo lines export"}
        :: {optionIds = Nil,    optionNames = "aib_valves_export" :: Nil,       argDescriptor = ReqArg(setAibValvesExport, "FILE##Sheet"),       explanation = "path to AI2 valves export"}
        :: {optionIds = Nil,    optionNames = "worklist" :: Nil,                argDescriptor = ReqArg(setWorklist, "FILE##Sheet"),             explanation = "path to worklist and sheet name"}
        :: {optionIds = Nil,    optionNames = "change_request_name" :: Nil,     argDescriptor = ReqArg(setChangeRequestName, "TEXT"),           explanation = "Name for Change Request"}
        :: {optionIds = Nil,    optionNames = "outpath" :: Nil,                 argDescriptor = ReqArg(setOutpath, "FILE"),                     explanation = "path to UXL output"}
        :: Nil

    def setUxlTemplate(s: String): Option[UpdateArguments] = 
        Some(opts -> {uxlTemplate = System/FilePath.new(s) | opts})
    
    def setAibHierarchyExport(s: String): Option[UpdateArguments] = 
        Some(opts -> {aibHierarchyExport = AssetLib/GenS4/XlsxSource.fromString(s) | opts})

    def setAibEquipmentExport(s: String): Option[UpdateArguments] = 
        Some(opts -> {aibEquipmentExport = AssetLib/GenS4/XlsxSource.fromString(s) | opts})        
    
    def setAibMemosExport(s: String): Option[UpdateArguments] = 
        Some(opts -> {aibMemosExport = AssetLib/GenS4/XlsxSource.fromString(s) | opts})

    def setAibValvesExport(s: String): Option[UpdateArguments] = 
        Some(opts -> {aibValvesExport = Some(AssetLib/GenS4/XlsxSource.fromString(s)) | opts})


    def setWorklist(s: String): Option[UpdateArguments] = 
        Some(opts -> {phase1Worklist = AssetLib/GenS4/XlsxSource.fromString(s) | opts})
 
    
    def setChangeRequestName(s: String): Option[UpdateArguments] = 
        Some(opts -> {changeRequestName = s | opts})
    
    def setOutpath(s: String): Option[UpdateArguments] = 
        Some(opts -> {outpath = System/FilePath.new(s) | opts})


    pub def main(args: Array[String]): Int32 & Impure = 
        use GetOpt.ArgOrder.{Permute};
        use GetOpt.{getOpt, usageInfo};
        let options1 = makeCmdLineOptions();
        let header = "Usage: <phase1> [OPTION...]";
        let args2 = GetOpt.preprocess({quoteOpen = "'", quoteClose = "'", stripQuoteMarks = true}, args);
        match getOpt(Permute, options1, args2) {
            case Failure(errs)  => {Console.printLine("Errors: ${errs}");  Console.printLine(usageInfo(header, options1)); 1}
            case Success(updates) => {
                let progArgs = List.foldLeft((ac, f) -> f(ac), defaultArguments(), updates.options);
                match AssetLib/GenS4/Phase1.phase1(progArgs) {
                    case Ok() => {Console.printLine("Wrote: ${progArgs.outpath}"); 0}
                    case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
                }
            }
        }


}
