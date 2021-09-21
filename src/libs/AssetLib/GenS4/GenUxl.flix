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


namespace AssetLib/GenS4/GenUxl {

    use SheetIO/Reader.{XlsxSource};
    use AssetLib/S4Lite/Datatypes.{UxlSource, SLFunctionalLocation, SLFlocCharacteristic};
    use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
    use AssetLib/S4Lite/S4LiteRelations.{FlocCharacteristic};
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};
    

    type alias GenEquiArguments = 
        { aibEquipmentExport: XlsxSource
        , aibMemosExport: XlsxSource
        , aibAgaspExport: XlsxSource
        }

    pub def generateCombinedUxl(flocWorkList: XlsxSource, 
                            equiWorkList: XlsxSource, 
                            genEquiArgs: GenEquiArguments, outputArgs: UxlOutputArgs): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let* flocs  = AssetLib/GenS4/GenMonad.execGenMonad(genFlocUxl(flocWorkList));
        let* equis  = AssetLib/GenS4/GenMonad.execGenMonad(genEquiUxl(genEquiArgs, equiWorkList));
        let* _      = AssetLib/S4Lite/EmitUxl.outputUxl(true, outputArgs, AssetLib/S4Lite/Datatypes.combineUxlSource(flocs, equis));
        Ok()

    pub def generateFlocUxl(workList: XlsxSource, outputArgs: UxlOutputArgs): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let* flocs  = AssetLib/GenS4/GenMonad.execGenMonad(genFlocUxl(workList));
        let* _      = AssetLib/S4Lite/EmitUxl.outputUxl(true, outputArgs, flocs);
        Ok()

    /// Generate all characteristics 
    pub def genFlocUxl(workList: XlsxSource): GenMonad[Unit] = 
        use  AssetLib/GenS4/GenMonad.{flatMap, return};
        let* workitems  = AssetLib/GenS4/WorkLists.readFlocWorkList(workList);
        let* _  = AssetLib/Gens4/Rules/FunctionalLocation.genFlocs(workitems);
        let* _  = AssetLib/Gens4/Rules/FunctionalLocation.genFlocCharacteristics(workitems);
        let* _  = AssetLib/GenS4/Rules/Characteristics/AibReference.genFlocAibReference(workitems);
        let* _  = AssetLib/GenS4/Rules/Characteristics/EastNorth.genFlocEastNorth(workitems);
        let* _  = AssetLib/GenS4/Rules/Characteristics/SolutionId.genFlocSolutionId(workitems);
        return()


    pub def generateEquiUxl(genEquiArgs: GenEquiArguments, workList: XlsxSource, outputArgs: UxlOutputArgs): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let* equis  = AssetLib/GenS4/GenMonad.execGenMonad(genEquiUxl(genEquiArgs, workList));
        let* _      = AssetLib/S4Lite/EmitUxl.outputUxl(true, outputArgs, equis);
        Ok()

    /// Empty string for no solution id.
    pub def genEquiUxl(args: GenEquiArguments, workList: XlsxSource): GenMonad[Unit] = 
        use AssetLib/GenS4/GenMonad.{flatMap, return, liftAction};
        let* workitems  = AssetLib/GenS4/WorkLists.readEquiWorkList(workList);
        let* _          = liftAction(_ -> Console.printLine("workitems count: ${List.length(workitems)}"));
        let* equiAttrs  = AssetLib/GenS4/AibFacts/Attributes/Equipment.readEquipmentData(args.aibEquipmentExport);
        let* _          = AssetLib/GenS4/Rules/Equipment.genEquis(equiAttrs, workitems);
        let* _          = AssetLib/GenS4/Rules/LongText.genEquiLongText(workitems, args.aibMemosExport, args.aibEquipmentExport);
        let* _          = AssetLib/GenS4/Rules/Equipment.genCommonCharacteristics(workitems, args.aibEquipmentExport);
        let* _          = AssetLib/GenS4/Rules/Characteristics/AibReference.genEquiAibReference(workitems, args.aibEquipmentExport);
        let* _          = AssetLib/GenS4/Rules/Characteristics/SolutionId.genEquiSolutionId(workitems);
        let* _          = AssetLib/GenS4/Rules/Characteristics/EastNorth.genEquiEastNorth(workitems, args.aibEquipmentExport);
        let* _          = AssetLib/GenS4/Rules/Characteristics/AssetCondition.genAssetCondition(workitems, args.aibAgaspExport);
        return()

    /// Phase 2
    /// Phase 2 is hopefully a temporary fix to overcome limitations in the target system

    type alias Phase2GenEquiArguments = 
        { workList: XlsxSource
        , s4ChangeRequestEquiTab: System.FilePath       /// Sheet always called Data
        , aibElectricalExport: Option[XlsxSource]
        , aibFanExport: Option[XlsxSource]
        , aibInstrumentExport: Option[XlsxSource]
        , aibLiftingExport: Option[XlsxSource]
        , aibPumpExport: Option[XlsxSource]
        , aibTankExport: Option[XlsxSource]
        , aibValveExport: Option[XlsxSource]
        }

    type alias FileUploadOutputArgs = 
        { outputDirectory: System.FilePath
        , userName: String
        , filePrefix: String
        }    

    pub def generatePhase2EquiUxl(genArgs: Phase2GenEquiArguments, outputArgs: FileUploadOutputArgs): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let* (uxl, workitems) = AssetLib/GenS4/GenMonad.runGenMonad(genPhase2Equi(genArgs));
        let chars       = uxl.equiCharacteristics;
        let renamings   = AssetLib/GenS4/WorkLists.getEquipmentWorkItemKeyMap(workitems);
        let* cs1        = AssetLib/S4Lite/EmitUpload.renumberSLEquiCharacteristics(renamings, {path = genArgs.s4ChangeRequestEquiTab, sheet = "Data"}, chars);
        let filter      = AssetLib/S4Lite/EmitUpload.noneClassFilter();
        let* _          = AssetLib/S4Lite/EmitUpload.outputEquiUploads(outputArgs.userName, cs1, outputArgs.filePrefix, filter, outputArgs.outputDirectory);
        Ok()


    pub def genPhase2Equi(args: Phase2GenEquiArguments): GenMonad[List[EquiWorkItem]] = 
        use AssetLib/GenS4/GenMonad.{flatMap, return, whenSome};
        let* workitems  = AssetLib/GenS4/WorkLists.readEquiWorkList(args.workList);
        let* _          = whenSome(args.aibElectricalExport, AssetLib/GenS4/Rules/Characteristics/Actu.genActu(workitems));
        let* _          = whenSome(args.aibElectricalExport, AssetLib/GenS4/Rules/Characteristics/Conp.genConp(workitems));
        let* _          = whenSome(args.aibLiftingExport, AssetLib/GenS4/Rules/Characteristics/Crht.genCrht(workitems));
        let* _          = whenSome(args.aibElectricalExport, AssetLib/GenS4/Rules/Characteristics/Emtr.genEmtr(workitems));
        let* _          = whenSome(args.aibFanExport, AssetLib/GenS4/Rules/Characteristics/Fans.genFans(workitems));
        let* _          = whenSome(args.aibInstrumentExport, AssetLib/GenS4/Rules/Characteristics/Fstn.genFstn(workitems));
        let* _          = whenSome(args.aibLiftingExport, AssetLib/GenS4/Rules/Characteristics/Liac.genLiac(workitems));
        let* _          = whenSome(args.aibLiftingExport, AssetLib/GenS4/Rules/Characteristics/Lisl.genLisl(workitems));
        let* _          = whenSome(args.aibInstrumentExport, AssetLib/GenS4/Rules/Characteristics/Lstn.genLstn(workitems));
        let* _          = whenSome(args.aibInstrumentExport, AssetLib/GenS4/Rules/Characteristics/Pstn.genPstn(workitems));
        let* _          = whenSome(args.aibPumpExport, AssetLib/GenS4/Rules/Characteristics/Pump.genPump(workitems));
        let* _          = whenSome(args.aibPumpExport, AssetLib/GenS4/Rules/Characteristics/Pums.genPums(workitems));
        let* _          = whenSome(args.aibLiftingExport, AssetLib/GenS4/Rules/Characteristics/Sfer.genSfer(workitems));
        let* _          = whenSome(args.aibElectricalExport, AssetLib/GenS4/Rules/Characteristics/Sole.genSole(workitems));
        let* _          = whenSome(args.aibElectricalExport, AssetLib/GenS4/Rules/Characteristics/Star.genStar(workitems));
        let* _          = whenSome(args.aibTankExport, AssetLib/GenS4/Rules/Characteristics/Tank.genTank(workitems));
        let* _          = whenSome(args.aibInstrumentExport, AssetLib/GenS4/Rules/Characteristics/Tstn.genTstn(workitems));
        let* _          = whenSome(args.aibValveExport, AssetLib/GenS4/Rules/Characteristics/Valv.genValv(workitems));
        return(workitems)


}
