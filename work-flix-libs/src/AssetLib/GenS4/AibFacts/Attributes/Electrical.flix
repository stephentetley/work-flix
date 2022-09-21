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
    use Compatibility.{XlsxSource};

    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/Base/CommonRelations.{CurrentInA, 
        InsulationClass, IPRating, Power, SpeedRPM, VoltageIn};


    /// Read from Aib file...

    pub type alias ElectricalFacts[r: SchemaRow] = 
        #{CurrentInA, InsulationClass, IPRating, Power, SpeedRPM, VoltageIn | r}


    pub def readElectricalFacts(src: XlsxSource): GenMonad[ElectricalFacts[r]] =
        AssetLib/GenS4/GenMonad.liftActionResult(_ -> SheetIO/Reader.someNamedRelations(evalElectrical(), src))        


    def evalElectrical(): NamedRowEvaluator[#{CurrentInA, InsulationClass, 
                                                IPRating, Power, SpeedRPM,
                                                VoltageIn | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, point, withDefault};  
        let* c1 = withDefault(evalCurrentInA(), #{});
        let* c2 = withDefault(evalInsulationClass(), #{});
        let* c3 = withDefault(evalIPRating(), #{});
        let* c4 = withDefault(evalPower(), #{});
        let* c5 = withDefault(evalSpeedRPM(), #{});
        let* c6 = withDefault(evalVoltageIn(), #{});
        point(c1 <+> c2 <+> c3 <+> c4 <+> c5 <+> c6)


    def evalCurrentInA(): NamedRowEvaluator[#{CurrentInA | r}] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFact2("Current In", (x1, x2) -> #{ CurrentInA(x1, x2). })


    def evalInsulationClass(): NamedRowEvaluator[#{InsulationClass | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("Insulation Class", (x1, x2) -> #{ InsulationClass(x1, x2). })

    def evalIPRating(): NamedRowEvaluator[#{IPRating | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("IP Rating", (x1, x2) -> #{ IPRating(x1, x2). })

    def evalPower(): NamedRowEvaluator[#{Power | r}] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFactWithUnits("Power", 
            "Power Units", (x1, x2, x3) -> #{ Power(x1, x2, x3). })

    
    def evalSpeedRPM(): NamedRowEvaluator[#{SpeedRPM | r}] =
        AssetLib/GenS4/AibFacts/Utils.getIntFact2("Speed (RPM)", (x1, x2) -> #{ SpeedRPM(x1, x2). })


    def evalVoltageIn(): NamedRowEvaluator[#{VoltageIn | r}] =
        AssetLib/GenS4/AibFacts/Utils.getIntFactWithUnits("Voltage In", 
            "Voltage In (AC Or DC)", (x1, x2, x3) -> #{ VoltageIn(x1, x2, x3). })




}
