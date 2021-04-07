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


namespace AssetLib/AibRel/AssetCondition {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;

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

    /// Read from Aib file...


    pub def readAgaspFile[r](sheetName: String, 
                                path: System.FilePath): Result[#{ConditionGrade, ConditionGradeReason, 
                                                                PerformanceGrade, PerformanceGradeReason, 
                                                                LoadingFactor, LoadingFactorReason, SurveyYear| r}, String] & Impure =
        SheetIO/SheetReader.runXlsx(readAgaspSheet(sheetName), path)
        

    pub def readAgaspSheet[r](sheetName: String): SheetReader[#{ConditionGrade, ConditionGradeReason, 
                                                                PerformanceGrade, PerformanceGradeReason, 
                                                                LoadingFactor, LoadingFactorReason, SurveyYear| r}] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, allNamedRows};         
        let* s1     = getSheetNamed(sheetName);
        let* xs     = allNamedRows(s1, evalRow());
        let relns   = List.foldLeft((ac, x) -> ac <+> x, #{}, xs);
        return(relns)


    def evalRow[r](): NamedRowEvaluator[#{ConditionGrade, ConditionGradeReason, 
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
        

    def decodeConditionGrade(s: String): Option[Int32] = match String.trim(s) { 
        case "1 - Good" => Some(1)
        case _ => None
    }


    def decodeLoadingFactor(s: String): Option[Int32] = match String.trim(s) { 
        case "3 - Satisfactory" => Some(1)
        case _ => None
    }

    def decodePerformanceGrade(s: String): Option[Int32] = match String.trim(s) { 
        case "1 - Availability  95%" => Some(1)
        case _ => None
    }

}
