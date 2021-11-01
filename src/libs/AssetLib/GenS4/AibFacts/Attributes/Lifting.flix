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

    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/Base/CommonRelations.{WorkLoad, TestCertNo, YWRef};

    /// Read from Aib file...

    pub type alias LiftingFacts[r: SchemaRow] = #{WorkLoad, TestCertNo, YWRef | r}


    pub def readLiftingFacts(src: XlsxSource): GenMonad[LiftingFacts[r1]]  =
        AssetLib/GenS4/GenMonad.liftActionResult(_ -> SheetIO/Reader.someNamedRelations(src, evalLifting()))


    def evalLifting(): NamedRowEvaluator[LiftingFacts[r]] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, withDefault};  
        let* c1 = withDefault(evalWorkLoad(), #{});
        let* c2 = withDefault(evalTestCertNo(), #{});
        let* c3 = withDefault(evalYWRef(), #{});
        return(c1 <+> c2 <+> c3)


    def evalWorkLoad(): NamedRowEvaluator[LiftingFacts[r]] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFactWithUnits("Work Load", 
            "Work Load Units", (x1, x2, x3) -> #{ WorkLoad(x1, x2, x3). })


    def evalTestCertNo(): NamedRowEvaluator[#{TestCertNo | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("Test Cert No", (aibref, ans) -> #{ TestCertNo(aibref, ans). })
    
    def evalYWRef(): NamedRowEvaluator[#{YWRef | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("YWRef", (aibref, ans) -> #{ YWRef(aibref, ans). })



}
