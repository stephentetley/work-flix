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


namespace AssetLib/GenS4/AibFacts/Attributes/Pump {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;
    use SheetIO/Reader.{XlsxSource};


    /// Read from Aib file...


    pub def readPumpData(src: XlsxSource): Result[#{DiaphragmMaterial, DutyHead, DutyHeadUnits,
                                                        Flow, FlowUnits, ImpellerType, LiftingType, 
                                                        RatingPower, RatingUnits | r}, String] & Impure =
        AssetLib/GenS4/AibFacts/Utils.readAibFacts(aibPump(), true, src)
        
    


    pub def aibPump(): NamedRowEvaluator[#{DiaphragmMaterial, DutyHead, DutyHeadUnits,
                                            Flow, FlowUnits, ImpellerType, LiftingType, 
                                            RatingPower, RatingUnits | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, withDefault};  
        let* c1 = withDefault(getDiaphragmMaterial(), #{});
        let* c2 = withDefault(getDutyHead(), #{});
        let* c3 = withDefault(getDutyHeadUnits(), #{});
        let* c4 = withDefault(getFlow(), #{});
        let* c5 = withDefault(getFlowUnits(), #{});
        let* c6 = withDefault(getImpellerType(), #{});
        let* c7 = withDefault(getLiftingType(), #{});
        let* c8 = withDefault(getRatingPower(), #{});
        let* c9 = withDefault(getRatingUnits(), #{});
        return(c1 <+> c2 <+> c3 <+> c4 <+> c5 <+> c6 <+> c7 <+> c8 <+> c9)

    pub rel DiaphragmMaterial(aibref: String, material: String)

    def getDiaphragmMaterial(): NamedRowEvaluator[#{DiaphragmMaterial | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("Diaphragm Material", (aibref, ans) -> #{ DiaphragmMaterial(aibref, ans). })


    pub rel DutyHead(aibref: String, size: Float64)

    def getDutyHead(): NamedRowEvaluator[#{DutyHead | r}] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFact2("Duty Head", (aibref, ans) -> #{ DutyHead(aibref, ans). })

    pub rel DutyHeadUnits(aibref: String, units: String)

    def getDutyHeadUnits(): NamedRowEvaluator[#{DutyHeadUnits | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("Duty Head Units", (aibref, ans) -> #{ DutyHeadUnits(aibref, ans). })

    
    pub rel Flow(aibref: String, flow: Float64)

    pub def getFlow(): NamedRowEvaluator[#{Flow | r}] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFact2("Flow", (aibref, ans) -> #{ Flow(aibref, ans). })


    pub rel FlowUnits(aibref: String, units: String)

    pub def getFlowUnits(): NamedRowEvaluator[#{FlowUnits | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("Flow Units", (aibref, ans) -> #{ FlowUnits(aibref, ans). })


    pub rel ImpellerType(aibref: String, impellerType: String)

    pub def getImpellerType(): NamedRowEvaluator[#{ImpellerType | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("Impeller Type", (aibref, ans) -> #{ ImpellerType(aibref, ans). })


    pub rel LiftingType(aibref: String, liftingType: String)

    pub def getLiftingType(): NamedRowEvaluator[#{LiftingType | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("Lifting Type", (aibref, ans) -> #{ LiftingType(aibref, ans). })
 

    pub rel RatingPower(aibref: String, power: Float64)

    pub def getRatingPower(): NamedRowEvaluator[#{RatingPower | r}] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFact2("Rating (Power)", (aibref, ans) -> #{ RatingPower(aibref, ans). })

    
    pub rel RatingUnits(aibref: String, units: String)

    pub def getRatingUnits(): NamedRowEvaluator[#{RatingUnits | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("Rating Units", (aibref, ans) -> #{ RatingUnits(aibref, ans). })

}
