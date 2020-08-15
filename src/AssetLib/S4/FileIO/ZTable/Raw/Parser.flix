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

use Data/Transient.DList;

use TextParser.TextParser;
use TextParser.RowParser;


namespace AssetLib/S4/FileIO/ZTable/Raw/Parser {



    pub def importRows(rowp: RowParser[row], path: System.FilePath): Result[List[row], System.Error] & Impure = 
        use Result.flatMap;
        use Data/Transient/DList.{toList};
        let* rows = TextParser.parseFile(importRowsParser(rowp), path, Text/Charset.utf_8());
        Ok(toList(rows))


    def importRowsParser(rowp: RowParser[row]): TextParser[DList[row], t] = 
        use Data/Transient/DList.{empty, snoc};
        use TextParser.{flatMap, return};
        use TextParser/Combinators.{manyTill, manyTillWith, count};
        use TextParser/Text.{skipLine};
        let* _      = manyTill(skipLine(), separatingLine());
        let* _      = count(2, skipLine());
        let row1    = makeLineTextParser(rowp);
        let* rows   = manyTillWith((x,ac) -> snoc(ac, x), empty(), row1, separatingLine()); 
        return(rows)

    /// Line of many '-' chars.
    def separatingLine(): TextParser[Unit, t] = 
        use TextParser.{flatMap, return, skippingAts};
        use TextParser/Text.{newline};
        let* _  = skippingAts("^\-+");
        let* _  = newline();
        return()


    def makeLineTextParser(rowp: RowParser[row]): TextParser[row, t] = 
        use TextParser/RowParser.{rowTextParser};
        use AssetLib/Common/Utils.{leadingSepBy};
        let split = s -> leadingSepBy(s, "|");
        rowTextParser(split, rowp)

}