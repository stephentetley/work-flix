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

    use AssetLib/AibRel/HierarchicalRelations.{AibFloc, AibEquipment};
    use AssetLib/S4Rel/Relations.{FlocDatum, FlocCharacteristic, EquiDatum, EquiCharacteristic};
    use ValveReport/Relations.{ValveAttribs, ValveUserData};

    pub def s4Status(x: String): String = match x {
        case "OPERATIONAL" =>  "OPER"
        case "NON-OPERATIONAL" => "NOP"
        case _ => x
    }

    def stringWithDefault(s: String, d: String): String = if (String.isEmpty(s)) d else s


    pub def eqVALV[r](): #{ValveTypeMap3, ValveAttribs, ValveUserData, EquiDatum, EquiCharacteristic, AibEquipment | r} = 
        use AssetLib/Common/Osgb36.{eastingfromOsgb36, northingfromOsgb36};
        #{
            EquiDatum(aibref, 
                            "M",
                            s4Name,
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
                AibEquipment(aibref, aibSite, description, equiType, 
                    installedFrom, manufacturer, model, partNumber, serialNumber, _, pandi, status, _), 
                ValveUserData(aibref, s4Name, suppliedFloc, _).

            EquiCharacteristic(aibref, valvClass, "UNICLASS_CODE", "") :- 
                AibEquipment(aibref, _, _,  equiType, _, _,  _, _, _,  _, _, _,  _),
                ValveAttribs(aibref, valveType, _, _,),
                ValveTypeMap3(equiType, valveType, valvClass).

            EquiCharacteristic(aibref, valvClass, "UNICLASS_DESC", "") :- 
                AibEquipment(aibref, _, _,  equiType, _, _,  _, _, _,  _, _, _,  _),
                ValveAttribs(aibref, valveType, _, _),
                ValveTypeMap3(equiType, valveType, valvClass).

            EquiCharacteristic(aibref, valvClass, "LOCATION_ON_SITE", locationOnSite) :- 
                AibEquipment(aibref, _, _,  equiType, _, _,  _, _, _,  _, _, _,  _),
                ValveAttribs(aibref, valveType, _, locationOnSite),
                ValveTypeMap3(equiType, valveType, valvClass).

            EquiCharacteristic(aibref, valvClass, "VALV_INLET_SIZE_MM", ToString.toString(sizeMM)) :- 
                AibEquipment(aibref, _, _,  equiType, _, _,  _, _, _,  _, _, _,  _),
                ValveAttribs(aibref, valveType, sizeMM, _),
                ValveTypeMap3(equiType, valveType, valvClass).                

            /// EAST_NORTH
            EquiCharacteristic(aibref, "EAST_NORTH", "EASTING", ToString.toString(eastingfromOsgb36(ngr)) ) :- 
                AibEquipment(aibref, _, _,  equiType, _, _,  _, _, _,  ngr, _, _,  _),
                ValveAttribs(aibref, valveType, _, _),
                ValveTypeMap3(equiType, valveType, _).

            EquiCharacteristic(aibref, "EAST_NORTH", "NORTHING", ToString.toString(northingfromOsgb36(ngr)) ) :- 
                AibEquipment(aibref, _, _,  equiType, _, _,  _, _, _,  ngr, _, _,  _),
                ValveAttribs(aibref, valveType, _, _),
                ValveTypeMap3(equiType, valveType, _).

            /// SOLUTION_ID
            EquiCharacteristic(aibref, "SOLUTION_ID", "SOLUTION_ID", solutionnId) :- 
                AibEquipment(aibref, _, _,  equiType, _, _,  _, _, _,  ngr, _, _,  _),
                ValveUserData(aibref, _, _, solutionnId),
                ValveAttribs(aibref, valveType, _, _),
                ValveTypeMap3(equiType, valveType, _).

            /// AIB_REFERENCE
            EquiCharacteristic(aibref, "AIB_REFERENCE", "AI2_AIB_REFERENCE", aibref) :- 
                AibEquipment(aibref, _, _,  equiType, _, _,  _, _, _,  _, _, _,  _),
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _),
                ValveAttribs(aibref, valveType, _, _),
                ValveTypeMap3(equiType, valveType, _).

            EquiCharacteristic(aibref, "AIB_REFERENCE", "S4_AIB_REFERENCE", "") :- 
                AibEquipment(aibref, _, _,  equiType, _, _,  _, _, _,  _, _, _,  _),
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _),
                ValveAttribs(aibref, valveType, _, _),
                ValveTypeMap3(equiType, valveType, _).

            /// TODO "AIB_REFERENCE", "AI2_AIB_REFERENCE" Parent (SAI)


        }

    rel ValveTypeMap3(equiType: String, aibType: String, ans: String)

    pub def valveTypeMap3[r](): #{ValveTypeMap3 | r} = #{
        ValveTypeMap3("EQUIPMENT: NON RETURN VALVE", "",        "VALVNR").
        ValveTypeMap3("EQUIPMENT: ISOLATING VALVES", "Ball",    "VALVBA").
        ValveTypeMap3("EQUIPMENT: ISOLATING VALVES", "Gate",    "VALVGA").
    }

}