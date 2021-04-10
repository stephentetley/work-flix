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


namespace AssetLib/AibRel/MemoLines {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;

    

    pub rel MemoText(aibref: String, text: String)

    /// Read from Aib xlsx export file...
    pub def readMemoData(sheetName: String, 
                                path: System.FilePath): Result[#{MemoText| r}, String] & Impure =
        SheetIO/SheetReader.runXlsx(readMemoSheet(sheetName), path)
        

    pub def readMemoSheet(sheetName: String): SheetReader[#{MemoText| r}] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, allNamedRows};         
        let* s1     = getSheetNamed(sheetName);
        let* xs     = allNamedRows(s1, evalRow());
        let relns   = List.foldLeft((ac, x) -> ac <+> x, #{}, xs);
        return(relns)

    /// Expects at least "Memo Line 1" and "Memo Line 2"
    /// A Memo Line is not epected to contain newline.
    ///
    /// Note - this is a genuine use of `optional` as file may not contain column "Memo Line 3" etc.
    /// 
    def evalRow(): NamedRowEvaluator[#{MemoText| r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, map, optional, getContentNamed}; 
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6) -> { 
                let xs = x2 :: x3 :: Option.getWithDefault(x4, "") :: Option.getWithDefault(x5, "") 
                            :: Option.getWithDefault(x5, "") :: Option.getWithDefault(x6, "") :: Nil;
                match List.filter(s1 -> not String.isEmpty(s1) , List.map(String.trim, xs)) { 
                    case Nil => #{}
                    case ys => {let str = String.unlines(ys); #{ MemoText(x1, str). } }
                }
                })
            <&> getContentNamed("Reference")
            <*> getContentNamed("Memo Line 1")
            <*> getContentNamed("Memo Line 2")
            <*> optional(getContentNamed("Memo Line 3"))
            <*> optional(getContentNamed("Memo Line 4"))
            <*> optional(getContentNamed("Memo Line 5"))



}
