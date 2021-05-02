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

namespace ValveReport/Equipment {

    use AssetLib/AibFacts/Relations.{AibStringValue, AibFloatValue};
    use AssetLib/AibFacts/HierarchyFacts.{AibFloc, AibEquipment};
    use AssetLib/GenS4/UxlRelations.{EquiDatum, EquiCharacteristic};
    use AssetLib/GenS4/Characteristics/AssetCondition.{ConditionGrade, ConditionGradeReason, 
        PerformanceGrade, PerformanceGradeReason, LoadingFactor, LoadingFactorReason, SurveyYear};
        
    use ValveReport/Relations.{ValveWorkItem};

    pub def s4Status(x: String): String = match x {
        case "OPERATIONAL" =>  "OPER"
        case "NON-OPERATIONAL" => "NOP"
        case _ => x
    }

    def s4SerialNumber(s: String): String = match s { 
        case "N/A" => "NOT APPLICABLE"
        case s1 if (String.isEmpty(s1)) => "UNKNOWN"
        case s1 => s1
    }





    pub def equipment(today: Time.LocalDate): #{ValveWorkItem, EquiDatum, EquiCharacteristic, AibEquipment | r} = 
        let noneF64: Option[Float64] = None;
        #{
            EquiDatum(aibref, 
                        s4Category,
                        String.takeLeft(40, s4Name),
                        today,
                        s4EquiType,
                        noneF64,
                        installedFrom,
                        manufacturer,
                        model,
                        partNumber,
                        s4SerialNumber(serialNumber),
                        suppliedFloc,
                        superEqui,
                        pandi,
                        s4Status(status)) :- 
                AibEquipment(aibref, description, equiType,
                    installedFrom, manufacturer, model, partNumber, serialNumber, _, pandi, status, _), 
                ValveWorkItem(aibref, s4Name, suppliedFloc, superEqui, s4Category, s4EquiType, s4EquiClass).


            EquiCharacteristic(aibref, s4EquiClass, "UNICLASS_CODE", "") :- 
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _, _, _),
                ValveWorkItem(aibref, _, _, _, _, s4EquiType, s4EquiClass).

            EquiCharacteristic(aibref, s4EquiClass, "UNICLASS_DESC", "") :- 
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _, _, _),
                ValveWorkItem(aibref, _, _, _, _, s4EquiType, s4EquiClass).


        }

            /// /// Define the typemap here.
            /// /// There aren't any modularity benefits to defining it outside 
            /// /// this block and there is the downside that if defined oustide 
            /// /// it is easy to forget to instantiate it.
            /// ///
            /// ValveTypeMap3("EQPT: PRESSURE REDUCING VALVE (WATER)", "",      "VALVPR").
            /// ValveTypeMap3("EQUIPMENT: AIR RELIEF VALVE", "",                "VALVAV").
            /// ValveTypeMap3("EQUIPMENT: ISOLATING VALVES", "Ball",            "VALVBA").
            /// ValveTypeMap3("EQUIPMENT: ISOLATING VALVES", "Butterfly",       "VALVBP").
            /// ValveTypeMap3("EQUIPMENT: ISOLATING VALVES", "Knife Gate",      "VALVGA").
            /// ValveTypeMap3("EQUIPMENT: ISOLATING VALVES", "Wedge Gate",      "VALVGA").
            /// ValveTypeMap3("EQUIPMENT: MULTI-WAY VALVE", "",                 "VALVMW").
            /// ValveTypeMap3("EQUIPMENT: NON RETURN VALVE", "",                "VALVNR").
            /// ValveTypeMap3("EQUIPMENT: RELIEF/SAFETY VALVE", "",             "VALVSF").

}

