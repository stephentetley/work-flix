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


namespace AssetLib/GenS4/AibFacts/Attributes/Fan {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;
    use SheetIO/Reader.{XlsxSource};

    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/Base/CommonRelations.{SpeedRPM, TypeOfFan, RatingPower};


    /// Read from Aib file...


    type alias FanFacts[r: SchemaRow] = 
        #{SpeedRPM, TypeOfFan, RatingPower | r}

    pub def readFanFacts(src: XlsxSource): GenMonad[FanFacts[r]] =
        AssetLib/GenS4/GenMonad.liftActionResult(_ -> SheetIO/Reader.someNamedRelations(src, evalFan()))
        


    def evalFan(): NamedRowEvaluator[FanFacts[r]] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, withDefault};  
        let* c1 = withDefault(evalSpeedRPM(), #{});
        let* c2 = withDefault(evalTypeOfFan(), #{});
        let* c3 = withDefault(evalRatingPower(), #{});
        return(c1 <+> c2 <+> c3)

    
    def evalSpeedRPM(): NamedRowEvaluator[#{SpeedRPM | r}] =
        AssetLib/GenS4/AibFacts/Utils.getIntFact2("Speed (RPM)", (x1, x2) -> #{ SpeedRPM(x1, x2). })
    
    
    def evalTypeOfFan(): NamedRowEvaluator[#{TypeOfFan | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("Type of Fan", (x1, x2) -> #{ TypeOfFan(x1, x2). })

    def evalRatingPower(): NamedRowEvaluator[#{RatingPower | r}] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFactWithUnits("Rating (Power)", 
            "Rating Units", (x1, x2, x3) -> #{ RatingPower(x1, x2, x3). })

    /// TODO ... other fields
    
    
}
