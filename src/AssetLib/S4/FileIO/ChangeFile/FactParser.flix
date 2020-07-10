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



use FactIO/FlatFile.LineEvaluator;
use FactIO/FlatFile.SimpleParser;
use FactIO/FlatFile.RowWithHeadersEvaluator;
use FactIO/FlatFile.RowWithHeadersEvaluator.{RowWithHeadersEvaluator};

/// This is a generic library for making ChangeFile loaders and
/// not an actual change file loader.


/// TODO - call this FactReader?
namespace AssetLib/S4/FileIO/ChangeFile/FactParser {


    pub def importRows(eval: RowWithHeadersEvaluator[reln], path: String): Result[reln, System.Error] & Impure = 
        use Result.flatMap;
        let* relns = FactIO/FlatFile/SimpleParser.runSimpleParser(importRowsParser(eval), path, Text/Charset.utf_8());
        Ok(solve relns)


    def importRowsParser(eval: RowWithHeadersEvaluator[reln]): SimpleParser[reln] = 
        use FactIO/FlatFile/SimpleParser.{flatMap, return, skipLinesTill, linesTillEnd};
        use FactIO/FlatFile/LineEvaluator.{choice};
        let* headers = skipLinesTill(headerRow());
        let eval1 = makeLineEvaluator(headers, eval);
        let* rows = linesTillEnd(eval1);
        return(solve rows)

    def headerRow(): LineEvaluator[Map[String, Int32]] = 
        use Text/Regex/MatchEvaluator.{getNamedCapture, map};
        use FactIO/FlatFile/RowWithHeadersEvaluator.{makeHeaders};
        use FactIO/FlatFile/LineEvaluator.{matchesRegex};
        let regex = "^\*(?<rest>[A-Z]+.*)";
        let eval = getNamedCapture("rest") |> map(s -> makeHeaders(String.split(s, "\t")));
        matchesRegex(regex, eval)

    def makeLineEvaluator(columnHeadings: Map[String, Int32], eval: RowWithHeadersEvaluator[reln]): LineEvaluator[reln] = 
        use FactIO/FlatFile/RowWithHeadersEvaluator.{toLineEvaluator};
        toLineEvaluator(s -> String.split(s, "\t"), columnHeadings, eval)




    
}