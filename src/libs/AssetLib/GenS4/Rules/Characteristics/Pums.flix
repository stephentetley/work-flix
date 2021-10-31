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


namespace AssetLib/GenS4/Rules/Characteristics/Pums {

    use SheetIO/Reader.{XlsxSource};

    use AssetLib/S4Lite/Datatypes.{SLEquiCharacteristic};
    use AssetLib/GenS4/Base/CommonRelations.{DiaphragmMaterial, 
        DutyHead, Flow, ImpellerType, PumpLiftingType, RatingPower, SpeedRPM};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};
    use AssetLib/S4Lite/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String, S4Float, S4Int};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{iEqual};
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3};
    


    pub type alias PumsSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, DiaphragmMaterial, DutyHead,  Flow, ImpellerType, PumpLiftingType, RatingPower, SpeedRPM, 
            EquiCharacteristic  | r1}

    pub def genPums(workitems: #{EquiWorkItem3 | r1}, facts: PumsSchema[r1]): GenMonad[Unit] =
        let workitems1 = workitems as PumsSchema[r1];
        pums(workitems1 <+> facts)


    pub def pums(input: PumsSchema[r1]): GenMonad[Unit] = 
        let rules = #{
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

        };
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(rules <+> input)


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

}
