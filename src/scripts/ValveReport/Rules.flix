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

namespace ValveReport/Rules {

    use AssetLib/Translate/Aib/HierarchicalRelations.{AibFloc, AibEquipment};
    use AssetLib/Translate/S4/Relations.{EquiDatum, EquiCharacteristic};
    use AssetLib/Translate/AssetCondition.{ConditionGrade, ConditionGradeReason, 
        PerformanceGrade, PerformanceGradeReason, LoadingFactor, LoadingFactorReason, SurveyYear};
    use ValveReport/Relations.{ValveAttribs, ValveWorkItem};

    pub def s4Status(x: String): String = match x {
        case "OPERATIONAL" =>  "OPER"
        case "NON-OPERATIONAL" => "NOP"
        case _ => x
    }

    def stringWithDefault(s: String, d: String): String = if (String.isEmpty(s)) d else s

    rel ValveTypeMap3(equiType: String, aibType: String, ans: String)



    pub def eqVALV(): #{ValveTypeMap3, 
                        ValveAttribs, ValveWorkItem, 
                        EquiDatum, EquiCharacteristic, AibEquipment | r} = 
        #{
            
            /// Define the typemap here.
            /// There aren't any modularity benefits to defining it outside 
            /// this block and there is the downside that if defined oustide 
            /// it is easy to forget to instntiate it.
            ///
            ValveTypeMap3("EQPT: PRESSURE REDUCING VALVE (WATER)", "",      "VALVPR").
            ValveTypeMap3("EQUIPMENT: ISOLATING VALVES", "Ball",            "VALVBA").
            ValveTypeMap3("EQUIPMENT: ISOLATING VALVES", "Butterfly",       "VALVBP").
            ValveTypeMap3("EQUIPMENT: ISOLATING VALVES", "Knife Gate",      "VALVGA").
            ValveTypeMap3("EQUIPMENT: ISOLATING VALVES", "Wedge Gate",      "VALVGA").
            ValveTypeMap3("EQUIPMENT: NON RETURN VALVE", "",                "VALVNR").
            ValveTypeMap3("EQUIPMENT: RELIEF/SAFETY VALVE", "",             "VALVSF").

            EquiDatum(aibref, 
                            "M",
                            String.takeLeft(40, s4Name),
                            "VALV",
                            installedFrom,
                            manufacturer,
                            model,
                            partNumber,
                            stringWithDefault(serialNumber, "UNKNOWN"),
                            suppliedFloc,
                            "",
                            pandi,
                            s4Status(status)) :- 
                AibEquipment(aibref, description, equiType, 
                    installedFrom, manufacturer, model, partNumber, serialNumber, _, pandi, status, _), 
                ValveWorkItem(aibref, s4Name, suppliedFloc).


            EquiCharacteristic(aibref, valvClass, "UNICLASS_CODE", "") :- 
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _),
                AibEquipment(aibref, _, equiType,  _, _, _,  _, _, _,  _, _, _),
                ValveAttribs(aibref, valveType, _, _),
                ValveTypeMap3(equiType, valveType, valvClass).

            EquiCharacteristic(aibref, valvClass, "UNICLASS_DESC", "") :- 
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _),
                AibEquipment(aibref, _, equiType,  _, _, _,  _, _, _,  _, _, _),
                ValveAttribs(aibref, valveType, _, _),
                ValveTypeMap3(equiType, valveType, valvClass).

            EquiCharacteristic(aibref, valvClass, "LOCATION_ON_SITE", locationOnSite) :- 
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _),
                AibEquipment(aibref, _, equiType,  _, _, _,  _, _, _,  _, _, _),
                ValveAttribs(aibref, valveType, _, locationOnSite),
                ValveTypeMap3(equiType, valveType, valvClass).

            EquiCharacteristic(aibref, valvClass, "VALV_INLET_SIZE_MM", getSizeValue(osize)) :- 
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _),
                AibEquipment(aibref, _, equiType,  _, _, _,  _, _, _,  _, _, _),
                ValveAttribs(aibref, valveType, osize, _),
                ValveTypeMap3(equiType, valveType, valvClass),
                if not Option.isEmpty(osize).

        }

    def getSizeValue(x: Option[Float64]): String = 
        Option.getWithDefault(Option.map(ToString.toString, x), "")


}

