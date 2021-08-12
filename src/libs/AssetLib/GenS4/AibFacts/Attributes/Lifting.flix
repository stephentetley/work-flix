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


namespace AssetLib/GenS4/AibFacts/Attributes/Lifting {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;
    use SheetIO/Reader.{XlsxSource};

    /// Read from Aib file...


    pub def readLiftingData(src: XlsxSource): Result[#{WorkLoad, WorkLoadUnits,
                                                        TestCertNo, YWRef | r}, String] & Impure =
        AssetLib/GenS4/AibFacts/Utils.readAibFacts(aibLifting(), true, src)
        
    


    pub def aibLifting(): NamedRowEvaluator[#{WorkLoad, WorkLoadUnits,
                                            TestCertNo, YWRef | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, withDefault};  
        let* c1 = withDefault(getWorkLoad(), #{});
        let* c2 = withDefault(getWorkLoadUnits(), #{});
        let* c3 = withDefault(getTestCertNo(), #{});
        let* c4 = withDefault(getYWRef(), #{});
        return(c1 <+> c2 <+> c3 <+> c4)

    pub rel WorkLoad(aibref: String, load: Float64)

    def getWorkLoad(): NamedRowEvaluator[#{WorkLoad | r}] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFact2("Work Load", (aibref, ans) -> #{ WorkLoad(aibref, ans). })


    pub rel WorkLoadUnits(aibref: String, units: String)

    def getWorkLoadUnits(): NamedRowEvaluator[#{WorkLoadUnits | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("Work Load Units", (aibref, ans) -> #{ WorkLoadUnits(aibref, ans). })

    pub rel TestCertNo(aibref: String, number: String)

    def getTestCertNo(): NamedRowEvaluator[#{TestCertNo | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("Test Cert No", (aibref, ans) -> #{ TestCertNo(aibref, ans). })

    
    pub rel YWRef(aibref: String, refnum: String)

    pub def getYWRef(): NamedRowEvaluator[#{YWRef | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("YWRef", (aibref, ans) -> #{ YWRef(aibref, ans). })



}
