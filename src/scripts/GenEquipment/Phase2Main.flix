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

namespace ValveReport/Phase2Main {

    use GetOpt.{ArgDescr, OptionDescr};
    use GetOpt.ArgDescr.{NoArg, ReqArg, OptArg};

    use AssetLib/AibFacts/Relations.{AibFactGroup, AibStringValue, AibIntValue, AibFloatValue};
    use AssetLib/GenS4/XlsxSource.{XlsxSource};
    use AssetLib/AibFacts/HierarchyFacts.{AibRootNode, AibFloc, AibEquipment};
    use AssetLib/AibFacts/Attributes/Equipment.{EquipmentAttibutes};
    use AssetLib/GenS4/MemoLines.{MemoText};
    use AssetLib/GenS4/Phase2.{Phase2Arguments};



    type alias UpdateArguments = Phase2Arguments -> Phase2Arguments


    def defaultArguments(): Phase2Arguments = 
        { userName = "asset_data_support"
        , aibHierarchyExport = {file = System/FilePath.new(""), sheet = "Sheet1"}
        , aibEquipmentExport = {file = System/FilePath.new(""), sheet = "Sheet1"}
        , aibAgaspExport = {file = System/FilePath.new(""), sheet = "Sheet1"}
        , aibElectricalExport = {file = System/FilePath.new(""), sheet = "Sheet1"}
        , aibRangeSignalExport = {file = System/FilePath.new(""), sheet = "Sheet1"}
        , aibValveExport = {file = System/FilePath.new(""), sheet = "Sheet1"}
        , solutionId = None
        , phase1Worklist = {file = System/FilePath.new(""), sheet = "Sheet1"}
        , phase2Worklist = System/FilePath.new("")
        , outNameRoot = "equipment"
        , outdir = System/FilePath.new("") 
        }  

    def makeCmdLineOptions(): List[OptionDescr[UpdateArguments]] = 
           {optionIds = Nil,    optionNames = "user_name" :: Nil,               argDescriptor = ReqArg(setUserName, "TEXT"),                 explanation = "user name"}
        :: {optionIds = Nil,    optionNames = "aib_hierarchy_export" :: Nil,    argDescriptor = ReqArg(setAibHierarchyExport, "FILE##Sheet"),   explanation = "path to AI2 hierarchy export and sheet name"}
        :: {optionIds = Nil,    optionNames = "aib_equipment_export" :: Nil,    argDescriptor = ReqArg(setAibEquipmentExport, "FILE##Sheet"),   explanation = "path to AI2 equipment export and sheet name"}
        :: {optionIds = Nil,    optionNames = "aib_agasp_export" :: Nil,        argDescriptor = ReqArg(setAibAgaspExport, "FILE##Sheet"),       explanation = "path to AI2 asset condition export"}
        :: {optionIds = Nil,    optionNames = "aib_electrical_export" :: Nil,   argDescriptor = ReqArg(setAibElectricalExport, "FILE##Sheet"),       explanation = "path to AI2 electrical (motor etc.) export"}
        :: {optionIds = Nil,    optionNames = "aib_range_signal_export" :: Nil, argDescriptor = ReqArg(setAibRangeSignalExport, "FILE##Sheet"),       explanation = "path to AI2 range and signal export"}
        :: {optionIds = Nil,    optionNames = "aib_valve_export" :: Nil,        argDescriptor = ReqArg(setAibValveExport, "FILE##Sheet"),       explanation = "path to AI2 valves export"}
        :: {optionIds = Nil,    optionNames = "solution_id" :: Nil,             argDescriptor = ReqArg(setSolutionId, "TEXT"),                  explanation = "set solution_id"}
        :: {optionIds = Nil,    optionNames = "phase1_worklist" :: Nil,         argDescriptor = ReqArg(setPhase1Worklist, "FILE##Sheet"),       explanation = "path to phase1 worklist and sheet name"}
        :: {optionIds = Nil,    optionNames = "phase2_worklist" :: Nil,         argDescriptor = ReqArg(setPhase2Worklist, "FILE##Sheet"),       explanation = "path to phase2 worklist and sheet name"}
        :: {optionIds = Nil,    optionNames = "out_name_root" :: Nil,           argDescriptor = ReqArg(setOutNameRoot, "TEXT"),           explanation = "Name prefix for upload files"}
        :: {optionIds = Nil,    optionNames = "outdir" :: Nil,                  argDescriptor = ReqArg(setOutdir, "FILE"),                     explanation = "path to output directory"}
        :: Nil

    def setUserName(s: String): Option[UpdateArguments] = 
        Some(opts -> {userName = s | opts})
    
    def setAibHierarchyExport(s: String): Option[UpdateArguments] = 
        Some(opts -> {aibHierarchyExport = AssetLib/GenS4/XlsxSource.fromString(s) | opts})

    def setAibEquipmentExport(s: String): Option[UpdateArguments] = 
        Some(opts -> {aibEquipmentExport = AssetLib/GenS4/XlsxSource.fromString(s) | opts})

    def setAibAgaspExport(s: String): Option[UpdateArguments] = 
        Some(opts -> {aibAgaspExport = AssetLib/GenS4/XlsxSource.fromString(s) | opts})

    def setAibElectricalExport(s: String): Option[UpdateArguments] = 
        Some(opts -> {aibElectricalExport = AssetLib/GenS4/XlsxSource.fromString(s) | opts})

    def setAibRangeSignalExport(s: String): Option[UpdateArguments] = 
        Some(opts -> {aibRangeSignalExport = AssetLib/GenS4/XlsxSource.fromString(s) | opts})

    def setAibValveExport(s: String): Option[UpdateArguments] = 
        Some(opts -> {aibValveExport = AssetLib/GenS4/XlsxSource.fromString(s) | opts})

    def setSolutionId(s: String): Option[UpdateArguments] = 
        let ans = if (String.isEmpty(s)) None else Some(s);
        Some(opts -> {solutionId = ans | opts})

    def setPhase1Worklist(s: String): Option[UpdateArguments] = 
        Some(opts -> {phase1Worklist = AssetLib/GenS4/XlsxSource.fromString(s) | opts})
 
    def setPhase2Worklist(s: String): Option[UpdateArguments] = 
        Some(opts -> {phase2Worklist = System/FilePath.new(s) | opts})
    
    def setOutNameRoot(s: String): Option[UpdateArguments] = 
        Some(opts -> {outNameRoot = s | opts})
    
    def setOutdir(s: String): Option[UpdateArguments] = 
        Some(opts -> {outdir = System/FilePath.new(s) | opts})


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
                match AssetLib/GenS4/Phase2.phase2(progArgs) {
                    case Ok() => {Console.printLine("Wrote file to: ${progArgs.outdir}"); 0}
                    case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
                }
            }
        }


}
