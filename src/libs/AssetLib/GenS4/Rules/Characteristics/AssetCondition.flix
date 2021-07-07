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

    use SheetIO/Reader.{XlsxSource};

    use AssetLib/AibFacts/Attributes/AssetCondition.{ConditionGrade, ConditionGradeReason, 
        LoadingFactor, LoadingFactorReason, PerformanceGrade, PerformanceGradeReason, 
        SurveyYear};
    use AssetLib/S4Lite/Datatypes.{SLEquiCharacteristic};
    use AssetLib/GenS4/WorkLists.{EquipmentWorkItem, EquiWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String, S4Int};
    


    /// src should be asset condition facts
    pub def genAssetCondition(worklist: List[EquipmentWorkItem], src: XlsxSource): Result[Chain[SLEquiCharacteristic], String] & Impure =
        use Result.{flatMap};
        let workitems   = AssetLib/GenS4/WorkLists.makeEquiWorkItems(worklist);
        let* facts = AssetLib/AibFacts/Attributes/AssetCondition.readAgaspData(src);
        let ans = assetCondition(workitems <+> facts) |> AssetLib/GenS4/S4LiteRelations.toSLEquiCharacteristic;
        Ok(ans) 

    pub def assetCondition(input: #{EquiWorkItem, ConditionGrade, ConditionGradeReason, 
                                    LoadingFactor, LoadingFactorReason, 
                                    PerformanceGrade, PerformanceGradeReason, 
                                    SurveyYear, EquiCharacteristic | r1}): #{EquiCharacteristic | r} = 
        let rules = #{

            EquiCharacteristic(equiId, "ASSET_CONDITION", "CONDITION_GRADE", 1, S4String(s4ConditionGrade(grade))) :- 
                EquiWorkItem(equiId, _, _,  _, _, _,  _, _, _),
                ConditionGrade(equiId, grade).

            EquiCharacteristic(equiId, "ASSET_CONDITION", "CONDITION_GRADE_REASON", 1, S4String(String.toUpperCase(reason))) :- 
                EquiWorkItem(equiId, _, _,  _, _, _,  _, _, _),
                ConditionGradeReason(equiId, reason).

            EquiCharacteristic(equiId, "ASSET_CONDITION", "LOADING_FACTOR", 1, S4String(s4LoadingFactor(factor))) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, _, _),
                LoadingFactor(equiId, factor).

            EquiCharacteristic(equiId, "ASSET_CONDITION", "LOADING_FACTOR_REASON", 1, S4String(String.toUpperCase(reason))) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, _, _),
                LoadingFactorReason(equiId, reason).

            EquiCharacteristic(equiId, "ASSET_CONDITION", "PERFORMANCE_GRADE", 1, S4String(s4PerformanceGrade(grade))) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, _, _),
                PerformanceGrade(equiId, grade).

            EquiCharacteristic(equiId, "ASSET_CONDITION", "PERFORMANCE_GRADE_REASON", 1, S4String(String.toUpperCase(reason))) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, _, _),
                PerformanceGradeReason(equiId, reason).

            /// NOTE in Aib this is called "SURVEY_YEAR"
            EquiCharacteristic(equiId, "ASSET_CONDITION", "SURVEY_DATE", 1, S4Int(year)) :- 
                EquiWorkItem(equiId, _, _,  _, _, _,  _, _, _),
                SurveyYear(equiId, year).           

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
