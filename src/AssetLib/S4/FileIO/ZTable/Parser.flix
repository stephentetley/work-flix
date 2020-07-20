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

use TextParser.TextParser;
use TextParser.RowParser;


namespace AssetLib/S4/FileIO/ZTable/Parser {



    pub def importRows(rowp: RowParser[reln], path: System.FilePath): Result[reln, System.Error] & Impure = 
        use Result.flatMap;
        let* relns = TextParser.parseFile(importRowsParser(rowp), path, Text/Charset.utf_8());
        Ok(solve relns)


    def importRowsParser(rowp: RowParser[reln]): TextParser[reln, t] = 
        use TextParser.{flatMap, return};
        use TextParser/Combinators.{manyTill, manyTillWith, count};
        use TextParser/Text.{skipLine};
        let* _      = manyTill(skipLine(), separatingLine());
        let* _      = count(2, skipLine());
        let row1    = makeLineTextParser(rowp);
        let* rows   = manyTillWith((x,ac) -> ac <+> x, #{}, row1, separatingLine());        
        return(solve rows)

    /// Line of many '-'
    def separatingLine(): TextParser[Unit, t] = 
        use TextParser.{flatMap, return, skippingAts};
        use TextParser/Text.{newline};
        let* _  = skippingAts("^\-+");
        let* _  = newline();
        return()


    def makeLineTextParser(rowp: RowParser[reln]): TextParser[reln, t] = 
        use TextParser/RowParser.{rowTextParser};
        use AssetLib/Common/Utils.{leadingSepBy};
        let split = s -> leadingSepBy(s, "|");
        rowTextParser(split, rowp)

}