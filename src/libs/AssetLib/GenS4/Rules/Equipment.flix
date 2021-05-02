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

namespace ValveReport/Rules/Equipment {

    use AssetLib/AibFacts/Relations.{AibStringValue, AibFloatValue};
    use AssetLib/AibFacts/HierarchyFacts.{AibEquipment};
    use AssetLib/AibFacts/Attributes/Equipment.{EquipmentAttibutes};
    use AssetLib/GenS4/WorkListRelations.{Phase1EquiItem};
    use AssetLib/GenS4/UxlRelations.{EquiDatum, EquiCharacteristic};
        
    pub rel ValveTypeMap3(equiName: String, valveType: String, s4Class: String)

    pub def equipment(today: Time.LocalDate): #{Phase1EquiItem, EquiDatum, EquiCharacteristic, 
                                                AibEquipment, EquipmentAttibutes, 
                                                AibStringValue, 
                                                ValveTypeMap3 | r} = 
        #{
            
                        
            /// Define the typemap here.
            /// There aren't any modularity benefits to defining it outside 
            /// this block and there is the downside that if defined oustide 
            /// it is easy to forget to instantiate it.
            ///
            ValveTypeMap3("EQPT: PRESSURE REDUCING VALVE (WATER)", "",      "VALVPR").
            ValveTypeMap3("EQUIPMENT: AIR RELIEF VALVE", "",                "VALVAV").
            ValveTypeMap3("EQUIPMENT: ISOLATING VALVES", "Ball",            "VALVBA").
            ValveTypeMap3("EQUIPMENT: ISOLATING VALVES", "Butterfly",       "VALVBP").
            ValveTypeMap3("EQUIPMENT: ISOLATING VALVES", "Knife Gate",      "VALVGA").
            ValveTypeMap3("EQUIPMENT: ISOLATING VALVES", "Wedge Gate",      "VALVGA").
            ValveTypeMap3("EQUIPMENT: MULTI-WAY VALVE", "",                 "VALVMW").
            ValveTypeMap3("EQUIPMENT: NON RETURN VALVE", "",                "VALVNR").
            ValveTypeMap3("EQUIPMENT: RELIEF/SAFETY VALVE", "",             "VALVSF").

            EquiDatum(aibref, 
                        s4Category,
                        String.takeLeft(40, s4Name),
                        today,
                        s4EquiType,
                        weightKg,
                        installedFrom,
                        manufacturer,
                        model,
                        specificModelFrame,
                        s4SerialNumber(serialNumber),
                        suppliedFloc,
                        superEqui,
                        pandiTag,
                        s4Status(status)) :- 
                Phase1EquiItem(aibref, s4Name, suppliedFloc, superEqui, s4Category, s4EquiType, _), 
                AibEquipment(aibref, _, _, installedFrom, manufacturer, model,  _, status, _), 
                EquipmentAttibutes(aibref, pandiTag, specificModelFrame, serialNumber, weightKg).



            EquiCharacteristic(aibref, s4EquiClass, "UNICLASS_CODE", "") :- 
                Phase1EquiItem(aibref, _, _, _, _, "VALV", ""),
                AibEquipment(aibref, _, aibEquiName, _, _, _,  _, _, _), 
                AibStringValue(aibref, "VALVE_TYPE", valveType),
                ValveTypeMap3(aibEquiName, valveType, s4EquiClass).

            EquiCharacteristic(aibref, s4EquiClass, "UNICLASS_CODE", "") :- 
                Phase1EquiItem(aibref, _, _, _, _, s4EquiType, s4EquiClass),
                if s4EquiType != "VALV".

            EquiCharacteristic(aibref, s4EquiClass, "UNICLASS_DESC", "") :- 
                Phase1EquiItem(aibref, _, _, _, _, "VALV", ""),
                AibEquipment(aibref, _, aibEquiName, _, _, _,  _, _, _), 
                AibStringValue(aibref, "VALVE_TYPE", valveType),
                ValveTypeMap3(aibEquiName, valveType, s4EquiClass).

            EquiCharacteristic(aibref, s4EquiClass, "UNICLASS_DESC", "") :-
                Phase1EquiItem(aibref, _, _, _, _, s4EquiType, s4EquiClass),
                if s4EquiType != "VALV".

        }



    def s4Status(x: String): String = match x {
        case "OPERATIONAL" =>  "OPER"
        case "NON-OPERATIONAL" => "NOP"
        case _ => x
    }

    def s4SerialNumber(s: String): String = match s { 
        case "N/A" => "NOT APPLICABLE"
        case s1 if (String.isEmpty(s1)) => "UNKNOWN"
        case s1 => s1
    }


}

