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


namespace AssetLib/GenS4/AibFacts/Attributes/Vessel {

    use Compatibility.{XlsxSource};
    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;

    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/Base/CommonRelations.{BarLitres, PVCapacityLitres, PVVerificationStatus, 
        PVVerificationStatusDate, SwpOrSol, 
        TestCertNo, TestPressureBars, WrittenSchemeNumber, YWRef};

    /// Read from Aib file...

    pub type alias VesselFacts[r: SchemaRow] = 
        #{BarLitres, PVCapacityLitres, PVVerificationStatus, SwpOrSol,
            TestCertNo, TestPressureBars, WrittenSchemeNumber, YWRef | r}

    pub def readVesselFacts(src: XlsxSource): GenMonad[VesselFacts[r1]] =
        AssetLib/GenS4/GenMonad.liftActionResult(_ -> SheetIO/Reader.someNamedRelations(evalVessel(), src))
        
    
    def evalVessel(): NamedRowEvaluator[VesselFacts[r1]] =
        use SheetIO/NamedRowEvaluator.{flatMap, point, withDefault};
        let* c1 = withDefault(evalBarLitres(), #{});
        let* c2 = withDefault(evalPVCapacityLitres(), #{});
        let* c3 = withDefault(evalPVVerificationStatus(), #{});
        let* c4 = withDefault(evalPVVerificationStatusDate(), #{});
        let* c5 = withDefault(evalSwpOrSol(), #{});
        let* c20 = withDefault(evalTestCertNo(), #{});
        let* c21 = withDefault(evalTestPressureBars(), #{});
        let* c22 = withDefault(evalWrittenSchemeNumber(), #{});
        let* c23 = withDefault(evalYWRef(), #{});
        point(c1 <+> c2 <+> c3 <+> c4 <+> c5 <+> c20 <+> c21 <+> c22 <+> c23)
    
    /// Bar Litres	P.V.Capacity Ltrs	PV Verification Status	PV Verification Status Date	S.W.P or S.O.L.	S.W.P or S.O.L. Units	
    /// Safe Working Procedure Date	Safe Working Procedure Name	Safe Working Procedure Type - Location


    def evalBarLitres(): NamedRowEvaluator[#{BarLitres | r}] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFact2("Bar Litres", (aibref, ans) -> #{ BarLitres(aibref, ans). })

    def evalPVCapacityLitres(): NamedRowEvaluator[#{PVCapacityLitres | r}] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFact2("P.V.Capacity Ltrs", (aibref, ans) -> #{ PVCapacityLitres(aibref, ans). })

    def evalPVVerificationStatus(): NamedRowEvaluator[#{PVVerificationStatus | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("PV Verification Status", (aibref, ans) -> #{ PVVerificationStatus(aibref, ans). })

    // PV Verification Status Date  
    def evalPVVerificationStatusDate(): NamedRowEvaluator[#{PVVerificationStatusDate | r}] =
        AssetLib/GenS4/AibFacts/Utils.getMdyDateFact2("PV Verification Status Date", (aibref, ans) -> #{ PVVerificationStatusDate(aibref, ans). })


    def evalSwpOrSol(): NamedRowEvaluator[#{SwpOrSol | r}] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFactWithUnits("S.W.P or S.O.L.", 
            "S.W.P or S.O.L. Units", (x1, x2, x3) -> #{ SwpOrSol(x1, x2, x3). })

    /// Test Cert No	Test Pressure bars	Written Scheme No	YWRef


    def evalTestCertNo(): NamedRowEvaluator[#{TestCertNo | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("Test Cert No", (aibref, ans) -> #{ TestCertNo(aibref, ans). })

    def evalTestPressureBars(): NamedRowEvaluator[#{TestPressureBars | r}] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFact2("Test Pressure bars", (aibref, ans) -> #{ TestPressureBars(aibref, ans). })
    
    def evalWrittenSchemeNumber(): NamedRowEvaluator[#{WrittenSchemeNumber | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("Written Scheme No", (aibref, ans) -> #{ WrittenSchemeNumber(aibref, ans). })

    def evalYWRef(): NamedRowEvaluator[#{YWRef | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("YWRef", (aibref, ans) -> #{ YWRef(aibref, ans). })


}
