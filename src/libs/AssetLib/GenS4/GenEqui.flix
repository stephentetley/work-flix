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


namespace AssetLib/GenS4/GenEqui {

    use SheetIO/Reader.{XlsxSource};


    use AssetLib/S4Lite/Datatypes.{UxlSource};
    use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};

    type alias GenEquiArguments = 
        { workList: XlsxSource
        , aibEquipmentExport: XlsxSource
        , aibMemosExport: XlsxSource
        , aibGridRefsExport: XlsxSource
        , aibAgaspExport: XlsxSource
        }

    pub def emitEquiUxl(genArgs: GenEquiArguments, outputArgs: UxlOutputArgs): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let* equis  = AssetLib/GenS4/GenMonad.execGenMonad(generateEquiUxl(genArgs));
        let* _      = AssetLib/S4Lite/EmitUxl.outputUxl(true, outputArgs, equis);
        Ok()

    /// Empty string for no solution id.
    pub def generateEquiUxl(args: GenEquiArguments): GenMonad[Unit] = 
        use AssetLib/GenS4/GenMonad.{flatMap, return, liftAction};
        let* workitems  = AssetLib/GenS4/WorkLists.readEquiWorkList(args.workList);
        let* _          = liftAction(_ -> Console.printLine("workitems count: ${List.length(workitems)}"));
        let* equiAttrs  = AssetLib/GenS4/AibFacts/Attributes/Equipment.readEquipmentData(args.aibEquipmentExport);
        let* _          = AssetLib/GenS4/Rules/Equipment.genEquis(equiAttrs, workitems);
        let* _          = AssetLib/GenS4/Rules/LongText.genEquiLongText(workitems, args.aibMemosExport, args.aibEquipmentExport);
        let* _          = AssetLib/GenS4/Rules/Equipment.genCommonCharacteristics(workitems, args.aibEquipmentExport);
        let* _          = AssetLib/GenS4/Rules/Characteristics/AibReference.genEquiAibReference(workitems, args.aibEquipmentExport);
        let* _          = AssetLib/GenS4/Rules/Characteristics/SolutionId.genEquiSolutionId(workitems);
        let* _          = AssetLib/GenS4/Rules/Characteristics/EastNorth.genEquiEastNorth(workitems, args.aibGridRefsExport);
        let* _          = AssetLib/GenS4/Rules/Characteristics/AssetCondition.genAssetCondition(workitems, args.aibAgaspExport);
        return()

    /// Phase 2

    type alias Phase2GenEquiArguments = 
        { workList: XlsxSource
        , s4ChangeRequestEquiTab: System.FilePath       /// Sheet always called Data
        , aibElectricalExport: Option[XlsxSource]
        , aibInstrumentExport: Option[XlsxSource]
        , aibLiftingExport: Option[XlsxSource]
        , aibPumpExport: Option[XlsxSource]
        , aibValveExport: Option[XlsxSource]
        }

    type alias FileUploadOutputArgs = 
        { outputDirectory: System.FilePath
        , userName: String
        , filePrefix: String
        }    

    pub def emitPhase2EquiUxl(genArgs: Phase2GenEquiArguments, outputArgs: FileUploadOutputArgs): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let* (uxl, workitems) = AssetLib/GenS4/GenMonad.runGenMonad(generatePhase2Equi(genArgs));
        let chars       = uxl.equiCharacteristics;
        let renamings   = AssetLib/GenS4/WorkLists.getEquipmentWorkItemKeyMap(workitems);
        let* cs1        = AssetLib/S4Lite/EmitUpload.renumberSLEquiCharacteristics(renamings, {path = genArgs.s4ChangeRequestEquiTab, sheet = "Data"}, chars);
        let filter      = AssetLib/S4Lite/EmitUpload.allClassFilter();
        let* _          = AssetLib/S4Lite/EmitUpload.outputEquiUploads(outputArgs.userName, cs1, outputArgs.filePrefix, filter, outputArgs.outputDirectory);
        Ok()


    pub def generatePhase2Equi(args: Phase2GenEquiArguments): GenMonad[List[EquiWorkItem]] = 
        use AssetLib/GenS4/GenMonad.{flatMap, return, whenSome};
        let* workitems  = AssetLib/GenS4/WorkLists.readEquiWorkList(args.workList);
        let* _          = whenSome(args.aibElectricalExport, AssetLib/GenS4/Rules/Characteristics/Actu.genActu(workitems));
        let* _          = whenSome(args.aibLiftingExport, AssetLib/GenS4/Rules/Characteristics/Crht.genCrht(workitems));
        let* _          = whenSome(args.aibInstrumentExport, AssetLib/GenS4/Rules/Characteristics/Fstn.genFstn(workitems));
        let* _          = whenSome(args.aibInstrumentExport, AssetLib/GenS4/Rules/Characteristics/Lstn.genLstn(workitems));
        let* _          = whenSome(args.aibInstrumentExport, AssetLib/GenS4/Rules/Characteristics/Pstn.genPstn(workitems));
        let* _          = whenSome(args.aibPumpExport, AssetLib/GenS4/Rules/Characteristics/Pump.genPump(workitems));
        let* _          = whenSome(args.aibPumpExport, AssetLib/GenS4/Rules/Characteristics/Pums.genPums(workitems));
        let* _          = whenSome(args.aibElectricalExport, AssetLib/GenS4/Rules/Characteristics/Sole.genSole(workitems));
        let* _          = whenSome(args.aibInstrumentExport, AssetLib/GenS4/Rules/Characteristics/Tstn.genTstn(workitems));
        let* _          = whenSome(args.aibValveExport, AssetLib/GenS4/Rules/Characteristics/Valv.genValv(workitems));
        return(workitems)


