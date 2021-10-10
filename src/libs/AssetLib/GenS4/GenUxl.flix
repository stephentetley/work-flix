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



    /// Generate all characteristics 
    def genFlocUxl(workList: XlsxSource): GenMonad[Unit] = 
        use  AssetLib/GenS4/GenMonad.{flatMap, return};
        let* workitems  = AssetLib/GenS4/WorkLists.readFlocWorkList(workList);
        let* _  = AssetLib/Gens4/Rules/FunctionalLocation.genFlocs(workitems);
        let* _  = AssetLib/Gens4/Rules/FunctionalLocation.genFlocCharacteristics(workitems);
        let* _  = AssetLib/GenS4/Rules/Characteristics/AibReference.genFlocAibReference(workitems);
        let* _  = AssetLib/GenS4/Rules/Characteristics/EastNorth.genFlocEastNorth(workitems);
        let* _  = AssetLib/GenS4/Rules/Characteristics/SolutionId.genFlocSolutionId(workitems);
        return()


    /// Empty string for no solution id.
    def genEquiUxl(args: FactExports, workList: XlsxSource): GenMonad[Unit] = 
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

    /// `_dummy` and the casts of `facts` are hacks to avoid declaring a huge schema type for facts.
    def genOptional(args: OptionalExports, workList: XlsxSource, _dummy: #{|r}): GenMonad[Unit] = 
        use AssetLib/GenS4/GenMonad.{flatMap, return, map};
        let* workitems  = AssetLib/GenS4/WorkLists.readEquiWorkList(workList) |> map(AssetLib/GenS4/WorkLists.makeEquiWorkItem3);
        let* f1     = loadOptional(args.aibElectricalExport, AssetLib/GenS4/AibFacts/Attributes/Electrical.readElectricalFacts);
        let* f2     = loadOptional(args.aibFanExport, AssetLib/GenS4/AibFacts/Attributes/Fan.readFanFacts);
        let* f3     = loadOptional(args.aibInstrumentExport, AssetLib/GenS4/AibFacts/Attributes/Instrument.readInstrumentFacts);
        let* f4     = loadOptional(args.aibLiftingExport, AssetLib/GenS4/AibFacts/Attributes/Lifting.readLiftingFacts);
        let* f5     = loadOptional(args.aibPumpExport, AssetLib/GenS4/AibFacts/Attributes/Pump.readPumpFacts);
        let* f6     = loadOptional(args.aibTankExport, AssetLib/GenS4/AibFacts/Attributes/Tank.readTankFacts);
        let* f7     = loadOptional(args.aibValveExport, AssetLib/GenS4/AibFacts/Attributes/Valve.readValveFacts);
        let facts   = f1 <+> f2 <+> f3 <+> f4 <+> f5 <+> f6 <+> f7;
        let* _      = AssetLib/GenS4/Rules/Characteristics/Actu.genActu(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Actu.ActuFacts[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Conp.genConp(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Conp.ConpFacts[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Crht.genCrht(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Crht.CrhtFacts[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Emtr.genEmtr(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Emtr.EmtrFacts[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Fans.genFans(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Fans.FansFacts[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Fstn.genFstn(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Fstn.FstnFacts[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Liac.genLiac(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Liac.LiacFacts[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Lisl.genLisl(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Lisl.LislFacts[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Lstn.genLstn(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Lstn.LstnFacts[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Pstn.genPstn(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Pstn.PstnFacts[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Pump.genPump(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Pump.PumpFacts[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Pums.genPums(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Pums.PumsFacts[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Sfer.genSfer(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Sfer.SferFacts[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Sole.genSole(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Sole.SoleFacts[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Star.genStar(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Star.StarFacts[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Tank.genTank(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Tank.TankFacts[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Tstn.genTstn(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Tstn.TstnFacts[r]);
        let* _      = AssetLib/GenS4/Rules/Characteristics/Valv.genValv(workitems, facts as AssetLib/GenS4/Rules/Characteristics/Valv.ValvFacts[r]);
        return()

    def loadOptional(x: Option[XlsxSource], load: XlsxSource -> GenMonad[#{|r1}]): GenMonad[#{|r1}] = 
        use AssetLib/GenS4/GenMonad.{return};
        match x {
            case Some(src) => load(src)
            case None => return(#{})
        }



}
