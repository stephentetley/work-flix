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


namespace AssetLib/GenS4/AibFacts/Attributes/Valve {

    use SheetIO/Reader.{XlsxSource};
    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;

    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/Base/CommonRelations.{ValveSize};

    /// Read from Aib file...


    pub def readValveFacts(src: XlsxSource): GenMonad[#{ValveSize | r}] =
        AssetLib/GenS4/GenMonad.liftActionResult(_ -> SheetIO/Reader.someNamedRelations(evalValve(), src))
        
    
    def evalValve(): NamedRowEvaluator[#{ValveSize | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, withDefault};
        withDefault(evalValveSize(), #{})
    
    def evalValveSize(): NamedRowEvaluator[#{ValveSize | r}] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFactWithUnits("Size", 
            "Size Units", (x1, x2, x3) -> #{ ValveSize(x1, x2, x3). })

}
