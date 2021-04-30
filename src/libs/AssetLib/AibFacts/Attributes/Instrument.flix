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


namespace AssetLib/AibFacts/Attributes/Instrument {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;

    use AssetLib/AibFacts/Relations.{AibStringValue, AibIntValue, AibFloatValue};
    use AssetLib/AibFacts/Relations.{getAttributes, getStringValue, getIntValue, getFloatValue};



    /// Read from Aib file...


    pub def readInstrumentData(sheetName: String, 
                                path: System.FilePath): Result[#{AibStringValue, AibFloatValue | r}, String] & Impure =
        AssetLib/AibFacts/Relations.readAibFacts(aibInstrument(), sheetName, path)
        
    


    pub def aibInstrument(): NamedRowEvaluator[#{AibStringValue, AibFloatValue | r}] =
        getAttributes( getRangeMin()
            :: getRangeMax()
            :: getRangeUnit()
            :: getSignalMin()
            :: getSignalMax()
            :: getSignalUnit()
            :: Nil
        )      

    /// Range max	Range min	Range unit	Signal max	Signal min	Signal unit


    pub def getRangeMin(): NamedRowEvaluator[#{AibFloatValue | r}] =
        getFloatValue("Range min", "RANGE_MIN")

    pub def getRangeMax(): NamedRowEvaluator[#{AibFloatValue | r}] =
        getFloatValue("Range max", "RANGE_MAX")

    pub def getRangeUnit(): NamedRowEvaluator[#{AibStringValue | r}] =
        getStringValue("Range unit", "RANGE_UNIT")


    pub def getSignalMin(): NamedRowEvaluator[#{AibFloatValue | r}] =
        getFloatValue("Signal min", "SIGNAL_MIN")

    pub def getSignalMax(): NamedRowEvaluator[#{AibFloatValue | r}] =
        getFloatValue("Signal max", "SIGNAL_MAX")

    pub def getSignalUnit(): NamedRowEvaluator[#{AibStringValue | r}] =
        getStringValue("Signal unit", "SIGNAL_UNIT")

}
