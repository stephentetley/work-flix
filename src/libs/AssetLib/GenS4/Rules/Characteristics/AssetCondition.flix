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


namespace AssetLib/GenS4/Rules/Characteristics/AssetCondition {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;


    use AssetLib/AibFacts/Relations.{AibStringValue, AibIntValue};
    use AssetLib/GenS4/WorkListRelations.{EquiWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String, S4Int};

    pub def assetCondition(input: #{EquiWorkItem, AibStringValue, 
                                    AibIntValue, EquiCharacteristic | r}): #{EquiCharacteristic | r} = 
        let rules = #{

            EquiCharacteristic(equiId, "ASSET_CONDITION", "CONDITION_GRADE", 1, S4String(s4ConditionGrade(grade))) :- 
                EquiWorkItem(equiId, _, _,  _, _, _,  _, _, _),
                AibStringValue(equiId, "CONDITION_GRADE", grade).

            EquiCharacteristic(equiId, "ASSET_CONDITION", "CONDITION_GRADE_REASON", 1, S4String(String.toUpperCase(reason))) :- 
                EquiWorkItem(equiId, _, _,  _, _, _,  _, _, _),
                AibStringValue(equiId, "CONDITION_GRADE_REASON", reason).

            EquiCharacteristic(equiId, "ASSET_CONDITION", "PERFORMANCE_GRADE", 1, S4String(s4PerformanceGrade(grade))) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, _, _),
                AibStringValue(equiId, "PERFORMANCE_GRADE", grade).

            EquiCharacteristic(equiId, "ASSET_CONDITION", "PERFORMANCE_GRADE_REASON", 1, S4String(String.toUpperCase(reason))) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, _, _),
                AibStringValue(equiId, "PERFORMANCE_GRADE_REASON", reason).

            EquiCharacteristic(equiId, "ASSET_CONDITION", "LOADING_FACTOR", 1, S4String(s4LoadingFactor(factor))) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, _, _),
                AibStringValue(equiId, "LOADING_FACTOR", factor).

            EquiCharacteristic(equiId, "ASSET_CONDITION", "LOADING_FACTOR_REASON", 1, S4String(String.toUpperCase(reason))) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, _, _),
                AibStringValue(equiId, "LOADING_FACTOR_REASON", reason).

            /// NOTE in Aib this is called "SURVEY_YEAR"
            EquiCharacteristic(equiId, "ASSET_CONDITION", "SURVEY_DATE", 1, S4Int(year)) :- 
                EquiWorkItem(equiId, _, _,  _, _, _,  _, _, _),
                AibIntValue(equiId, "SURVEY_YEAR", year).           

        }; 
        solve (rules <+> input) project EquiCharacteristic
        






    def s4ConditionGrade(s: String): String = match String.trim(s) { 
        case "1 - Good"         => "1 - GOOD"
        case "2 - Fair"         => "2 - FAIR"
        case "3 - Adequate"     => "3 - ADEQUATE"
        case "4 - Poor"         => "4 - POOR"
        case "5 - Awful"        => "5 - AWFUL"
        case _ => ""
    }

    def s4LoadingFactor(s: String): String = match String.trim(s) { 
        case "1 - Significantly Under Loaded"   => "1 - SIGNIFICANTLY UNDER LOADED"
        case "2 - Under Loaded"                 => "2 - UNDER LOADED"
        case "3 - Satisfactory"                 => "3 - SATISFACTORY"
        case "4 - Overloaded"                   => "4 - OVERLOADED"
        case "5 - Unacceptable"                 => "5 - UNACCEPTABLE"
        case _ => ""
    }

    def s4PerformanceGrade(s: String): String = match String.trim(s) { 
        case "1 - Availability  95%"        => "1 - AVAILABILITY 95%"
        case "2 - Availability  90% - 94%"  => "2 - AVAILABILITY 90% - 94%"
        case "3 - Availability  80% - 89%"  => "3 - AVAILABILITY 80% - 89%"
        case "4 - Availability  50% - 79%"  => "4 - AVAILABILITY 50% - 79%"
        case "5 - Availability  49%"        => "5 - AVAILABILITY 49%"
        case _ => ""
    }

}
