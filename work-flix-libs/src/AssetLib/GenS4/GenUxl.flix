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

    use Compatibility.{XlsxSource};
    
    use AssetLib/S4Lite/Datatypes.{UxlOutput, SLFunctionalLocation, SLFlocCharacteristic};
    use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
    use AssetLib/S4Lite/S4LiteRelations.{FlocCharacteristic};
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/WorkLists.{FlocWorkItem, EquiWorkItem};
    

    pub type alias GenUxlSource = 
        { flocWorkList :: Option[XlsxSource]
        , equiWorkList :: Option[XlsxSource]
        , facts :: FactExports
        }

    pub type alias FactExports =         
        { aibEquipmentExport :: XlsxSource
        , aibMemosExport :: XlsxSource
        , aibAgaspExport :: XlsxSource
        , optExports :: OptionalExports
        }

    pub type alias OptionalExports =
        { aibElectricalExport :: Option[XlsxSource]
        , aibFanExport :: Option[XlsxSource]
        , aibInstrumentExport :: Option[XlsxSource]
        , aibLiftingExport :: Option[XlsxSource]
        , aibPumpExport :: Option[XlsxSource]
        , aibTankExport :: Option[XlsxSource]
        , aibValveExport :: Option[XlsxSource]
        , aibVesselExport1 :: Option[XlsxSource]
        , aibVesselExport2 :: Option[XlsxSource]
        }

    pub def emptyOptionalExports(): OptionalExports = 
        { aibElectricalExport = None
        , aibFanExport = None
        , aibInstrumentExport = None
        , aibLiftingExport = None
        , aibPumpExport = None
        , aibTankExport = None
        , aibValveExport = None
        , aibVesselExport1 = None
        , aibVesselExport2 = None
        }

    /// Flocs and equi now in batches...

    pub def generateUxl(src: GenUxlSource, outputArgs: UxlOutputArgs): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        use AssetLib/GenS4/GenMonad.{execGenMonad};
        let* flocItems      = match src.flocWorkList { 
            case Some(x1) => AssetLib/GenS4/WorkLists.readFlocWorkList(x1)
            case None => Ok(Nil)
        };
        let flocGroups      = List.groupBy((x1, y1) -> x1.batchNumber == y1.batchNumber, flocItems);
        let* equiItems      = match src.equiWorkList { 
            case Some(x1) => AssetLib/GenS4/WorkLists.readEquiWorkList(x1)
            case None => Ok(Nil)
        };
        let equiGroups      = List.groupBy((x1, y1) -> x1.batchNumber == y1.batchNumber, equiItems);
        let sourceGroups    = joinGroups(flocGroups, equiGroups);

        let* batches        = Result.traverse(x1 -> execGenMonad(genUxl(src.facts, x1)), sourceGroups);
        let _               = println("Batch count: ${List.length(batches)}");
        let* _              = writeBatches(outputArgs, batches);
        Ok()

    def joinGroups(flocGroups: List[List[FlocWorkItem]], 
                    equiGroups: List[List[EquiWorkItem]]): List[{floc :: List[FlocWorkItem], equi :: List[EquiWorkItem]}] = 
        let getFlocIndex = x1 -> match x1 {
            case Nil     => 0
            case r1 :: _ => r1.batchNumber
        };
        let getEquiIndex = x1 -> match x1 {
            case Nil     => 0
            case r1 :: _ => r1.batchNumber
        };
        let flocStep = (acc, xs) -> match getFlocIndex(xs) {
            case ix if (ix > 0) => Map.insert(ix, {floc = xs, equi = Nil}, acc)
            case _              => acc
        };
        let equiStep = (acc, xs) -> match getEquiIndex(xs) {
            case ix if ix > 0 => Map.insertWith((new1, old1) -> {floc = old1.floc, equi = new1.equi}, ix, {floc = Nil, equi = xs}, acc) 
            case _            => acc
        };
        let m1 = List.foldLeft(flocStep, Map.empty(), flocGroups);
        let m2 = List.foldLeft(equiStep, m1, equiGroups);
        Map.valuesOf(m2)




    def writeBatches(outputArgs: UxlOutputArgs, xs: List[UxlOutput]): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let strIndex = i -> String.padLeft(2, '0', "${i}");
        let step = (ix, uxl) -> { 
            let path    = FlixSandbox/System/FilePath.mapBaseName(s -> s + "_${strIndex(ix)}", outputArgs.outpath);
            let crname  = String.replace(from = "##", to = strIndex(ix),  outputArgs.changeRequestName);
            let args    = {outpath = path, changeRequestName = crname, uxlTemplate = outputArgs.uxlTemplate};
            let* _      = AssetLib/S4Lite/EmitUxl.outputMocrUxl(args, uxl);
            let _       = println("Wrote: ${path}");
            Ok(ix + 1)
        };
        let* _  = Result.foldLeftM(step, 1, xs);
        Ok()


    def genUxl(args: FactExports, workitems: {floc :: List[FlocWorkItem], equi :: List[EquiWorkItem]}): GenMonad[Unit] = 
        use  AssetLib/GenS4/GenMonad.{flatMap, point};
        let* _  = genFlocUxl(workitems.floc);
        let* _  = genEquiUxl(args, workitems.equi);
        let* _  = genEquiCharacteristics(args.optExports,workitems.equi);
        point()

    /// Generate all characteristics 
    def genFlocUxl(workitems: List[FlocWorkItem]): GenMonad[Unit] = 
        use  AssetLib/GenS4/GenMonad.{flatMap, point};
        let* _  = AssetLib/Gens4/Rules/FunctionalLocation.genFlocs(workitems);
        let* _  = AssetLib/Gens4/Rules/FunctionalLocation.genFlocCharacteristics(workitems);
        let* _  = AssetLib/GenS4/Rules/Characteristics/AibReference.genFlocAibReference(workitems);
        let* _  = AssetLib/GenS4/Rules/Characteristics/EastNorth.genFlocEastNorth(workitems);
        let* _  = AssetLib/GenS4/Rules/Characteristics/SolutionId.genFlocSolutionId(workitems);
        point()


    def genEquiUxl(args: FactExports, workitems: List[EquiWorkItem]): GenMonad[Unit] = 
        use AssetLib/GenS4/GenMonad.{flatMap, point, liftAction};
        let* _          = liftAction(_ -> println("Equi workitems count: ${List.length(workitems)}"));
        let* equiAttrs  = AssetLib/GenS4/AibFacts/Attributes/Equipment.readEquipmentData(args.aibEquipmentExport);
        let* _          = AssetLib/GenS4/Rules/Equipment.genEquis(equiAttrs, workitems);
        let* _          = AssetLib/GenS4/Rules/MultilingualText.genEquiLongText(workitems, {memosSrc = args.aibMemosExport,  locsSrc = args.aibEquipmentExport});
        let* _          = AssetLib/GenS4/Rules/Equipment.genCommonCharacteristics(workitems, args.aibEquipmentExport, args.aibMemosExport);
        let* _          = AssetLib/GenS4/Rules/Characteristics/AibReference.genEquiAibReference(workitems, args.aibEquipmentExport);
        let* _          = AssetLib/GenS4/Rules/Characteristics/SolutionId.genEquiSolutionId(workitems);
        let* _          = AssetLib/GenS4/Rules/Characteristics/EastNorth.genEquiEastNorth(workitems, args.aibEquipmentExport);
        let* _          = AssetLib/GenS4/Rules/Characteristics/AssetCondition.genAssetCondition(workitems, args.aibAgaspExport);
        point()


    def genEquiCharacteristics(args: OptionalExports, xs: List[EquiWorkItem]): GenMonad[Unit] = 
        use AssetLib/GenS4/GenMonad.{flatMap, point, map};
        let workitems = AssetLib/GenS4/WorkLists.makeEquiWorkItem3(xs);
        let* f1     = loadOptional(args.aibElectricalExport, AssetLib/GenS4/AibFacts/Attributes/Electrical.readElectricalFacts);
        let* f2     = loadOptional(args.aibFanExport, AssetLib/GenS4/AibFacts/Attributes/Fan.readFanFacts);
        let* f3     = loadOptional(args.aibInstrumentExport, AssetLib/GenS4/AibFacts/Attributes/Instrument.readInstrumentFacts);
        let* f4     = loadOptional(args.aibLiftingExport, AssetLib/GenS4/AibFacts/Attributes/Lifting.readLiftingFacts);
        let* f5     = loadOptional(args.aibPumpExport, AssetLib/GenS4/AibFacts/Attributes/Pump.readPumpFacts);
        let* f6     = loadOptional(args.aibTankExport, AssetLib/GenS4/AibFacts/Attributes/Tank.readTankFacts);
        let* f7     = loadOptional(args.aibValveExport, AssetLib/GenS4/AibFacts/Attributes/Valve.readValveFacts);
        let* f8     = loadOptional(args.aibVesselExport1, AssetLib/GenS4/AibFacts/Attributes/Vessel.readVesselFacts);
        let* f9     = loadOptional(args.aibVesselExport2, AssetLib/GenS4/AibFacts/Attributes/Vessel.readVesselFacts);
        let facts   = f1 <+> f2 <+> f3 <+> f4 <+> f5 <+> f6 <+> f7 <+> f8 <+> f9;
        let* _      = AssetLib/GenS4/Rules/Characteristics/BuildingsCivils.genBuildingsCivilsCharacteristics(workitems, facts);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Electrical.genElectricalCharacteristics(workitems, facts);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Instrument.genInstrumentCharacteristics(workitems, facts);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Mechanical.genMechanicalCharacteristics(workitems, facts);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Statutory.genStatutoryCharacteristics(workitems, facts);
        point()


    def loadOptional(x: Option[XlsxSource], load: XlsxSource -> GenMonad[#{|r1}]): GenMonad[#{|r1}] = 
        use AssetLib/GenS4/GenMonad.{point};
        match x {
            case Some(src) => load(src)
            case None => point(#{})
        }



}
