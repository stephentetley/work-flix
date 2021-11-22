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



namespace AssetLib/FileIO/S4/ZTable/Parser {


    use Data.DList;
    use FlixParsec.Parser;

    use AssetLib/FileIO/S4/ZTable.RowEvaluator;

    /// Note - parser may loop rather than fail if given wrong ztable input source for the RowEvaluator, needs investigating...

    pub def importRows(eval: RowEvaluator[row], path: System.FilePath): Result[List[row], String] & Impure = 
        use Result.flatMap;
        use Data/DList.{toList};
        let* rows = FlixParsec/Extras.parsesFile(importRowsParser(eval), 4, path, Text/Charset.utf_8());
        Ok(toList(rows))


    def importRowsParser(eval: RowEvaluator[row]): Parser[t1, DList[row]] = 
        use Data/DList.{empty, snoc};
        use FlixParsec/Prim.{flatMap, return};
        use FlixParsec/Combinators.{manyTill, manyTillWith, count};
        use FlixParsec/Text.{skipLine};
        let* _      = manyTill(skipLine(), separatingLine());
        let* _      = count(2, skipLine());
        let row1    = makeLineParser(eval);
        let* rows   = manyTillWith((ac, x) -> snoc(ac, x), empty(), row1, separatingLine()); 
        return(rows)

    /// Line of many '-' chars.
    def separatingLine(): Parser[t1, Unit] = 
        use FlixParsec/Prim.{flatMap, return};
        use FlixParsec/Regex.{skippingAts};
        use FlixParsec/Text.{newline};
        let* _  = skippingAts("^\\-+");
        let* _  = newline();
        return()


    def makeLineParser(eval: RowEvaluator[row]): Parser[t1, row] = 
        use FlixParsec/Prim.{flatMap, return, liftActionResult};
        use FlixParsec/Text.{restOfLine};
        use AssetLib/FileIO/S4/ZTable/RowEvaluator.{evaluateString};
        let split = s -> leadingSepBy(s, "|");
        let* s0 = restOfLine(true);
        let s1 = Text/Regex.replace(Text/Regex/Pattern.irrefutablePattern("\\R"), "", s0);
        liftActionResult(_ -> evaluateString(split, s1, eval))


    def leadingSepBy(input: String, sep: String): Array[String] & Impure =
        use Text/Regex/Pattern.{compile, quote};
        match compile(quote(sep)) {
            case Ok(patt) => Text/Regex.split(patt, input) |> Array.dropLeft(1)
            case Err(_)   => Array.new("", 0)
        }

}