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

    use AssetLib/AibFacts/Utils.{getStringValuedFact, getIntValuedFact};

    /// Read from Aib file...


    pub def readAgaspData(sheetName: String, 
                          path: System.FilePath): Result[#{ConditionGrade, ConditionGradeReason, 
                                                            LoadingFactor, LoadingFactorReason, 
                                                            PerformanceGrade, PerformanceGradeReason, 
                                                            SurveyYear | r}, String] & Impure =
        AssetLib/AibFacts/Utils.readAibFacts(aibAssetCondition(), true, sheetName, path)

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

    def getConditionGrade(): NamedRowEvaluator[#{ConditionGrade | r}] =
        getStringValuedFact("Condition Grade", (aibref, ans) -> #{ ConditionGrade(aibref, ans). })


    pub rel ConditionGradeReason(aibref: String, reason: String)

    def getConditionGradeReason(): NamedRowEvaluator[#{ConditionGradeReason | r}] =
        getStringValuedFact("Condition Grade Reason", (aibref, ans) -> #{ ConditionGradeReason(aibref, ans). })

    pub rel LoadingFactor(aibref: String, factor: String)

    def getLoadingFactor(): NamedRowEvaluator[#{LoadingFactor | r}] =
        getStringValuedFact("Loading Factor", (aibref, ans) -> #{ LoadingFactor(aibref, ans). })


    pub rel LoadingFactorReason(aibref: String, reason: String)

    def getLoadingFactorReason(): NamedRowEvaluator[#{LoadingFactorReason | r}] =
        getStringValuedFact("Loading Factor Reason", (aibref, ans) -> #{ LoadingFactorReason(aibref, ans). })


    pub rel PerformanceGrade(aibref: String, grade: String)

    def getPerformanceGrade(): NamedRowEvaluator[#{PerformanceGrade | r}] =
        getStringValuedFact("Performance Grade", (aibref, ans) -> #{ PerformanceGrade(aibref, ans). })


    pub rel PerformanceGradeReason(aibref: String, reason: String)

    def getPerformanceGradeReason(): NamedRowEvaluator[#{PerformanceGradeReason | r}] =
        getStringValuedFact("Performance Grade Reason", (aibref, ans) -> #{ PerformanceGradeReason(aibref, ans). })



    pub rel SurveyYear(aibref: String, year: Int32)

    def getSurveyYear(): NamedRowEvaluator[#{SurveyYear | r}] =
        getIntValuedFact("AGASP Survey Year", (aibref, ans) -> #{ SurveyYear(aibref, ans). })



}
