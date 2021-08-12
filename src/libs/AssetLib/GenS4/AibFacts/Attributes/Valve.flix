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

    use AssetLib/GenS4/Base/CommonRelations.{ValveType, ValveSize};

    /// Read from Aib file...


    pub def readValveData(src: XlsxSource): Result[#{ValveType, ValveSize | r}, String] & Impure =
        SheetIO/Reader.someNamedRelations(src, evalValve())
        
    
    pub def evalValve(): NamedRowEvaluator[#{ValveType, ValveSize | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, withDefault};  
        let* c1 = withDefault(evalValveType(), #{});
        let* c2 = withDefault(evalValveSize(), #{});
        return(c1 <+> c2)    

    

    def evalValveType(): NamedRowEvaluator[#{ValveType | r}] =
        AssetLib/GenS4/AibFacts/Utils.getStringFact2("Valve Type", (x1, x2) -> #{ ValveType(x1, x2). })

    
    
    
    def evalValveSize(): NamedRowEvaluator[#{ValveSize | r}] =
        AssetLib/GenS4/AibFacts/Utils.getFloatFactWithUnits("Size", 
            "Size Units", (x1, x2, x3) -> #{ ValveSize(x1, x2, x3). }, #{})

}
