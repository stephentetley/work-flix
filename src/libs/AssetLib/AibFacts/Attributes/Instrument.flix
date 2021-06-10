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

    use AssetLib/AibFacts/Utils.{getStringValuedFact, getFloatValuedFact, getIntValuedFact};



    /// Read from Aib file...


    pub def readInstrumentData(sheetName: String, 
                                path: System.FilePath): Result[#{RangeMin, RangeMax, RangeUnit,
                                                                SignalMin, SignalMax, SignalUnit, 
                                                                TransducerType, TransducerSerialNumber | r}, String] & Impure =
        AssetLib/AibFacts/Utils.readAibFacts(aibInstrument(), true, sheetName, path)
        
    


    pub def aibInstrument(): NamedRowEvaluator[#{RangeMin, RangeMax, RangeUnit,
                                                SignalMin, SignalMax, SignalUnit, 
                                                TransducerType, TransducerSerialNumber | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, withDefault};  
        let* c1 = withDefault(getRangeMin(), #{});
        let* c2 = withDefault(getRangeMax(), #{});
        let* c3 = withDefault(getRangeUnit(), #{});
        let* c4 = withDefault(getSignalMin(), #{});
        let* c5 = withDefault(getSignalMax(), #{});
        let* c6 = withDefault(getSignalUnit(), #{});
        let* c7 = withDefault(getTransducerType(), #{});
        let* c8 = withDefault(getTransducerSerialNumber(), #{});
        return(c1 <+> c2 <+> c3 <+> c4 <+> c5 <+> c6 <+> c7 <+> c8)


    /// Range max	Range min	Range unit	Signal max	Signal min	Signal unit

    pub rel RangeMin(aibref: String, rmin: Float64)

    def getRangeMin(): NamedRowEvaluator[#{RangeMin | r}] =
        getFloatValuedFact("Range min", (aibref, ans) -> #{ RangeMin(aibref, ans). })


    pub rel RangeMax(aibref: String, rmax: Float64)

    def getRangeMax(): NamedRowEvaluator[#{RangeMax | r}] =
        getFloatValuedFact("Range max", (aibref, ans) -> #{ RangeMax(aibref, ans). })


    pub rel RangeUnit(aibref: String, units: String)

    def getRangeUnit(): NamedRowEvaluator[#{RangeUnit | r}] =
        getStringValuedFact("Range unit", (aibref, ans) -> #{ RangeUnit(aibref, ans). })

    pub rel SignalMin(aibref: String, smin: Float64)

    def getSignalMin(): NamedRowEvaluator[#{SignalMin | r}] =
        getFloatValuedFact("Signal min", (aibref, ans) -> #{ SignalMin(aibref, ans). })


    pub rel SignalMax(aibref: String, smax: Float64)

    def getSignalMax(): NamedRowEvaluator[#{SignalMax | r}] =
        getFloatValuedFact("Signal max", (aibref, ans) -> #{ SignalMax(aibref, ans). })


    pub rel SignalUnit(aibref: String, units: String)

    def getSignalUnit(): NamedRowEvaluator[#{SignalUnit | r}] =
        getStringValuedFact("Signal unit", (aibref, ans) -> #{ SignalUnit(aibref, ans). })


    pub rel TransducerType(aibref: String, model: String)

    def getTransducerType(): NamedRowEvaluator[#{TransducerType | r}] =
        getStringValuedFact("Transducer Type", (aibref, ans) -> #{ TransducerType(aibref, ans). })

    pub rel TransducerSerialNumber(aibref: String, serialNum: String)

    def getTransducerSerialNumber(): NamedRowEvaluator[#{TransducerSerialNumber | r}] =
        getStringValuedFact("Transducer Serial No", (aibref, ans) -> #{ TransducerSerialNumber(aibref, ans). })


}
