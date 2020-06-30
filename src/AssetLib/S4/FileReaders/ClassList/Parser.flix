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

use System.Error.{Generic};
use Time.LocalDate;


use TextParser.TextParser;
use TextParser.{parseFile, return, map, lookingAts, liftResult};
// use TextParser/Combinators.{seqRight, ignore, choice, liftResult, many, manyTill};
// use TextParser/Text.{many1UpperCase, restOfLine, lookingAts, string};
use TextParser/Token1.{lexeme, symbol};

use AssetLib/S4/FileReaders/ClassList/Datatypes.{ClassList};


namespace AssetLib/S4/FileReaders/ClassList/Parser {



    /// Always UTF-8?
    pub def parseFile(path: String) : Result[ClassList, System.Error] & Impure = 
        let path1 = System/FilePath.new(path);
        TextParser.parseFile(classListParser(), path1, Text/Charset.utf_8()) 


    def classListParser(): TextParser[ClassList, t] = 
        use TextParser.flatMap;
        let* _ = symbol("Class List");
        let* d = pDateStamp();
        return({ dateStamp = d, classes = Nil})

    def pDateStamp(): TextParser[LocalDate, t] = 
        use TextParser.flatMap;
        let* d = lexeme(lookingAts("\d{2}\.\d{2}\.\d{4}"));
        let* fmt = liftResult(Time/Format/DateFormatter.fromPattern("dd.MM.yyyy"));
        let* ans = liftResult(Time/LocalDate.parse(d, fmt));
        return(ans)
        

}