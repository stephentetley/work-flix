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

    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/Base/CommonRelations.{DiaphragmMaterial, 
        DutyHead, Flow, ImpellerType, PumpLiftingType, RatingPower};

    /// Read from Aib file...
    pub type alias PumpFacts[r: SchemaRow] = 
        #{DutyHead, Flow, ImpellerType, PumpLiftingType, RatingPower | r}

    pub def readPumpFacts(src: XlsxSource): GenMonad[PumpFacts[r]]  =
        AssetLib/GenS4/GenMonad.liftActionResult(_ -> SheetIO/Reader.someNamedRelations(src, evalPump()))
        
    


    pub def evalPump(): NamedRowEvaluator[PumpFacts[r]] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, withDefault};
        let* c1 = withDefault(evalDutyHead(), #{});
        let* c2 = withDefault(evalFlow(), #{});
        let* c3 = withDefault(evalImpellerType(), #{});
        let* c4 = withDefault(evalPumpLiftingType(), #{});
        let* c5 = withDefault(evalRatingPower(), #{});
        return(c1 <+> c2 <+> c3 <+> c4 <+> c5)

    
    /// def evalDiaphragmMaterial(): NamedRowEvaluator[#{DiaphragmMaterial | r}] =
    ///     AssetLib/GenS4/AibFacts/Utils.getStringFact2("Diaphragm Material", (x1, x2) -> #{ DiaphragmMaterial(x1, x2). })


    
    def evalDutyHead(): NamedRowEvaluator[#{DutyHead | r}] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFactWithUnits("Duty Head", 
            "Duty Head Units", (x1, x2, x3) -> #{ DutyHead(x1, x2, x3). })
    
    
    def evalFlow(): NamedRowEvaluator[#{Flow | r}] =        
        AssetLib/GenS4/AibFacts/Utils.getFloatFactWithUnits("Flow", 
            "Flow Units", (x1, x2, x3) -> #{ Flow(x1, x2, x3). })

    
    def evalImpellerType(): NamedRowEvaluator[#{ImpellerType | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("Impeller Type", (x1, x2) -> #{ ImpellerType(x1, x2). })

    
    def evalPumpLiftingType(): NamedRowEvaluator[#{PumpLiftingType | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("Lifting Type", (x1, x2) -> #{ LiftingType(x1, x2). })
 

    def evalRatingPower(): NamedRowEvaluator[#{RatingPower | r}] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFactWithUnits("Rating (Power)", 
            "Rating Units", (x1, x2, x3) -> #{ RatingPower(x1, x2, x3). })
        
}
