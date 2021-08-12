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

    use AssetLib/GenS4/AibFacts/Utils.{getStringValuedFact, getFloatValuedFact, getIntValuedFact};


    /// Read from Aib file...


    pub def readElectricalData(src: XlsxSource): Result[#{CurrentIn, InsulationClass, 
                                                                IPRating, Power, PowerUnits, SpeedRPM,
                                                                VoltageIn, VoltageInACOrDC | r}, String] & Impure =
        AssetLib/GenS4/AibFacts/Utils.readAibFacts(aibElectrical(), true, src)
        


    pub def aibElectrical(): NamedRowEvaluator[#{CurrentIn, InsulationClass, 
                                                IPRating, Power, PowerUnits, SpeedRPM,
                                                VoltageIn, VoltageInACOrDC | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, withDefault};  
        let* c1 = withDefault(getCurrentIn(), #{});
        let* c2 = withDefault(getInsulationClass(), #{});
        let* c3 = withDefault(getIPRating(), #{});
        let* c4 = withDefault(getPower(), #{});
        let* c5 = withDefault(getPowerUnits(), #{});
        let* c6 = withDefault(getSpeedRPM(), #{});
        let* c7 = withDefault(getVoltageIn(), #{});
        let* c8 = withDefault(getVoltageInACOrDC(), #{});
        return(c1 <+> c2 <+> c3 <+> c4 <+> c5 <+> c6 <+> c7 <+> c8)

    pub rel CurrentIn(aibref: String, current: Float64)

    def getCurrentIn(): NamedRowEvaluator[#{CurrentIn | r}] =
        getFloatValuedFact("Current In", (aibref, ans) -> #{ CurrentIn(aibref, ans). })
        

    pub rel InsulationClass(aibref: String, insclass: String)

    def getInsulationClass(): NamedRowEvaluator[#{InsulationClass | r}] =
        getStringValuedFact("Insulation Class", (aibref, ans) -> #{ InsulationClass(aibref, ans). })


    pub rel IPRating(aibref: String, insclass: String)

    def getIPRating(): NamedRowEvaluator[#{IPRating | r}] =
        getStringValuedFact("IP Rating", (aibref, ans) -> #{ IPRating(aibref, ans). })


    pub rel Power(aibref: String, power: Float64)

    def getPower(): NamedRowEvaluator[#{Power | r}] =
        getFloatValuedFact("Power", (aibref, ans) -> #{ Power(aibref, ans). })
        

    pub rel PowerUnits(aibref: String, units: String)

    def getPowerUnits(): NamedRowEvaluator[#{PowerUnits | r}] =
        getStringValuedFact("Power Units", (aibref, ans) -> #{ PowerUnits(aibref, ans). })

    
    pub rel SpeedRPM(aibref: String, speed: Int32)

    def getSpeedRPM(): NamedRowEvaluator[#{SpeedRPM | r}] =
        getIntValuedFact("Speed (RPM)", (aibref, ans) -> #{ SpeedRPM(aibref, ans). })


    pub rel VoltageIn(aibref: String, voltage: Int32)

    def getVoltageIn(): NamedRowEvaluator[#{VoltageIn | r}] =
        getIntValuedFact("Voltage In", (aibref, ans) -> #{ VoltageIn(aibref, ans). })


    rel VoltageInACOrDC(aibref: String, voltageACOrDC: String)

    def getVoltageInACOrDC(): NamedRowEvaluator[#{VoltageInACOrDC | r}] =
        getStringValuedFact("Voltage In (AC Or DC)", (aibref, ans) -> #{ VoltageInACOrDC(aibref, ans). })


}
