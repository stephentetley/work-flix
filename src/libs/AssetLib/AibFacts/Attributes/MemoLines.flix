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


namespace AssetLib/AibFacts/Attributes/MemoLines {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;

    use AssetLib/AibFacts/Relations.{getAttributes, getStringValue};



    /// Read from Aib file...

    pub rel AibMemoLine(aibref: String, text: String)

    pub def readMemoLinesData(sheetName: String, 
                                path: System.FilePath): Result[#{AibMemoLine | r}, String] & Impure =
        AssetLib/AibFacts/Utils.readAibFacts(aibMemoLines(), true, sheetName, path)
        
    
    def aibMemoLines(): NamedRowEvaluator[#{AibMemoLine | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, withDefault, getNonEmptyContentNamed, getContentNamed}; 
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6) -> { 
                let xs = x2 :: x3 :: x4 :: x5 :: x6 :: Nil;
                match List.filter(s1 -> not String.isEmpty(s1) , List.map(String.trim, xs)) { 
                    case Nil => #{}
                    case ys => {let str = String.unlines(ys); #{ AibMemoLine(x1, str). } }
                }
            })
            <&> getNonEmptyContentNamed("Reference")
            <*> withDefault(getContentNamed("Memo Line 1"), "")
            <*> withDefault(getContentNamed("Memo Line 2"), "")
            <*> withDefault(getContentNamed("Memo Line 3"), "")
            <*> withDefault(getContentNamed("Memo Line 4"), "")
            <*> withDefault(getContentNamed("Memo Line 5"), "")

}
