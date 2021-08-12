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


namespace AssetLib/GenS4/AibFacts/Attributes/Instrument {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;
    use SheetIO/Reader.{XlsxSource};
    use AssetLib/GenS4/Base/CommonRelations.{RangeMinMax, SignalMinMax, Transducer};

    /// Read from Aib file...


    pub def readInstrumentData(src: XlsxSource): Result[#{RangeMinMax, SignalMinMax, Transducer | r}, String] & Impure =
        SheetIO/Reader.allNamedRelations(src, evalInstrument())
    

    def evalInstrument(): NamedRowEvaluator[#{RangeMinMax, SignalMinMax, Transducer | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, withDefault};  
        let* c1 = withDefault(evalRangeMinMax(), #{});
        let* c2 = withDefault(evalSignalMinMax(), #{});
        let* c3 = withDefault(evalTransducer(), #{});
        return(c1 <+> c2 <+> c3)


    /// Range max	Range min	Range unit	Signal max	Signal min	Signal unit



    def evalRangeMinMax(): NamedRowEvaluator[#{RangeMinMax | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, getNonEmptyContentNamed, getContentNamed, getFloat64Named}; 
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4) ->
            if (not String.isEmpty(x4))
                #{ RangeMinMax(x1, x2, x3, x4). }
            else #{}
            )
        <&> getNonEmptyContentNamed("Reference")
        <*> getFloat64Named("Range min")
        <*> getFloat64Named("Range max")
        <*> getContentNamed("Range unit")


    def evalSignalMinMax(): NamedRowEvaluator[#{SignalMinMax | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, getNonEmptyContentNamed, getContentNamed, getFloat64Named}; 
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4) ->
            if (not String.isEmpty(x4))
                #{ SignalMinMax(x1, x2, x3, x4). }
            else #{}
            )
        <&> getNonEmptyContentNamed("Reference")
        <*> getFloat64Named("Signal min")
        <*> getFloat64Named("Signal max")
        <*> getContentNamed("Signal unit")


    def evalTransducer(): NamedRowEvaluator[#{Transducer | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, getNonEmptyContentNamed, getContentNamed}; 
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3) ->
            if (not String.isEmpty(x2) or not String.isEmpty(x3))
                #{ Transducer(x1, x2, x3). }
            else #{}
            )
        <&> getNonEmptyContentNamed("Reference")
        <*> getContentNamed("Transducer Type")
        <*> getContentNamed("Transducer Serial No")

}
