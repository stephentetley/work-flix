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
        DutyHead, Flow, ImpellerType, PumpLiftingType, RatingPower, ValveSize};
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};

    pub def genMechanicalCharacteristics(workitems: #{EquiWorkItem3 | r1}, facts: #{|r2}): GenMonad[Unit] = 
        use AssetLib/GenS4/GenMonad.{flatMap, return};
        let* _ = genPump(workitems, facts as PumpSchema[r2]);
        let* _ = genValv(workitems, facts as ValvSchema[r2]);
        return()


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
