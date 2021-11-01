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


namespace AssetLib/GenS4/Rules/Characteristics/Mechanical {

    use SheetIO/Reader.{XlsxSource};

    use AssetLib/S4Lite/Datatypes.{SLEquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String, S4Int, S4Float};
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3, S4DiaphragmMaterial, DiaphragmMaterial, 
        DutyHead, Flow, ImpellerType, PumpLiftingType, RatingPower, SpeedRPM, TypeOfFan, ValveSize};
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{recognizedVoltageUnits, voltageUnits};

    pub def genMechanicalCharacteristics(workitems: #{EquiWorkItem3 | r1}, facts: #{|r2}): GenMonad[Unit] = 
        use AssetLib/GenS4/GenMonad.{flatMap, return};
        let* _ = genComp(workitems, facts as CompSchema[r2]);
        let* _ = genFans(workitems, facts as FansSchema[r2]);
        let* _ = genHsys(workitems, facts as HsysSchema[r2]);
        let* _ = genMixr(workitems, facts as MixrSchema[r2]);
        let* _ = genPump(workitems, facts as PumpSchema[r2]);
        let* _ = genPums(workitems, facts as PumsSchema[r2]);
        let* _ = genScpr(workitems, facts as ScprSchema[r2]);
        let* _ = genScrf(workitems, facts as ScrfSchema[r2]);
        let* _ = genTrut(workitems, facts as TrutSchema[r2]);
        let* _ = genValv(workitems, facts as ValvSchema[r2]);
        return()

    /// # COMP

    pub type alias CompSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, RatingPower, EquiCharacteristic | r1}

    pub def genComp(workitems: #{EquiWorkItem3 | r1}, facts: CompSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as CompSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> compCharacteristics())


    /// Note UNICLASS_CODE / UNICLASS_DESC / LOCATION_ON_SITE already created.
    pub def compCharacteristics(): CompSchema[r1] = #{

        EquiCharacteristic(equiId, s4Class, "COMP_RATED_POWER_KW", 1, S4Float(ans)) :-
            EquiWorkItem3(equiId, "COMP", s4Class),
            RatingPower(equiId, ans, "KILOWATTS").

    }


    /// # FANS

    pub type alias FansSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, SpeedRPM, RatingPower, TypeOfFan, S4FanType, EquiCharacteristic | r1}


    pub def genFans(workitems: #{EquiWorkItem3 | r1}, facts: FansSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as FansSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> fansCharacteristics())

    rel S4FanType(aibType: String, s4Type: String)

    pub def fansCharacteristics(): FansSchema[r1] = #{

        EquiCharacteristic(equiId, s4Class, "FANS_RATED_SPEED_RPM", 1, S4Int(speed)) :- 
            EquiWorkItem3(equiId, "FANS", s4Class),
            SpeedRPM(equiId, speed).

        EquiCharacteristic(equiId, s4Class, "FANS_TYPE", 1, S4String(s4type)) :- 
            EquiWorkItem3(equiId, "FANS", s4Class),
            TypeOfFan(equiId, aibtype),
            S4FanType(aibtype, s4type).
    
        EquiCharacteristic(equiId, s4Class, "FANS_RATED_POWER_KW", 1, S4Float(power)) :- 
            EquiWorkItem3(equiId, "FANS", s4Class),
            RatingPower(equiId, power, "KILOWATTS").
        

        S4FanType("EXTRACTOR FAN", "EXTRACTOR"). 
        S4FanType("FORCED AIR FAN", "FORCED AIR"). 

    }

    /// # HSYS (Haudraulic Power Pack)

    pub type alias HsysSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, RatingPower, SpeedRPM, EquiCharacteristic | r1}

    pub def genHsys(workitems: #{EquiWorkItem3 | r1}, facts: HsysSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as HsysSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> hsysCharacteristics())


    /// Note UNICLASS_CODE / UNICLASS_DESC / LOCATION_ON_SITE already created.
    pub def hsysCharacteristics(): HsysSchema[r1] = #{

        EquiCharacteristic(equiId, s4Class, "HSYS_RATED_VOLTAGE", 1, S4Int(voltage)) :-
            EquiWorkItem3(equiId, "HSYS", s4Class),
            VoltageIn(equiId, voltage, units),
            if recognizedVoltageUnits(units).

        EquiCharacteristic(equiId, s4Class, "HSYS_RATED_VOLTAGE_UNITS", 1, S4String(voltageUnits(units))) :-
            EquiWorkItem3(equiId, "HSYS", s4Class),
            VoltageIn(equiId, _, units),
            if recognizedVoltageUnits(units).

    }

    /// # MIXR

    pub type alias MixrSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, RatingPower, SpeedRPM, EquiCharacteristic | r1}

    pub def genMixr(workitems: #{EquiWorkItem3 | r1}, facts: MixrSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as MixrSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> mixrCharacteristics())


    /// Note UNICLASS_CODE / UNICLASS_DESC / LOCATION_ON_SITE already created.
    pub def mixrCharacteristics(): MixrSchema[r1] = #{

        /// Not generated for static mixer
        EquiCharacteristic(equiId, s4Class, "MIXR_RATED_POWER_KW", 1, S4Float(power)) :- 
            EquiWorkItem3(equiId, "MIXR", s4Class),
            RatingPower(equiId, power, "KILOWATTS"), 
            if s4Class != "MIXRST".

        /// Not generated for static mixer
        EquiCharacteristic(equiId, s4Class, "MIXR_RATED_SPEED_RPM", 1, S4Int(ans)) :-
            EquiWorkItem3(equiId, "MIXR", s4Class),
            SpeedRPM(equiId, ans), 
            if s4Class != "MIXRST".

    }

    /// # PUMP

    pub type alias PumpSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, S4DiaphragmMaterial, DiaphragmMaterial, DutyHead,  Flow, ImpellerType, PumpLiftingType, RatingPower, 
            EquiCharacteristic | r1}

    pub def genPump(workitems: #{EquiWorkItem3 | r1}, facts: PumpSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as PumpSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> pumpCharacteristics())

    pub def pumpCharacteristics(): PumpSchema[r1] = #{
        
        EquiCharacteristic(equiId, s4Class, "PUMP_FLOW_LITRES_PER_SEC", 1, S4Float(flowLitresPerSecond(flow, units))) :- 
            EquiWorkItem3(equiId, "PUMP", s4Class),
            Flow(equiId, flow, units),
            if recognizedFlowUnits(units).

        EquiCharacteristic(equiId, s4Class, "PUMP_INSTALLED_DESIGN_HEAD_M", 1, S4Float(ans)) :-
            EquiWorkItem3(equiId, "PUMP", s4Class),
            DutyHead(equiId, ans, "METRES").

        /// TODO may have to limit pump-classes here...
        EquiCharacteristic(equiId, s4Class, "PUMP_IMPELLER_TYPE", 1, S4String(ans)) :-
            EquiWorkItem3(equiId, "PUMP", s4Class),
            ImpellerType(equiId, ans).

        EquiCharacteristic(equiId, s4Class, "PUMP_DIAPHRAGM_MATERIAL", 1, S4String(s4Name)) :-
            EquiWorkItem3(equiId, "PUMP", s4Class),
            DiaphragmMaterial(equiId, material),
            S4DiaphragmMaterial(material, s4Name).

        EquiCharacteristic(equiId, s4Class, "PUMP_RATED_POWER_KW", 1, S4Float(ans)) :-
            EquiWorkItem3(equiId, "PUMP", s4Class),
            RatingPower(equiId, ans, "KILOWATTS").
    
    
    
        S4DiaphragmMaterial("EPDM", "EPMD").
        
    }


    def recognizedFlowUnits(units: String): Bool = match units { 
        case "LITRE PER HOUR" => true
        case "LITRE PER MINUTE" => true
        case "LITRES PER SECOND" => true
        case _ => false
    }

    
    def flowLitresPerSecond(flow: Float64, units: String): Float64 = match units { 
        case "LITRE PER HOUR" => flow / 3600.0f64
        case "LITRE PER MINUTE" => flow / 60.0f64
        case "LITRES PER SECOND" => flow
        case _ => -1.0f64
    }

    /// # PUMS

    pub type alias PumsSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, DiaphragmMaterial, DutyHead,  Flow, ImpellerType, PumpLiftingType, RatingPower, SpeedRPM, 
            EquiCharacteristic  | r1}

    pub def genPums(workitems: #{EquiWorkItem3 | r1}, facts: PumsSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as PumsSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> pumsCharacteristics())


    pub def pumsCharacteristics(): PumsSchema[r1] = #{

        EquiCharacteristic(equiId, s4Class, "PUMS_FLOW_LITRES_PER_SEC", 1, S4Float(flowLitresPerSecond(flow, units))) :- 
            EquiWorkItem3(equiId, "PUMS", s4Class),
            Flow(equiId, flow, units),
            if recognizedFlowUnits(units).

        EquiCharacteristic(equiId, s4Class, "PUMS_INSTALLED_DESIGN_HEAD_M", 1, S4Float(ans)) :-
            EquiWorkItem3(equiId, "PUMS", s4Class),
            DutyHead(equiId, ans, "METRES").

        /// TODO may have to limit pump-classes here...
        EquiCharacteristic(equiId, s4Class, "PUMS_IMPELLER_TYPE", 1, S4String(ans)) :-
            EquiWorkItem3(equiId, "PUMS", s4Class),
            ImpellerType(equiId, ans).

        EquiCharacteristic(equiId, s4Class, "PUMS_LIFTING_TYPE", 1, S4String(ans)) :-
            EquiWorkItem3(equiId, "PUMS", s4Class),
            PumpLiftingType(equiId, ans).

        EquiCharacteristic(equiId, s4Class, "PUMS_RATED_POWER_KW", 1, S4Float(ans)) :-
            EquiWorkItem3(equiId, "PUMS", s4Class),
            RatingPower(equiId, ans, "KILOWATTS").


        EquiCharacteristic(equiId, s4Class, "PUMS_RATED_SPEED_RPM", 1, S4Int(ans)) :-
            EquiWorkItem3(equiId, "PUMS", s4Class),
            SpeedRPM(equiId, ans).

    }

    /// # TRUT

    pub type alias ScprSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, RatingPower, EquiCharacteristic | r1}


    pub def genScpr(workitems: #{EquiWorkItem3 | r1}, facts: ScprSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as ScprSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> scprCharacteristics())

    pub def scprCharacteristics(): ScprSchema[r1] =  #{
        
        EquiCharacteristic(equiId, s4Class, "SCPR_RATED_POWER_KW", 1, S4Float(power)) :-
            EquiWorkItem3(equiId, "SCPR", s4Class),
            RatingPower(equiId, power, "KILOWATTS").

    }

    /// # SCRF (fine screen)

    pub type alias ScrfSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, Flow, EquiCharacteristic | r1}

    pub def genScrf(workitems: #{EquiWorkItem3 | r1}, facts: ScrfSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as ScrfSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> scrfCharacteristics())


    /// Note UNICLASS_CODE / UNICLASS_DESC / LOCATION_ON_SITE already created.
    pub def scrfCharacteristics(): ScrfSchema[r1] = #{

        /// All fine screens
        EquiCharacteristic(equiId, s4Class, "SCRF_FLOW_LITRES_PER_SEC", 1, S4Float(flowLitresPerSecond(flow, units))) :- 
            EquiWorkItem3(equiId, "SCRF", s4Class),
            Flow(equiId, flow, units),
            if recognizedFlowUnits(units).

    }

    /// # TRUT

    pub type alias TrutSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, RatingPower, EquiCharacteristic | r1}


    pub def genTrut(workitems: #{EquiWorkItem3 | r1}, facts: TrutSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as TrutSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> trutCharacteristics())

    pub def trutCharacteristics(): TrutSchema[r1] =  #{
        
        EquiCharacteristic(equiId, s4Class, "TRUT_RATED_POWER_KW", 1, S4Float(power)) :-
            EquiWorkItem3(equiId, "TRUT", s4Class),
            RatingPower(equiId, power, "KILOWATTS").

    }

    /// # VALV
    
    pub type alias ValvSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, ValveSize, EquiCharacteristic | r1}

    pub def genValv(workitems: #{EquiWorkItem3 | r1}, facts: ValvSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as ValvSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> valvCharacteristics())
        


    pub def valvCharacteristics(): ValvSchema[r1] = #{

        EquiCharacteristic(equiId, s4Class, "VALV_INLET_SIZE_MM", 1, S4Int(sizeMM(size, units))) :- 
            EquiWorkItem3(equiId, "VALV", s4Class),
            ValveSize(equiId, size, units),
            if recognizedSizeUnits(units) and s4Class != "VALVRE".

        EquiCharacteristic(equiId, "VALVRE", "VALV_BORE_DIAMETER_MM", 1, S4Int(sizeMM(size, units))) :- 
            EquiWorkItem3(equiId, "VALV", "VALVRE"),
            ValveSize(equiId, size, units),
            if recognizedSizeUnits(units).

        }

    def recognizedSizeUnits(units: String): Bool = match units { 
        case "MILLIMETRES" => true
        case "INCH" => true
        case _ => false
    }

    def sizeMM(size: Float64, units: String): Int32 = 
        match units { 
            case "MILLIMETRES" => size
            case "INCH" => 25.4f64 * size
            case _ => -1.0f64
        } 
            |> round
            |> Float64.tryToInt32
            |> flip(Option.getWithDefault, 0)

    /// TODO make PR for Flix... with ceil and floor
    def round(x: Float64): Float64 =
        import java.lang.Math:rint(Float64);
        rint(x) as & Pure

}
