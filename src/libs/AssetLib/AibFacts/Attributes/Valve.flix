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


namespace AssetLib/AibFacts/Attributes/Valve {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;

    use AssetLib/AibFacts/Relations.{AibStringValue, AibFloatValue};
    use AssetLib/AibFacts/Relations.{getAttributes, getStringValue, getFloatValue};



    /// Read from Aib file...


    pub def readValveData(sheetName: String, 
                                path: System.FilePath): Result[#{AibStringValue, AibFloatValue | r}, String] & Impure =
        AssetLib/AibFacts/Relations.readAibFacts(aibValve(), sheetName, path)
        
    


    pub def aibValve(): NamedRowEvaluator[#{AibStringValue, AibFloatValue | r}] =
        getAttributes( getValveType()
            :: getSize()
            :: getSizeUnits()
            :: Nil
        )      


    pub def getValveType(): NamedRowEvaluator[#{AibStringValue | r}] =
        getStringValue("Valve Type", "VALVE_TYPE")

    pub def getSize(): NamedRowEvaluator[#{AibFloatValue | r}] =
        getFloatValue("Size", "SIZE")

    pub def getSizeUnits(): NamedRowEvaluator[#{AibStringValue | r}] =
        getStringValue("Size Units", "SIZE_UNITS")



}
