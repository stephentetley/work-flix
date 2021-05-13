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


namespace AssetLib/AibFacts/Attributes/Pump {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;

    use AssetLib/AibFacts/Relations.{AibStringValue, AibFloatValue};
    use AssetLib/AibFacts/Relations.{getAttributes, getStringValue, getFloatValue};



    /// Read from Aib file...


    pub def readPumpData(sheetName: String, 
                                path: System.FilePath): Result[#{AibStringValue, AibFloatValue | r}, String] & Impure =
        AssetLib/AibFacts/Relations.readAibFacts(aibPump(), sheetName, path)
        
    


    pub def aibPump(): NamedRowEvaluator[#{AibStringValue, AibFloatValue | r}] =
        getAttributes( getDutyHead()
            :: getDutyHeadUnits()
            :: getFlow()
            :: getFlowUnits()
            :: getImpellerType()
            :: getLiftingType()
            :: getRatingPower()
            :: getRatingUnits()
            :: Nil
        )      


    pub def getDutyHead(): NamedRowEvaluator[#{AibFloatValue | r}] =
        getFloatValue("Duty Head", "DUTY_HEAD")

    pub def getDutyHeadUnits(): NamedRowEvaluator[#{AibStringValue | r}] =
        getStringValue("Duty Head Units", "DUTY_HEAD_UNITS")

    pub def getFlow(): NamedRowEvaluator[#{AibFloatValue | r}] =
        getFloatValue("Flow", "FLOW")

    pub def getFlowUnits(): NamedRowEvaluator[#{AibStringValue | r}] =
        getStringValue("Flow Units", "FLOW_UNITS")

    pub def getImpellerType(): NamedRowEvaluator[#{AibStringValue | r}] =
        getStringValue("Impeller Type", "IMPELLER_TYPE")

    pub def getLiftingType(): NamedRowEvaluator[#{AibStringValue | r}] =
        getStringValue("Lifting Type", "LIFTING_TYPE")
 
    pub def getRatingPower(): NamedRowEvaluator[#{AibFloatValue | r}] =
        getFloatValue("Rating (Power)", "RATING_POWER")

    pub def getRatingUnits(): NamedRowEvaluator[#{AibStringValue | r}] =
        getStringValue("Rating Units", "RATING_UNITS")
}
