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


namespace AssetLib/GenS4/Rules/Characteristics/Pump {

    use AssetLib/AibFacts/Relations.{AibStringValue, AibFloatValue};
    use AssetLib/GenS4/WorkListRelations.{EquiWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String, S4Float};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{iEqual};


    pub def pump(input: #{EquiWorkItem, AibStringValue, 
                            AibFloatValue, EquiCharacteristic | r}): #{EquiCharacteristic | r} = 
        let rules = #{
            EquiCharacteristic(equiId, s4Class, "PUMP_FLOW_LITRES_PER_SEC", 1, S4Float(flowLitresPerSecond(flow, unit))) :- 
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "PUMP", s4Class),
                AibFloatValue(equiId, "FLOW", flow),
                AibStringValue(equiId, "FLOW_UNITS", unit),
                if recognizedFlowUnits(unit).

            EquiCharacteristic(equiId, s4Class, "PUMP_INSTALLED_DESIGN_HEAD_M", 1, S4Float(ans)) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "PUMP", s4Class),
                AibFloatValue(equiId, "DUTY_HEAD", ans),
                AibStringValue(equiId, "DUTY_HEAD_UNITS", "METRES").

            /// TODO may have to limit pump-classes here...
            EquiCharacteristic(equiId, s4Class, "PUMP_IMPELLER_TYPE", 1, S4String(ans)) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "PUMP", s4Class),
                AibStringValue(equiId, "IMPELLER_TYPE", ans).

                
            EquiCharacteristic(equiId, s4Class, "PUMP_DIAPHRAGM_MATERIAL", 1, S4String(diaphragmMaterial(material))) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "PUMP", s4Class),
                AibStringValue(equiId, "DIAPHRAGM_MATERIAL", material),
                if recognizedDiaphragmMaterial(material).

            EquiCharacteristic(equiId, s4Class, "PUMP_RATED_POWER_KW", 1, S4Float(ans)) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "PUMP", s4Class),
                AibFloatValue(equiId, "RATING_POWER", ans),
                AibStringValue(equiId, "RATING_UNITS", "KILOWATTS").
        };
        solve (rules <+> input) project EquiCharacteristic


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

    def recognizedDiaphragmMaterial(s: String): Bool = match s { 
        case "EPDM" => true
        case _ => false
    }

    
    def diaphragmMaterial(s: String): String = match s { 
        case "EPDM" => "EPMD"
        case _ => ""
    }


}
