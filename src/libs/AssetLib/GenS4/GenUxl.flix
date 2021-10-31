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
    use AssetLib/GenS4/WorkLists.{FlocWorkItem, EquiWorkItem};
    

    pub type alias GenUxlSource = 
        { flocWorkList :: Option[XlsxSource]
        , equiWorkList :: Option[XlsxSource]
        , facts :: FactExports
        , optionalFacts :: OptionalExports
        }

    pub type alias FactExports =         
        { aibEquipmentExport :: XlsxSource
        , aibMemosExport :: XlsxSource
        , aibAgaspExport :: XlsxSource
        }

    pub type alias OptionalExports =
        { aibElectricalExport :: Option[XlsxSource]
        , aibFanExport :: Option[XlsxSource]
        , aibInstrumentExport :: Option[XlsxSource]
        , aibLiftingExport :: Option[XlsxSource]
        , aibPumpExport :: Option[XlsxSource]
        , aibTankExport :: Option[XlsxSource]
        , aibValveExport :: Option[XlsxSource]
        }

    pub def emptyOptionalExports(): OptionalExports = 
        { aibElectricalExport = None
        , aibFanExport = None
        , aibInstrumentExport = None
        , aibLiftingExport = None
        , aibPumpExport = None
        , aibTankExport = None
        , aibValveExport = None
        }

    /// Floc should be its own batch...

    pub def generateUxl(src: GenUxlSource, outputArgs: UxlOutputArgs): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        use AssetLib/GenS4/GenMonad.{execGenMonad};
        use AssetLib/GenS4/GenMonad.{*>};
        let* flocItems      = match src.flocWorkList { 
            case Some(x1) => AssetLib/GenS4/WorkLists.readFlocWorkList(x1)
            case None => Ok(Nil)
        };
        let* flocUxl        = execGenMonad(genFlocUxl(flocItems));
        let* equiItems      = match src.equiWorkList { 
            case Some(x1) => AssetLib/GenS4/WorkLists.readEquiWorkList(x1)
            case None => Ok(Nil)
        };
        let equiGroups      = List.groupBy((x1, y1) -> x1.batchNumber == y1.batchNumber, equiItems);
        let* equiBatches    = Result.traverse(xs -> execGenMonad(genEquiUxl(src.facts, xs) *> genOptional(src.optionalFacts, xs, #{})), equiGroups);
        let* _              = writeFlocs(flocUxl, outputArgs);
        let _               = Console.printLine("Batch count: ${List.length(equiBatches)}");
        let* _              = writeEquiBatches(equiBatches, outputArgs);
        Ok()



    def writeFlocs(src1: UxlSource, outputArgs: UxlOutputArgs): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        if (not Chain.isEmpty(src1.funclocs)) {
            let path    = System/FilePath.mapBaseName(s -> s + "_Flocs", outputArgs.outpath);
            let crname  = outputArgs.changeRequestName + " Flocs";
            let args    = {outpath = path, changeRequestName = crname, uxlTemplate = outputArgs.uxlTemplate};
            let* _      = AssetLib/S4Lite/EmitUxl.outputMocrUxl(args, src1);
            let _       = Console.printLine("Wrote: ${path}");
            Ok()
        } else Ok()



    def writeEquiBatches(xs: List[UxlSource], outputArgs: UxlOutputArgs): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let step = (ix, uxl) -> { 
            let path    = System/FilePath.mapBaseName(s -> s + "_Equi${ix}", outputArgs.outpath);
            let crname  = outputArgs.changeRequestName + " Equi${ix}";
            let args    = {outpath = path, changeRequestName = crname, uxlTemplate = outputArgs.uxlTemplate};
            let* _      = AssetLib/S4Lite/EmitUxl.outputMocrUxl(args, uxl);
            let _       = Console.printLine("Wrote: ${path}");
            Ok(ix + 1)
        };
        let* _  = Result.foldLeftM(step, 1, xs);
        Ok()


    /// Generate all characteristics 
    def genFlocUxl(workitems: List[FlocWorkItem]): GenMonad[Unit] = 
        use  AssetLib/GenS4/GenMonad.{flatMap, return};
        let* _  = AssetLib/Gens4/Rules/FunctionalLocation.genFlocs(workitems);
        let* _  = AssetLib/Gens4/Rules/FunctionalLocation.genFlocCharacteristics(workitems);
        let* _  = AssetLib/GenS4/Rules/Characteristics/AibReference.genFlocAibReference(workitems);
        let* _  = AssetLib/GenS4/Rules/Characteristics/EastNorth.genFlocEastNorth(workitems);
        let* _  = AssetLib/GenS4/Rules/Characteristics/SolutionId.genFlocSolutionId(workitems);
        return()


    /// Empty string for no solution id.
    def genEquiUxl(args: FactExports, workitems: List[EquiWorkItem]): GenMonad[Unit] = 
        use AssetLib/GenS4/GenMonad.{flatMap, return, liftAction};
        let* _          = liftAction(_ -> Console.printLine("Equi workitems count: ${List.length(workitems)}"));
        let* equiAttrs  = AssetLib/GenS4/AibFacts/Attributes/Equipment.readEquipmentData(args.aibEquipmentExport);
        let* _          = AssetLib/GenS4/Rules/Equipment.genEquis(equiAttrs, workitems);
        let* _          = AssetLib/GenS4/Rules/LongText.genEquiLongText(workitems, args.aibMemosExport, args.aibEquipmentExport);
        let* _          = AssetLib/GenS4/Rules/Equipment.genCommonCharacteristics(workitems, args.aibEquipmentExport);
        let* _          = AssetLib/GenS4/Rules/Characteristics/AibReference.genEquiAibReference(workitems, args.aibEquipmentExport);
        let* _          = AssetLib/GenS4/Rules/Characteristics/SolutionId.genEquiSolutionId(workitems);
        let* _          = AssetLib/GenS4/Rules/Characteristics/EastNorth.genEquiEastNorth(workitems, args.aibEquipmentExport);
        let* _          = AssetLib/GenS4/Rules/Characteristics/AssetCondition.genAssetCondition(workitems, args.aibAgaspExport);
        return()

    /// `_dummy` and the casts of `facts` are hacks to avoid declaring a huge schema type for facts.
    def genOptional(args: OptionalExports, xs: List[EquiWorkItem], _dummy: #{|r}): GenMonad[Unit] = 
        use AssetLib/GenS4/GenMonad.{flatMap, return, map};
        let workitems  =AssetLib/GenS4/WorkLists.makeEquiWorkItem3(xs);
        let* f1     = loadOptional(args.aibElectricalExport, AssetLib/GenS4/AibFacts/Attributes/Electrical.readElectricalFacts);
        let* f2     = loadOptional(args.aibFanExport, AssetLib/GenS4/AibFacts/Attributes/Fan.readFanFacts);
        let* f3     = loadOptional(args.aibInstrumentExport, AssetLib/GenS4/AibFacts/Attributes/Instrument.readInstrumentFacts);
        let* f4     = loadOptional(args.aibLiftingExport, AssetLib/GenS4/AibFacts/Attributes/Lifting.readLiftingFacts);
        let* f5     = loadOptional(args.aibPumpExport, AssetLib/GenS4/AibFacts/Attributes/Pump.readPumpFacts);
        let* f6     = loadOptional(args.aibTankExport, AssetLib/GenS4/AibFacts/Attributes/Tank.readTankFacts);
        let* f7     = loadOptional(args.aibValveExport, AssetLib/GenS4/AibFacts/Attributes/Valve.readValveFacts);
        let facts   = f1 <+> f2 <+> f3 <+> f4 <+> f5 <+> f6 <+> f7;
        let* _      = AssetLib/GenS4/Rules/Characteristics/Actu.genActu(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Actu.ActuSchema[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Conp.genConp(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Conp.ConpSchema[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Crht.genCrht(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Crht.CrhtSchema[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Emtr.genEmtr(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Emtr.EmtrSchema[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Fans.genFans(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Fans.FansSchema[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Instrument.genFstn(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Instrument.FstnSchema[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Liac.genLiac(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Liac.LiacSchema[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Lisl.genLisl(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Lisl.LislSchema[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Instrument.genLstn(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Instrument.LstnSchema[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Mixr.genMixr(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Mixr.MixrSchema[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Instrument.genPstn(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Instrument.PstnSchema[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Pump.genPump(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Pump.PumpSchema[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Pums.genPums(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Pums.PumsSchema[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Scrf.genScrf(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Scrf.ScrfSchema[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Sfer.genSfer(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Sfer.SferSchema[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Sole.genSole(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Sole.SoleSchema[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Star.genStar(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Star.StarSchema[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Tank.genTank(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Tank.TankSchema[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Instrument.genTstn(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Instrument.TstnSchema[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Valv.genValv(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Valv.ValvSchema[r]);
        return()

    def loadOptional(x: Option[XlsxSource], load: XlsxSource -> GenMonad[#{|r1}]): GenMonad[#{|r1}] = 
        use AssetLib/GenS4/GenMonad.{return};
        match x {
            case Some(src) => load(src)
            case None => return(#{})
        }



}
