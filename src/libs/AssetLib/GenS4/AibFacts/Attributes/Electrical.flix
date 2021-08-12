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


namespace AssetLib/GenS4/AibFacts/Attributes/Electrical {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;
    use SheetIO/Reader.{XlsxSource};

    use AssetLib/GenS4/Base/CommonRelations.{CurrentInA, 
        InsulationClass, IPRating, Power, SpeedRPM, VoltageIn};
    use AssetLib/GenS4/AibFacts/Utils.{getStringFact2, getFloatFact2, getIntFact2};


    /// Read from Aib file...


    pub def readElectricalData(src: XlsxSource): Result[#{CurrentInA, InsulationClass, 
                                                            IPRating, Power, SpeedRPM,
                                                            VoltageIn | r}, String] & Impure =
        AssetLib/GenS4/AibFacts/Utils.readAibFacts(aibElectrical(), true, src)
        


    pub def aibElectrical(): NamedRowEvaluator[#{CurrentInA, InsulationClass, 
                                                IPRating, Power, SpeedRPM,
                                                VoltageIn | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, withDefault};  
        let* c1 = withDefault(evalCurrentInA(), #{});
        let* c2 = withDefault(getInsulationClass(), #{});
        let* c3 = withDefault(getIPRating(), #{});
        let* c4 = withDefault(getPower(), #{});
        let* c5 = withDefault(getSpeedRPM(), #{});
        let* c6 = withDefault(getVoltageIn(), #{});
        return(c1 <+> c2 <+> c3 <+> c4 <+> c5 <+> c6)


    def evalCurrentInA(): NamedRowEvaluator[#{CurrentInA | r}] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFact2("Current In", (x1, x2) -> #{ CurrentInA(x1, x2). })


    def getInsulationClass(): NamedRowEvaluator[#{InsulationClass | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("Insulation Class", (x1, x2) -> #{ InsulationClass(x1, x2). })

    def getIPRating(): NamedRowEvaluator[#{IPRating | r}] =
        getStringFact2("IP Rating", (aibref, ans) -> #{ IPRating(aibref, ans). })



    def getPower(): NamedRowEvaluator[#{Power | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, getNonEmptyContentNamed, getContentNamed, getFloat64Named}; 
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3) ->
            if (not String.isEmpty(x3))
                #{ Power(x1, x2, x3). }
            else #{}
            )
        <&> getNonEmptyContentNamed("Reference")
        <*> getFloat64Named("Power")
        <*> getContentNamed("Power Units")

    
    def getSpeedRPM(): NamedRowEvaluator[#{SpeedRPM | r}] =
        getIntFact2("Speed (RPM)", (aibref, ans) -> #{ SpeedRPM(aibref, ans). })


    def getVoltageIn(): NamedRowEvaluator[#{VoltageIn | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, getNonEmptyContentNamed, getContentNamed, getInt32Named}; 
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3) ->
            if (not String.isEmpty(x3))
                #{ VoltageIn(x1, x2, x3). }
            else #{}
            )
        <&> getNonEmptyContentNamed("Reference")
        <*> getInt32Named("Voltage In")
        <*> getContentNamed("Voltage In (AC Or DC)")


}
