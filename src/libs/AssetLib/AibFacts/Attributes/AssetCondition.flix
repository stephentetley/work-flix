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

    use AssetLib/AibFacts/Relations.{AibStringValue, AibIntValue};
    use AssetLib/AibFacts/Relations.{getAttributes, getStringValue, getIntValue};



    /// Read from Aib file...


    pub def readAgaspData(sheetName: String, 
                          path: System.FilePath): Result[#{AibStringValue, AibIntValue | r}, String] & Impure =
        SheetIO/SheetReader.runXlsx(readAgaspSheet(sheetName), path)
        

    pub def readAgaspSheet(sheetName: String): SheetReader[#{AibStringValue, AibIntValue | r}] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, allNamedRows};         
        let* s1     = getSheetNamed(sheetName);
        let* xs     = allNamedRows(s1, aibAssetCondition());
        let relns   = List.foldLeft((ac, x) -> ac <+> x, #{}, xs);
        return(relns)

    pub def aibAssetCondition(): NamedRowEvaluator[#{AibStringValue, AibIntValue | r}] =
        getAttributes( getConditionGrade()
            :: getConditionGradeReason()
            :: getLoadingFactor()
            :: getLoadingFactorReason()
            :: getPerformanceGrade()
            :: getPerformanceGradeReason()
            :: getSurveyYear()
            :: Nil
        )      

    pub def getConditionGrade(): NamedRowEvaluator[#{AibStringValue | r}] =
        getStringValue("Condition Grade", "CONDITION_GRADE")

    pub def getConditionGradeReason(): NamedRowEvaluator[#{AibStringValue | r}] =
        getStringValue("Condition Grade Reason", "CONDITION_GRADE_REASON")

    pub def getLoadingFactor(): NamedRowEvaluator[#{AibStringValue | r}] =
        getStringValue("Loading Factor", "LOADING_FACTOR")

    pub def getLoadingFactorReason(): NamedRowEvaluator[#{AibStringValue | r}] =
        getStringValue("Loading Factor Reason", "LOADING_FACTOR_REASON")

    pub def getPerformanceGrade(): NamedRowEvaluator[#{AibStringValue | r}] =
        getStringValue("Performance Grade", "PERFORMANCE_GRADE")

    pub def getPerformanceGradeReason(): NamedRowEvaluator[#{AibStringValue | r}] =
        getStringValue("Performance Grade Reason", "PERFORMANCE_GRADE_REASON")

    pub def getSurveyYear(): NamedRowEvaluator[#{AibIntValue | r}] =
        getStringValue("AGASP Survey Year", "SURVEY_YEAR")


}
