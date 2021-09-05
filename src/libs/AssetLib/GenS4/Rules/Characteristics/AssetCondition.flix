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

    use AssetLib/S4Lite/Datatypes.{SLEquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String, S4Int};
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3, ConditionGrade, 
        LoadingFactor, PerformanceGrade, SurveyYear};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};


    /// src should be asset condition facts
    pub def genAssetCondition(worklist: List[EquiWorkItem], src: XlsxSource): GenMonad[Unit] =
        use AssetLib/GenS4/GenMonad.{flatMap};
        let workitems   = AssetLib/GenS4/WorkLists.makeEquiWorkItem3(worklist);
        let* facts = AssetLib/GenS4/AibFacts/Attributes/AssetCondition.readAgaspData(src);
        assetCondition(workitems <+> facts)


    pub def assetCondition(input: #{EquiWorkItem3, ConditionGrade, 
                                    LoadingFactor, PerformanceGrade, 
                                    SurveyYear, EquiCharacteristic | r1}): GenMonad[Unit] = 
        let rules = #{

            EquiCharacteristic(equiId, "ASSET_CONDITION", "CONDITION_GRADE", 1, S4String(s4ConditionGrade(grade))) :- 
                EquiWorkItem3(equiId, _, _),
                ConditionGrade(equiId, grade, _).

            EquiCharacteristic(equiId, "ASSET_CONDITION", "CONDITION_GRADE_REASON", 1, S4String(String.toUpperCase(reason))) :- 
                EquiWorkItem3(equiId, _, _),
                ConditionGrade(equiId, _, reason), 
                if not String.isEmpty(reason).

            EquiCharacteristic(equiId, "ASSET_CONDITION", "LOADING_FACTOR", 1, S4String(s4LoadingFactor(factor))) :-
                EquiWorkItem3(equiId, _, _),
                LoadingFactor(equiId, factor, _).

            EquiCharacteristic(equiId, "ASSET_CONDITION", "LOADING_FACTOR_REASON", 1, S4String(String.toUpperCase(reason))) :-
                EquiWorkItem3(equiId, _, _),
                LoadingFactor(equiId, _, reason),
                if not String.isEmpty(reason).

            EquiCharacteristic(equiId, "ASSET_CONDITION", "PERFORMANCE_GRADE", 1, S4String(s4PerformanceGrade(grade))) :-
                EquiWorkItem3(equiId, _, _),
                PerformanceGrade(equiId, grade, _).

            EquiCharacteristic(equiId, "ASSET_CONDITION", "PERFORMANCE_GRADE_REASON", 1, S4String(String.toUpperCase(reason))) :-
                EquiWorkItem3(equiId, _, _),
                PerformanceGrade(equiId, _, reason),
                if not String.isEmpty(reason).

            /// NOTE in Aib this is called "SURVEY_YEAR"
            EquiCharacteristic(equiId, "ASSET_CONDITION", "SURVEY_DATE", 1, S4Int(year)) :- 
                EquiWorkItem3(equiId, _, _),
                SurveyYear(equiId, year).           

        }; 
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(rules <+> input)

    /// TODO should be an enum...
    
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
