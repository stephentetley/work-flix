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


    use FlixSandbox/System.FilePath;
    use FlixParsec.Parser;

    use AssetLib/FileIO/S4/ZTable.RowEvaluator;

    /// Note - parser may loop rather than fail if given wrong ztable input source for the RowEvaluator, needs investigating...

    /// Pass both the region and rhe evaluator...
    pub def importRows(r: Region[r], eval: RowEvaluator[r, row], path: FilePath): Result[List[row], String] \ { Read(r), Write(r), Impure } = 
        use Result.flatMap;
        let* rows = FlixParsec/Extras.parsesFile(importRowsParser(r, eval), 4, path, Text/Charset.utf_8());
        Ok(Chain.toList(rows))


    def importRowsParser(r: Region[r], eval: RowEvaluator[r, row]): Parser[t1, Chain[row]] \ { Read(r), Write(r) } = 
        use FlixParsec/Prim.{flatMap, point};
        use FlixParsec/Combinators.{manyTill, manyTillWith, count};
        use FlixParsec/Text.{skipLine};
        let* _      = manyTill(skipLine(), separatingLine());
        let* _      = count(2, skipLine());
        let row1    = makeLineParser(r, eval);
        let* rows   = manyTillWith((ac, x) -> Chain.snoc(ac, x), Chain.empty(), row1, separatingLine()); 
        point(rows)

    /// Line of many '-' chars.
    def separatingLine(): Parser[t1, Unit] = 
        use FlixParsec/Prim.{flatMap, point};
        use FlixParsec/Regex.{skippingAts};
        use FlixParsec/Text.{newline};
        let* _  = skippingAts("^\\-+");
        let* _  = newline();
        point()

    /// Here is the invoke site for eval 
    def makeLineParser(r: Region[r], eval: RowEvaluator[r, row]): Parser[t1, row] \ { Read(r), Write(r) } = 
        use FlixParsec/Prim.{flatMap, liftActionResult};
        use FlixParsec/Text.{restOfLine};
        use AssetLib/FileIO/S4/ZTable/RowEvaluator.{evaluateString};
        let split = s -> leadingSepBy(r, s, "|");
        let* s0 = restOfLine(true);
        let s1 = Text/Regex.replace(from = Text/Regex/Pattern.irrefutablePattern("\\R"), to = "", s0);
        liftActionResult(_ -> evaluateString(r, split, s1, eval))


    def leadingSepBy(r: Region[r], input: String, sep: String): Array[String, r] \ Write(r) =
        use Text/Regex/Pattern.{compile, quote};
        match compile(quote(sep)) {
            case Ok(patt) => Text/Regex.split(patt, input) |> List.drop(1) |> List.toArray(r)
            case Err(_)   => Array.new("", 0, r)
        }

}