/// ACTU    Electrical
/// FSTN    Instrument
/// LSTN    Instrument
/// PSTN    Instrument
/// PUMP    Pump
/// SOLE    Electrical
/// TANK



/// def crht(): Phase2Step = xs -> 
///     let src = {path = System/FilePath.new("G:/work/assets/lifting-equipment-2021/knost/knost-lifting-export.xlsx"), sheet = "Sheet1"};
///     AssetLib/GenS4/Rules/Characteristics/Crht.genCrht(xs, src) 

/// def emtr(): Phase2Step = xs -> 
///     let src = {path = System/FilePath.new("G:/work/assets/capital_schemes/dri02/driff-electrical-export.xlsx"), sheet = "Sheet1"};
///     AssetLib/GenS4/Rules/Characteristics/Emtr.genEmtr(xs, src) 

/// def fstn(): Phase2Step = xs -> 
///     let src = {path = System/FilePath.new("G:/work/assets/capital_schemes/dri02/driff-instrument-export.xlsx"), sheet = "Sheet1"};
///     AssetLib/GenS4/Rules/Characteristics/Fstn.genFstn(xs, src) 


/// def liac(): Phase2Step = xs -> 
///     let src = {path = System/FilePath.new("G:/work/assets/lifting-equipment-2021/knost/knost-lifting-export.xlsx"), sheet = "Sheet1"};
///     AssetLib/GenS4/Rules/Characteristics/Liac.genLiac(xs, src) 

/// def lisl(): Phase2Step = xs -> 
///     let src = {path = System/FilePath.new("G:/work/assets/lifting-equipment-2021/knost/knost-lifting-export.xlsx"), sheet = "Sheet1"};
///     AssetLib/GenS4/Rules/Characteristics/Lisl.genLisl(xs, src) 



/// def pstn(): Phase2Step = xs -> 
///     let src = {path = System/FilePath.new("G:/work/assets/capital_schemes/dri02/driff-instrument-export.xlsx"), sheet = "Sheet1"};
///     AssetLib/GenS4/Rules/Characteristics/Pstn.genPstn(xs, src) 






}
