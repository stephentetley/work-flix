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
use FactIO/FlatFile.Parser;    
use FactIO/FlatFile.RowEvaluator;


namespace AssetLib/S4/FileReaders/ZTable/FactParser {



    pub def importRows(eval: RowEvaluator[reln], path: String): Result[reln, System.Error] & Impure = 
        use Result.flatMap;
        let* relns = FactIO/FlatFile/Parser.runParser(importRowsParser(eval), (), path, Text/Charset.utf_8());
        Ok(solve relns)


    def importRowsParser(eval: RowEvaluator[reln]): Parser[reln, Unit] = 
        use FactIO/FlatFile/Parser.{flatMap, return, skipTill, skipLines, lines};
        use FactIO/FlatFile/LineEvaluator.{choice};
        let* _  = skipTill(separatingLine());
        let* _ = skipLines(2);
        let eval1 = makeLineEvaluator(eval);
        let* rows = lines(eval1);
        return(solve rows)

    /// Line of many '-'
    def separatingLine(): LineEvaluator[Unit] = 
        use FactIO/FlatFile/LineEvaluator.{matches, flatMap, liftResult, content};
        use Text/Regex/MatchEvaluator.{return};
        let* pattern = liftResult(Text/Regex/Pattern.compile("^\-+$"));
        matches(pattern, return())


    def makeLineEvaluator(eval: RowEvaluator[reln]): LineEvaluator[reln] = 
        use FactIO/FlatFile/RowEvaluator.{toLineEvaluator};
        use FactIO/FlatFile/Split.{leadingSepBy};
        let split = s -> leadingSepBy(s, "|");
        toLineEvaluator(split, eval)

}