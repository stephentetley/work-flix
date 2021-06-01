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


namespace AssetLib/AibFacts/Attributes/AssetCondition {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;

    /// Read from Aib file...


    pub def readAgaspData(sheetName: String, 
                          path: System.FilePath): Result[#{ConditionGrade, ConditionGradeReason, 
                                                            LoadingFactor, LoadingFactorReason, 
                                                            PerformanceGrade, PerformanceGradeReason, 
                                                            SurveyYear | r}, String] & Impure =
        use SheetIO/NamedRowEvaluator.{alt, return};
        AssetLib/AibFacts/Relations.readAibFacts(alt(aibAssetCondition(), return(#{})), sheetName, path)

    pub def aibAssetCondition(): NamedRowEvaluator[#{ConditionGrade, ConditionGradeReason, 
                                                        LoadingFactor, LoadingFactorReason, 
                                                        PerformanceGrade, PerformanceGradeReason, 
                                                        SurveyYear | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, withDefault};  
        let* c1 = withDefault(getConditionGrade(), #{});
        let* c2 = withDefault(getConditionGradeReason(), #{});
        let* c3 = withDefault(getLoadingFactor(), #{});
        let* c4 = withDefault(getLoadingFactorReason(), #{});
        let* c5 = withDefault(getPerformanceGrade(), #{});
        let* c6 = withDefault(getPerformanceGradeReason(), #{});
        let* c7 = withDefault(getSurveyYear(), #{});
        return(c1 <+> c2 <+> c3 <+> c4 <+> c5 <+> c6 <+> c7)

    pub rel ConditionGrade(aibref: String, grade: String)

    pub def getConditionGrade(): NamedRowEvaluator[#{ConditionGrade | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getNonEmptyContentNamed};  
        let* aibref     = getNonEmptyContentNamed("Reference");
        let* ans        = getNonEmptyContentNamed("Condition Grade");
        return(#{ ConditionGrade(aibref, ans). })


    
    pub rel ConditionGradeReason(aibref: String, reason: String)

    pub def getConditionGradeReason(): NamedRowEvaluator[#{ConditionGradeReason | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getNonEmptyContentNamed};  
        let* aibref     = getNonEmptyContentNamed("Reference");
        let* ans        = getNonEmptyContentNamed("Condition Grade Reason");
        return(#{ ConditionGradeReason(aibref, ans). })

    pub rel LoadingFactor(aibref: String, factor: String)

    pub def getLoadingFactor(): NamedRowEvaluator[#{LoadingFactor | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getNonEmptyContentNamed};  
        let* aibref     = getNonEmptyContentNamed("Reference");
        let* ans        = getNonEmptyContentNamed("Loading Factor");
        return(#{ LoadingFactor(aibref, ans). })


    pub rel LoadingFactorReason(aibref: String, reason: String)

    pub def getLoadingFactorReason(): NamedRowEvaluator[#{LoadingFactorReason | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getNonEmptyContentNamed};  
        let* aibref     = getNonEmptyContentNamed("Reference");
        let* ans        = getNonEmptyContentNamed("Loading Factor Reason");
        return(#{ LoadingFactorReason(aibref, ans). })


    pub rel PerformanceGrade(aibref: String, grade: String)

    pub def getPerformanceGrade(): NamedRowEvaluator[#{PerformanceGrade | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getNonEmptyContentNamed};  
        let* aibref     = getNonEmptyContentNamed("Reference");
        let* ans        = getNonEmptyContentNamed("Performance Grade");
        return(#{ PerformanceGrade(aibref, ans). })


    pub rel PerformanceGradeReason(aibref: String, reason: String)

    pub def getPerformanceGradeReason(): NamedRowEvaluator[#{PerformanceGradeReason | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getNonEmptyContentNamed};  
        let* aibref     = getNonEmptyContentNamed("Reference");
        let* ans        = getNonEmptyContentNamed("Performance Grade Reason");
        return(#{ PerformanceGradeReason(aibref, ans). })


    pub rel SurveyYear(aibref: String, year: Int32)

    pub def getSurveyYear(): NamedRowEvaluator[#{SurveyYear | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getNonEmptyContentNamed, getInt32Named};  
        let* aibref     = getNonEmptyContentNamed("Reference");
        let* ans        = getInt32Named("AGASP Survey Year");
        return(#{ SurveyYear(aibref, ans). })


}
