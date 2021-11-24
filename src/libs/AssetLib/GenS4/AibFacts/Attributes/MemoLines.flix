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


namespace AssetLib/GenS4/AibFacts/Attributes/MemoLines {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;
    use SheetIO/Reader.{XlsxSource};

    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/Base/CommonRelations.{AibMemoLine};



    /// Read from Aib file...

    pub def readMemoLinesData(src: XlsxSource): GenMonad[#{AibMemoLine | r}] =
        AssetLib/GenS4/GenMonad.liftActionResult(_ -> SheetIO/Reader.someNamedRelations(evalAibMemoLine(), src))
        
    
    def evalAibMemoLine(): NamedRowEvaluator[#{AibMemoLine | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, withDefault, getNonEmptyContentNamed, getContentNamed}; 
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6) -> { 
                let xs = x2 :: x3 :: x4 :: x5 :: x6 :: Nil;
                match List.filter(s1 -> not String.isEmpty(s1) , List.map(String.trim, xs)) { 
                    case Nil => #{}
                    case ys => {let str = String.unlines(ys); #{ AibMemoLine(x1; Set.singleton(str)). } }
                }
            })
            <&> getNonEmptyContentNamed("Reference")
            <*> withDefault(getContentNamed("Memo Line 1"), "")
            <*> withDefault(getContentNamed("Memo Line 2"), "")
            <*> withDefault(getContentNamed("Memo Line 3"), "")
            <*> withDefault(getContentNamed("Memo Line 4"), "")
            <*> withDefault(getContentNamed("Memo Line 5"), "")

}
