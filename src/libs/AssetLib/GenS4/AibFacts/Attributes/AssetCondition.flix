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


namespace AssetLib/GenS4/AibFacts/Attributes/AssetCondition {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;
    use SheetIO/Reader.{XlsxSource};

    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/Base/CommonRelations.{ConditionGrade, 
        LoadingFactor, PerformanceGrade, SurveyYear};

    /// Read from Aib file...


    pub def readAgaspData(src: XlsxSource): GenMonad[#{ConditionGrade, 
                                                        LoadingFactor, PerformanceGrade,
                                                        SurveyYear | r}] =
        AssetLib/GenS4/GenMonad.liftActionResult(_ -> SheetIO/Reader.someNamedRelations(src, evalAssetConditionFacts()))


    def evalAssetConditionFacts(): NamedRowEvaluator[#{ConditionGrade, 
                                                        LoadingFactor, PerformanceGrade,
                                                        SurveyYear | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, withDefault};  
        let* c1 = withDefault(getConditionGrade(), #{});
        let* c2 = withDefault(getLoadingFactor(), #{});
        let* c3 = withDefault(getPerformanceGrade(), #{});
        let* c4 = withDefault(getSurveyYear(), #{});
        return(c1 <+> c2 <+> c3 <+> c4)


    def getConditionGrade(): NamedRowEvaluator[#{ConditionGrade | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, getNonEmptyContentNamed, getContentNamed}; 
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3) -> Relation.whenNot(String.isEmpty(x2), #{ ConditionGrade(x1, x2, x3). }))
            <&> getNonEmptyContentNamed("Reference")
            <*> getContentNamed("Condition Grade")
            <*> getContentNamed("Condition Grade Reason")

    def getLoadingFactor(): NamedRowEvaluator[#{LoadingFactor | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, getNonEmptyContentNamed, getContentNamed}; 
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3) -> Relation.whenNot(String.isEmpty(x2), #{ LoadingFactor(x1, x2, x3). }))
            <&> getNonEmptyContentNamed("Reference")
            <*> getContentNamed("Loading Factor")
            <*> getContentNamed("Loading Factor Reason")

    def getPerformanceGrade(): NamedRowEvaluator[#{PerformanceGrade | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, getNonEmptyContentNamed, getContentNamed}; 
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3) -> Relation.whenNot(String.isEmpty(x2), #{ PerformanceGrade(x1, x2, x3). }))
            <&> getNonEmptyContentNamed("Reference")
            <*> getContentNamed("Performance Grade")
            <*> getContentNamed("Performance Grade Reason")

    def getSurveyYear(): NamedRowEvaluator[#{SurveyYear | r}] =
        AssetLib/GenS4/AibFacts/Utils.getIntFact2("AGASP Survey Year", (x1, x2) -> #{ SurveyYear(x1, x2). }) 
        
}
