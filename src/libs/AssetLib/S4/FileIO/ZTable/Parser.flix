/*
 * Copyright 2020 Stephen Tetley
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



namespace AssetLib/S4/FileIO/ZTable/Parser {


    use Data/Transient.DList;
    use TextParser.TextParser;

    use AssetLib/S4/FileIO/ZTable.RowEvaluator;

    /// Note - parser may loop rather than fail if given wrong ztable input source for the RowEvaluator, needs investigating...

    pub def importRows(eval: RowEvaluator[row], path: System.FilePath): Result[List[row], String] & Impure = 
        use Result.flatMap;
        use Data/Transient/DList.{toList};
        let* rows = TextParser.parsesFile(importRowsParser(eval), path, Text/Charset.utf_8());
        Ok(toList(rows))


    def importRowsParser(eval: RowEvaluator[row]): TextParser[DList[row], t] = 
        use Data/Transient/DList.{empty, snoc};
        use TextParser.{flatMap, return};
        use TextParser/Combinators.{manyTill, manyTillWith, count};
        use TextParser/Text.{skipLine};
        let* _      = manyTill(skipLine(), separatingLine());
        let* _      = count(2, skipLine());
        let row1    = makeLineTextParser(eval);
        let* rows   = manyTillWith((x,ac) -> snoc(ac, x), empty(), row1, separatingLine()); 
        return(rows)

    /// Line of many '-' chars.
    def separatingLine(): TextParser[Unit, t] = 
        use TextParser.{flatMap, return, skippingAts};
        use TextParser/Text.{newline};
        let* _  = skippingAts("^\-+");
        let* _  = newline();
        return()


    def makeLineTextParser(eval: RowEvaluator[row]): TextParser[row, t] = 
        use TextParser.{flatMap, return, liftActionResult};
        use TextParser/Text.{restOfLine};
        use AssetLib/S4/FileIO/ZTable/RowEvaluator.{evaluateString};
        let split = s -> leadingSepBy(s, "|");
        let* s0 = restOfLine(true);
        let s1 = Text/Regex.replace(s0, Text/Regex/Pattern.irrefutablePattern("\R"), "");
        liftActionResult(_ -> evaluateString(split, s1, eval))


    def leadingSepBy(input: String, sep: String): Array[String] & Impure =
        use Text/Regex.{split};
        use Text/Regex/Pattern.{compile, quote};
        match compile(quote(sep)) {
            case Some(patt) => split(input, patt) |> Array.dropLeft(1)
            case None       => Array.new("", 0)
        }

}