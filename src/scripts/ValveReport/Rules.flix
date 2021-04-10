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
    use AssetLib/AibRel/AssetCondition.{ConditionGrade, ConditionGradeReason, 
        PerformanceGrade, PerformanceGradeReason, LoadingFactor, LoadingFactorReason, SurveyYear};
    use AssetLib/S4Rel/Relations.{EquiDatum, EquiCharacteristic};
    use ValveReport/Relations.{ValveAttribs, ValveWorkItem};

    pub def s4Status(x: String): String = match x {
        case "OPERATIONAL" =>  "OPER"
        case "NON-OPERATIONAL" => "NOP"
        case _ => x
    }

    def stringWithDefault(s: String, d: String): String = if (String.isEmpty(s)) d else s


    pub def eqVALV(): #{ValveTypeMap3, 
                        ValveAttribs, ValveWorkItem, 
                        EquiDatum, EquiCharacteristic, AibEquipment | r} = 
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
                AibEquipment(aibref, description, equiType, 
                    installedFrom, manufacturer, model, partNumber, serialNumber, _, pandi, status, _), 
                ValveWorkItem(aibref, s4Name, suppliedFloc).

            EquiCharacteristic(aibref, valvClass, "UNICLASS_CODE", "") :- 
                AibEquipment(aibref, _, equiType,  _, _, _,  _, _, _,  _, _, _),
                ValveAttribs(aibref, valveType, _, _),
                ValveTypeMap3(equiType, valveType, valvClass).

            EquiCharacteristic(aibref, valvClass, "UNICLASS_DESC", "") :- 
                AibEquipment(aibref, _, equiType,  _, _, _,  _, _, _,  _, _, _),
                ValveAttribs(aibref, valveType, _, _),
                ValveTypeMap3(equiType, valveType, valvClass).

            EquiCharacteristic(aibref, valvClass, "LOCATION_ON_SITE", locationOnSite) :- 
                AibEquipment(aibref, _, equiType,  _, _, _,  _, _, _,  _, _, _),
                ValveAttribs(aibref, valveType, _, locationOnSite),
                ValveTypeMap3(equiType, valveType, valvClass).

            EquiCharacteristic(aibref, valvClass, "VALV_INLET_SIZE_MM", getSizeValue(osize)) :- 
                AibEquipment(aibref, _, equiType,  _, _, _,  _, _, _,  _, _, _),
                ValveAttribs(aibref, valveType, osize, _),
                ValveTypeMap3(equiType, valveType, valvClass),
                if not Option.isEmpty(osize).

        }

    def getSizeValue(x: Option[Float64]): String = 
        Option.getWithDefault(Option.map(ToString.toString, x), "")


    rel ValveTypeMap3(equiType: String, aibType: String, ans: String)

    pub def valveTypeMap3(): #{ValveTypeMap3 | r} = #{
        ValveTypeMap3("EQUIPMENT: NON RETURN VALVE", "",        "VALVNR").
        ValveTypeMap3("EQUIPMENT: ISOLATING VALVES", "Ball",    "VALVBA").
        ValveTypeMap3("EQUIPMENT: ISOLATING VALVES", "Gate",    "VALVGA").
    }

    /// The rules below should be "modular" - they use EquiDatum as an existence test to prevent 
    /// firing for all types of equipment not just valves which are made by the above rules.
    /// They will be moved into a separate files (if they fire as expected...)
    
    pub def equiEastNorth(): #{EquiDatum, EquiCharacteristic, AibEquipment | r} =
        use AssetLib/Common/Osgb36.{eastingfromOsgb36, northingfromOsgb36};
        #{
            /// EAST_NORTH (generate if have generated EquiDatum from AibEquipment)
            EquiCharacteristic(aibref, "EAST_NORTH", "EASTING", ToString.toString(eastingfromOsgb36(ngr)) ) :- 
                AibEquipment(aibref, _, equiType,  _, _, _,  _, _, _,  ngr, _, _),
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _).

            EquiCharacteristic(aibref, "EAST_NORTH", "NORTHING", ToString.toString(northingfromOsgb36(ngr)) ) :- 
                AibEquipment(aibref, _, equiType,  _, _, _,  _, _, _,  ngr, _, _),
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _).
        }


    pub def equiSolutionId(solutionId: String): #{EquiDatum, EquiCharacteristic, AibEquipment | r} =
        #{
            /// SOLUTION_ID
            EquiCharacteristic(aibref, "SOLUTION_ID", "SOLUTION_ID", solutionId) :- 
                AibEquipment(aibref, _, equiType,  _, _, _,  _, _, _,  _, _, _),
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _),
                if String.isEmpty(solutionId) == false.
            
        }

    pub def equiAibReference(): #{EquiDatum, EquiCharacteristic, AibEquipment | r} =
        #{
            /// AIB_REFERENCE (item)
            EquiCharacteristic(aibref, "AIB_REFERENCE", "AI2_AIB_REFERENCE", aibref) :- 
                AibEquipment(aibref, _, _,  _, _, _,  _, _, _,  _, _, _),
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _).

            /// AI2_AIB_REFERENCE (parent)
            EquiCharacteristic(aibref, "AIB_REFERENCE", "AI2_AIB_REFERENCE", parent) :- 
                AibEquipment(aibref, _, _,  _, _, _,  _, _, _,  _, _, parent),
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _).

            /// S4_AIB_REFERENCE (blank)
            EquiCharacteristic(aibref, "AIB_REFERENCE", "S4_AIB_REFERENCE", "") :- 
                AibEquipment(aibref, _, equiType,  _, _, _,  _, _, _,  _, _, _),
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _).
        }

    pub def assetCondition(): #{ConditionGrade, ConditionGradeReason,
                                PerformanceGrade, PerformanceGradeReason,
                                LoadingFactor, LoadingFactorReason,
                                SurveyYear,
                                EquiDatum, EquiCharacteristic, AibEquipment | r} = 
        use AssetLib/AibRel/AssetCondition.{s4ConditionGrade, s4PerformanceGrade, s4LoadingFactor};
        #{
    
            /// ASSET_CONDITION
            EquiCharacteristic(aibref, "ASSET_CONDITION", "CONDITION_GRADE", s4ConditionGrade(grade)) :- 
                AibEquipment(aibref, _, equiType,  _, _, _,  _, _, _,  _, _, _),
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _),
                ConditionGrade(aibref, grade).

            EquiCharacteristic(aibref, "ASSET_CONDITION", "CONDITION_GRADE_REASON", String.toUpperCase(reason)) :- 
                AibEquipment(aibref, _, equiType,  _, _, _,  _, _, _,  _, _, _),
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _),
                ConditionGradeReason(aibref, reason).

            EquiCharacteristic(aibref, "ASSET_CONDITION", "PERFORMANCE_GRADE", s4PerformanceGrade(grade)) :- 
                AibEquipment(aibref, _, equiType,  _, _, _,  _, _, _,  _, _, _),
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _),
                PerformanceGrade(aibref, grade).

            EquiCharacteristic(aibref, "ASSET_CONDITION", "PERFORMANCE_GRADE_REASON", String.toUpperCase(reason)) :- 
                AibEquipment(aibref, _, equiType,  _, _, _,  _, _, _,  _, _, _),
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _),
                PerformanceGradeReason(aibref, reason).

            EquiCharacteristic(aibref, "ASSET_CONDITION", "LOADING_FACTOR", s4LoadingFactor(factor)) :- 
                AibEquipment(aibref, _, equiType,  _, _, _,  _, _, _,  _, _, _),
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _),
                LoadingFactor(aibref, factor).

            EquiCharacteristic(aibref, "ASSET_CONDITION", "LOADING_FACTOR_REASON", String.toUpperCase(reason)) :- 
                AibEquipment(aibref, _, equiType,  _, _, _,  _, _, _,  _, _, _),
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _),
                LoadingFactorReason(aibref, reason).

            EquiCharacteristic(aibref, "ASSET_CONDITION", "SURVEY_DATE", ToString.toString(year)) :- 
                AibEquipment(aibref, _, equiType,  _, _, _,  _, _, _,  _, _, _),
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _),
                SurveyYear(aibref, year).
        }



}