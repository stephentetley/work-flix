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


namespace AssetLib/GenS4/Characteristics/AssetCondition {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;

    use AssetLib/GenS4/Aib/HierarchicalRelations.{AibEquipment};
    use AssetLib/GenS4/S4Relations.{EquiDatum, EquiCharacteristic};


    /// Are these better as binary facts?
    /// This would let use represent partially complete AGASP data
    /// without complications like wrapping types with Option


    pub rel ConditionGrade(aibref: String, grade: Int32)
    pub rel ConditionGradeReason(aibref: String, reason: String)
    pub rel PerformanceGrade(aibref: String, grade: Int32)
    pub rel PerformanceGradeReason(aibref: String, reason: String)
    pub rel LoadingFactor(aibref: String, grade: Int32)
    pub rel LoadingFactorReason(aibref: String, reason: String)
    pub rel SurveyYear(aibref: String, year: Int32)



    pub def assetCondition(): #{ConditionGrade, ConditionGradeReason,
                                PerformanceGrade, PerformanceGradeReason,
                                LoadingFactor, LoadingFactorReason,
                                SurveyYear,
                                EquiDatum, EquiCharacteristic | r} = 
        #{
    
            /// ASSET_CONDITION
            EquiCharacteristic(aibref, "ASSET_CONDITION", "CONDITION_GRADE", s4ConditionGrade(grade)) :- 
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _),
                ConditionGrade(aibref, grade).

            EquiCharacteristic(aibref, "ASSET_CONDITION", "CONDITION_GRADE_REASON", String.toUpperCase(reason)) :- 
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _),
                ConditionGradeReason(aibref, reason).

            EquiCharacteristic(aibref, "ASSET_CONDITION", "PERFORMANCE_GRADE", s4PerformanceGrade(grade)) :- 
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _),
                PerformanceGrade(aibref, grade).

            EquiCharacteristic(aibref, "ASSET_CONDITION", "PERFORMANCE_GRADE_REASON", String.toUpperCase(reason)) :- 
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _),
                PerformanceGradeReason(aibref, reason).

            EquiCharacteristic(aibref, "ASSET_CONDITION", "LOADING_FACTOR", s4LoadingFactor(factor)) :- 
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _),
                LoadingFactor(aibref, factor).

            EquiCharacteristic(aibref, "ASSET_CONDITION", "LOADING_FACTOR_REASON", String.toUpperCase(reason)) :- 
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _),
                LoadingFactorReason(aibref, reason).

            EquiCharacteristic(aibref, "ASSET_CONDITION", "SURVEY_DATE", ToString.toString(year)) :- 
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _),
                SurveyYear(aibref, year).
        }

    def decodeConditionGrade(s: String): Option[Int32] = match String.trim(s) { 
        case "1 - Good" => Some(1)
        case "2 - Fair" => Some(2)
        case "3 - Adequate" => Some(3)
        case "4 - Poor" => Some(4)
        case "5 - Awful" => Some(5)
        case _ => None
    }


    def decodeLoadingFactor(s: String): Option[Int32] = match String.trim(s) { 
        case "1 - Significantly Under Loaded" => Some(1)
        case "2 - Under Loaded" => Some(2)
        case "3 - Satisfactory" => Some(3)
        case "4 - Overloaded" => Some(4)
        case "5 - Unacceptable" => Some(5)
        case _ => None
    }

    def decodePerformanceGrade(s: String): Option[Int32] = match String.trim(s) { 
        case "1 - Availability  95%" => Some(1)
        case "2 - Availability  90% - 94%" => Some(2)
        case "3 - Availability  80% - 89%" => Some(3)
        case "4 - Availability  50% - 79%" => Some(4)
        case "5 - Availability  49%" => Some(5)
        case _ => None
    }

    
    pub def s4ConditionGrade(i: Int32): String = match i { 
        case 1 => "1 - GOOD"
        case 2 => "2 - FAIR"
        case 3 => "3 - ADEQUATE"
        case 4 => "4 - POOR"
        case 5 => "5 - AWFUL"
        case _ => ""
    }


    pub def s4LoadingFactor(i: Int32): String = match i { 
        case 1 => "1 - SIGNIFICANTLY UNDER LOADED"
        case 2 => "2 - UNDER LOADED"
        case 3 => "3 - SATISFACTORY"
        case 4 => "4 - OVERLOADED"
        case 5 => "5 - UNACCEPTABLE"
        case _ => ""
    }

    pub def s4PerformanceGrade(i: Int32): String = match i { 
        case 1 => "1 - AVAILABILITY 95%"
        case 2 => "2 - AVAILABILITY 90% - 94%"
        case 3 => "3 - AVAILABILITY 80% - 89%"
        case 4 => "4 - AVAILABILITY 50% - 79%"
        case 5 => "5 - AVAILABILITY 49%"
        case _ => ""
    }


    /// Read from Aib file...


    pub def readAgaspData(sheetName: String, 
                          path: System.FilePath): Result[#{ConditionGrade, ConditionGradeReason, 
                                                            PerformanceGrade, PerformanceGradeReason, 
                                                            LoadingFactor, LoadingFactorReason, SurveyYear| r}, String] & Impure =
        SheetIO/SheetReader.runXlsx(readAgaspSheet(sheetName), path)
        

    pub def readAgaspSheet(sheetName: String): SheetReader[#{ConditionGrade, ConditionGradeReason, 
                                                                PerformanceGrade, PerformanceGradeReason, 
                                                                LoadingFactor, LoadingFactorReason, SurveyYear| r}] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, allNamedRows};         
        let* s1     = getSheetNamed(sheetName);
        let* xs     = allNamedRows(s1, evalRow());
        let relns   = List.foldLeft((ac, x) -> ac <+> x, #{}, xs);
        return(relns)


    def evalRow(): NamedRowEvaluator[#{ConditionGrade, ConditionGradeReason, 
                                        PerformanceGrade, PerformanceGradeReason, 
                                        LoadingFactor, LoadingFactorReason, SurveyYear| r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, map, optional, getContentNamed, getInt32Named}; 
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7, x8) -> { 
                let r1 = makeOptional(i -> #{ ConditionGrade(x1, i). }, x2, #{});
                let r2 = if (String.isEmpty(x3)) #{} else #{ ConditionGradeReason(x1, x3). };
                let r3 = makeOptional(i -> #{ PerformanceGrade(x1, i). }, x4, #{});
                let r4 = if (String.isEmpty(x5)) #{} else #{ PerformanceGradeReason(x1, x5). };
                let r5 = makeOptional(i -> #{ LoadingFactor(x1, i). }, x6, #{});
                let r6 = if (String.isEmpty(x7)) #{} else #{ LoadingFactorReason(x1, x7). };
                let r7 = makeOptional(i -> #{ SurveyYear(x1, i). }, x8, #{});
                r1 <+> r6 <+> r5 <+> r4 <+> r3 <+> r2 <+> r7
                })
            <&> getContentNamed("Reference")
            <*> map(decodeConditionGrade, getContentNamed("Condition Grade"))
            <*> getContentNamed("Condition Grade Reason")
            <*> map(decodePerformanceGrade, getContentNamed("Performance Grade"))
            <*> getContentNamed("Performance Grade Reason")
            <*> map(decodeLoadingFactor, getContentNamed("Loading Factor"))
            <*> getContentNamed("Loading Factor Reason")
            <*> optional(getInt32Named("AGASP Survey Year"))

    def makeOptional(f: a -> reln, x: Option[a], d: reln): reln = match x {
        case Some(x1) => f(x1)
        case None => d
    }    

}
