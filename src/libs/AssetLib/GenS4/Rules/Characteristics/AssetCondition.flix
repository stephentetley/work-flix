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


    use AssetLib/AibFacts/Relations.{AibFactGroup, AibStringValue, AibIntValue};
    use AssetLib/GenS4/WorkListRelations.{Phase1EquiItem, Phase2EquiItem};
    use AssetLib/GenS4/UploadRelations.{ClassEqui, ValuaEquiText, ValuaEquiInt};
    use AssetLib/GenS4/UxlRelations.{EquiDatum, EquiCharacteristic};

    pub def assetCondition(): #{ClassEqui, ValuaEquiText, ValuaEquiInt, 
                                Phase1EquiItem, Phase2EquiItem,
                                AibFactGroup, AibStringValue, AibIntValue | r} = 
        #{

            ClassEqui(equiId, "ASSET_CONDITION", "002") :- 
                Phase2EquiItem(equiId, name, floc,  _, _),
                Phase1EquiItem(aibref, name, floc,  _, _, _,  _),
                AibFactGroup(aibref, "ASSET_CONDITION").

            ValuaEquiText(equiId, "002", "CONDITION_GRADE", s4ConditionGrade(grade), 1) :- 
                Phase2EquiItem(equiId, name, floc,  _, _),
                Phase1EquiItem(aibref, name, floc,  _, _, _,  _),
                AibStringValue(aibref, "CONDITION_GRADE", grade).

            ValuaEquiText(equiId, "002", "CONDITION_GRADE_REASON", String.toUpperCase(reason), 1) :- 
                Phase2EquiItem(equiId, name, description,  _, _),
                Phase1EquiItem(aibref, name, description,  _, _, _,  _),
                AibStringValue(aibref, "CONDITION_GRADE_REASON", reason).

            ValuaEquiText(equiId, "002", "PERFORMANCE_GRADE", s4PerformanceGrade(grade), 1) :-
                Phase2EquiItem(equiId, name, description,  _, _),
                Phase1EquiItem(aibref, name, description,  _, _, _,  _),
                AibStringValue(aibref, "PERFORMANCE_GRADE", grade).

            ValuaEquiText(equiId, "002", "PERFORMANCE_GRADE_REASON", String.toUpperCase(reason), 1) :-
                Phase2EquiItem(equiId, name, description,  _, _),
                Phase1EquiItem(aibref, name, description,  _, _, _,  _),
                AibStringValue(aibref, "PERFORMANCE_GRADE_REASON", reason).

            ValuaEquiText(equiId, "002", "LOADING_FACTOR", s4LoadingFactor(factor), 1) :-
                Phase2EquiItem(equiId, name, description,  _, _),
                Phase1EquiItem(aibref, name, description,  _, _, _,  _),
                AibStringValue(aibref, "LOADING_FACTOR", factor).

            ValuaEquiText(equiId, "002", "LOADING_FACTOR_REASON", String.toUpperCase(reason), 1) :-
                Phase2EquiItem(equiId, name, description,  _, _),
                Phase1EquiItem(aibref, name, description,  _, _, _,  _),
                AibStringValue(aibref, "LOADING_FACTOR_REASON", reason).

            ValuaEquiInt(equiId, "002", "SURVEY_DATE", year, 1) :- 
                Phase2EquiItem(equiId, name, description,  _, _),
                Phase1EquiItem(aibref, name, description,  _, _, _,  _),
                AibIntValue(aibref, "SURVEY_DATE", year).

        }
        

    pub def uxlAssetCondition(): #{AibStringValue, AibIntValue, EquiDatum, EquiCharacteristic | r} = 
        #{
    
            /// ASSET_CONDITION
            EquiCharacteristic(aibref, "ASSET_CONDITION", "CONDITION_GRADE", s4ConditionGrade(grade)) :- 
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _, _, _),
                AibStringValue(aibref, "CONDITION_GRADE", grade).

            EquiCharacteristic(aibref, "ASSET_CONDITION", "CONDITION_GRADE_REASON", String.toUpperCase(reason)) :- 
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _, _, _),
                AibStringValue(aibref, "CONDITION_GRADE_REASON", reason).

            EquiCharacteristic(aibref, "ASSET_CONDITION", "PERFORMANCE_GRADE", s4PerformanceGrade(grade)) :- 
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _, _, _),
                AibStringValue(aibref, "PERFORMANCE_GRADE", grade).

            EquiCharacteristic(aibref, "ASSET_CONDITION", "PERFORMANCE_GRADE_REASON", String.toUpperCase(reason)) :- 
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _, _, _),
                AibStringValue(aibref, "PERFORMANCE_GRADE_REASON", reason).

            EquiCharacteristic(aibref, "ASSET_CONDITION", "LOADING_FACTOR", s4LoadingFactor(factor)) :- 
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _, _, _),
                AibStringValue(aibref, "LOADING_FACTOR", factor).

            EquiCharacteristic(aibref, "ASSET_CONDITION", "LOADING_FACTOR_REASON", String.toUpperCase(reason)) :- 
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _, _, _),
                AibStringValue(aibref, "LOADING_FACTOR_REASON", reason).

            EquiCharacteristic(aibref, "ASSET_CONDITION", "SURVEY_DATE", ToString.toString(year)) :- 
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _, _, _),
                AibIntValue(aibref, "SURVEY_DATE", year).
        }


    /// pub def uploadAssetCondition(): #{ConditionGrade, ConditionGradeReason,
    ///                             PerformanceGrade, PerformanceGradeReason,
    ///                             LoadingFactor, LoadingFactorReason,
    ///                             SurveyYear,
    ///                             EquiDatum, EquiCharacteristic | r} = 
    ///     #{
    
    ///         /// ASSET_CONDITION

    ///         /// Maybe AIB should encode fact names as a String to reduce the number of fact types...
    ///         /// AibStringValue("PLI01991020", "CONDITION_GRADE", "1 - Good").
    ///         /// AibInteger("PLI01991020", "AGASP_SURVEY_YEAR", 2020).

    ///         ClassEqui(equiId, "ASSET_CONDITION", "002", Some(1)) :- 
    ///             CharValuaEqui(equiId, "002", "CONDITION_GRADE", _, _).

    ///         CharValuaEqui(equiId, "002", "CONDITION_GRADE", s4ConditionGrade(grade), 1) :- 
    ///             ChangeRequestItem(equiId, funcloc, description),
    ///             EquiDatum(aibref, _, description,  _, _, _,  _, _, _,  _, funcloc, _,  _, _),
    ///             AibStringValue(aibref, "CONDITION_GRADE", grade).

            
    ///         ClassEqui(equiId, "ASSET_CONDITION", "002", Some(1)) :- 
    ///             CharValuaEqui(equiId, "002", "CONDITION_GRADE_REASON", _, _).

    ///         CharValuaEqui(equiId, "002", "CONDITION_GRADE_REASON", String.toUpperCase(reason), 1) :- 
    ///             ChangeRequestItem(equiId, funcloc, description),
    ///             EquiDatum(aibref, _, description,  _, _, _,  _, _, _,  _, funcloc, _,  _, _),
    ///             AibStringValue(aibref, "CONDITION_GRADE_REASON", reason).

    ///         /// EquiCharacteristic(aibref, "ASSET_CONDITION", "PERFORMANCE_GRADE", s4PerformanceGrade(grade)) :- 
    ///         ///     EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _, _),
    ///         ///     PerformanceGrade(aibref, grade).

    ///         /// EquiCharacteristic(aibref, "ASSET_CONDITION", "PERFORMANCE_GRADE_REASON", String.toUpperCase(reason)) :- 
    ///         ///     EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _, _),
    ///         ///     PerformanceGradeReason(aibref, reason).

    ///         /// EquiCharacteristic(aibref, "ASSET_CONDITION", "LOADING_FACTOR", s4LoadingFactor(factor)) :- 
    ///         ///     EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _, _),
    ///         ///     LoadingFactor(aibref, factor).

    ///         /// EquiCharacteristic(aibref, "ASSET_CONDITION", "LOADING_FACTOR_REASON", String.toUpperCase(reason)) :- 
    ///         ///     EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _, _),
    ///         ///     LoadingFactorReason(aibref, reason).

    ///         /// EquiCharacteristic(aibref, "ASSET_CONDITION", "SURVEY_DATE", ToString.toString(year)) :- 
    ///         ///     EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _, _),
    ///         ///     SurveyYear(aibref, year).
    ///     }


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
