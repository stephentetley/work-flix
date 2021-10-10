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
    

    type alias GenUxlSource = 
        { flocWorkList :: Option[XlsxSource]
        , equiWorkList :: Option[XlsxSource]
        , facts :: FactExports
        , optionalFacts :: OptionalExports
        }

    type alias FactExports =         
        { aibEquipmentExport :: XlsxSource
        , aibMemosExport :: XlsxSource
        , aibAgaspExport :: XlsxSource
        }

    type alias OptionalExports =
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

    /// Must work with batching...
    pub def generateUxl(src: GenUxlSource, outputArgs: UxlOutputArgs): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        use AssetLib/GenS4/GenMonad.{execGenMonad, return};
        use AssetLib/GenS4/GenMonad.{*>};
        let* flocs  = match src.flocWorkList { 
            case Some(x1) => execGenMonad(genFlocUxl(x1))
            case None => execGenMonad(return())
        };
        let* equis  = match src.equiWorkList { 
            case Some(x1) => execGenMonad(genEquiUxl(src.facts, x1) *> genOptional(src.optionalFacts, x1, #{}))
            case None => execGenMonad(return())
        };
        let* _      = AssetLib/S4Lite/EmitUxl.outputUxl(true, outputArgs, AssetLib/S4Lite/Datatypes.combineUxlSource(flocs, equis));
        Ok()

    /// pub def generateFlocUxl(workList: XlsxSource, outputArgs: UxlOutputArgs): Result[Unit, String] & Impure = 
    ///     use Result.{flatMap};
    ///     let* flocs  = AssetLib/GenS4/GenMonad.execGenMonad(genFlocUxl(workList));
    ///     let* _      = AssetLib/S4Lite/EmitUxl.outputUxl(true, outputArgs, flocs);
    ///     Ok()

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


    /// pub def generateEquiUxl(factExports: FactExports, optionalExports: OptionalExports,
    ///                             workList: XlsxSource, outputArgs: UxlOutputArgs): Result[Unit, String] & Impure = 
    ///     use Result.{flatMap};
    ///     use AssetLib/GenS4/GenMonad.{execGenMonad};
    ///     use AssetLib/GenS4/GenMonad.{*>};
    ///     let* equis  = execGenMonad(genEquiUxl(factExports, workList) *> genOptional(optionalExports, workList, #{}));
    ///     let* _      = AssetLib/S4Lite/EmitUxl.outputUxl(true, outputArgs, equis);
    ///     Ok()

    /// Empty string for no solution id.
    pub def genEquiUxl(args: FactExports, workList: XlsxSource): GenMonad[Unit] = 
        use AssetLib/GenS4/GenMonad.{flatMap, return, liftAction};
        let* workitems  = AssetLib/GenS4/WorkLists.readEquiWorkList(workList);
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

    /// `_dummy` and the casts are hacks to avoid declaring a huge schema type for facts.
    def genOptional(args: OptionalExports, workList: XlsxSource, _dummy: #{|r}): GenMonad[Unit] = 
        use AssetLib/GenS4/GenMonad.{flatMap, return, map};
        let* workitems  = AssetLib/GenS4/WorkLists.readEquiWorkList(workList) |> map(AssetLib/GenS4/WorkLists.makeEquiWorkItem3);
        let* f1     = loadOptional(args.aibElectricalExport, AssetLib/GenS4/AibFacts/Attributes/Electrical.readElectricalFacts);
        let* f2     = loadOptional(args.aibFanExport, AssetLib/GenS4/AibFacts/Attributes/Fan.readFanFacts);
        let* f3     = loadOptional(args.aibInstrumentExport, AssetLib/GenS4/AibFacts/Attributes/Instrument.readInstrumentFacts);
        let facts   = f1 <+> f2 <+> f3;
        let* _      = AssetLib/GenS4/Rules/Characteristics/Actu.genActu(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Actu.ActuFacts[r]);
    ///     let* _          = whenSome(args.aibElectricalExport, AssetLib/GenS4/Rules/Characteristics/Conp.genConp(workitems));
    ///     let* _          = whenSome(args.aibLiftingExport, AssetLib/GenS4/Rules/Characteristics/Crht.genCrht(workitems));
        let* _      = AssetLib/GenS4/Rules/Characteristics/Emtr.genEmtr(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Emtr.EmtrFacts[r]);
    ///     let* _          = whenSome(args.aibFanExport, AssetLib/GenS4/Rules/Characteristics/Fans.genFans(workitems));
    ///     let* _          = whenSome(args.aibInstrumentExport, AssetLib/GenS4/Rules/Characteristics/Fstn.genFstn(workitems));
    ///     let* _          = whenSome(args.aibLiftingExport, AssetLib/GenS4/Rules/Characteristics/Liac.genLiac(workitems));
    ///     let* _          = whenSome(args.aibLiftingExport, AssetLib/GenS4/Rules/Characteristics/Lisl.genLisl(workitems));
        let* _          = AssetLib/GenS4/Rules/Characteristics/Lstn.genLstn(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Lstn.LstnFacts[r]);
    ///     let* _          = whenSome(args.aibInstrumentExport, AssetLib/GenS4/Rules/Characteristics/Pstn.genPstn(workitems));
    ///     let* _          = whenSome(args.aibPumpExport, AssetLib/GenS4/Rules/Characteristics/Pump.genPump(workitems));
    ///     let* _          = whenSome(args.aibPumpExport, AssetLib/GenS4/Rules/Characteristics/Pums.genPums(workitems));
    ///     let* _          = whenSome(args.aibLiftingExport, AssetLib/GenS4/Rules/Characteristics/Sfer.genSfer(workitems));
    ///     let* _          = whenSome(args.aibElectricalExport, AssetLib/GenS4/Rules/Characteristics/Sole.genSole(workitems));
    ///     let* _          = whenSome(args.aibElectricalExport, AssetLib/GenS4/Rules/Characteristics/Star.genStar(workitems));
    ///     let* _          = whenSome(args.aibTankExport, AssetLib/GenS4/Rules/Characteristics/Tank.genTank(workitems));
    ///     let* _          = whenSome(args.aibInstrumentExport, AssetLib/GenS4/Rules/Characteristics/Tstn.genTstn(workitems));
    ///     let* _          = whenSome(args.aibValveExport, AssetLib/GenS4/Rules/Characteristics/Valv.genValv(workitems));
        return()

    def loadOptional(x: Option[XlsxSource], load: XlsxSource -> GenMonad[#{|r1}]): GenMonad[#{|r1}] = 
        use AssetLib/GenS4/GenMonad.{return};
        match x {
            case Some(src) => load(src)
            case None => return(#{})
        }



}
