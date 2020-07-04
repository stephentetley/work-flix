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
use System.Error.{Generic};
use Time.LocalDate;


use TextParser.TextParser;
use TextParser.{parseFile, return, failure, map, lookingAts, liftResult, swapError, parseLine};
use TextParser/Combinators.{optional, manyWith};
use TextParser/Text.{restOfLine, content, anchorLine};
use TextParser/Token1.{lexeme, symbol, int32};

use AssetLib/S4/FileReaders/ClassList/Datatypes.{ClassListFile, ClassListRow, ClassRow, CharacteristicRow, Datatype};
use AssetLib/S4/FileReaders/ClassList/Datatypes.ClassListRow.{ClassRow, CharacteristicRow, ValueRow};
use AssetLib/S4/FileReaders/ClassList/Datatypes.Datatype.{Text, Date, NumInt, NumDecimal};


namespace AssetLib/S4/FileReaders/ClassList/Parser {




    def append(x: Option[a], ac: DList[a]): DList[a] = 
        use Data/Transient/DList.{snoc};
        match x { 
            case Some(a) => snoc(ac, a)
            case None => ac
        }


    /// Always UTF-8?
    pub def parseFile(path: String) : Result[ClassListFile, System.Error] & Impure = 
        let path1 = System/FilePath.new(path);
        TextParser.parseFile(classListParser(), path1, Text/Charset.utf_8()) 


    def classListParser(): TextParser[ClassListFile, t] = 
        use TextParser.flatMap;
        use Data/Transient/DList.{empty, toList};
        let* _  = symbol("Class List");
        let* d  = pDateStamp();
        let* _  = anchorLine(Text/Regex/Pattern.quote("Class -> Characteristic"));
        let* _  = anchorLine("\-{40,}");
        let* rows = manyWith(append, empty(), parseLine(classListRow(), true));
        return({ dateStamp = d, rows = toList(rows)})

    def pDateStamp(): TextParser[LocalDate, t] = 
        use TextParser.flatMap;
        let* d = lexeme(lookingAts("\d{2}\.\d{2}\.\d{4}"));
        let* fmt = liftResult(Time/Format/DateFormatter.fromPattern("dd.MM.yyyy"));
        let* ans = liftResult(Time/LocalDate.parse(d, fmt));
        return(ans)
        

    def classListRow(): TextParser[Option[ClassListRow], t] = 
        use TextParser.flatMap;
        let* indent = indentingLevel();
        match indent { 
            case 11 => optional(map(ClassRow, classLine()))
            case 15 => optional(map(CharacteristicRow, characteristicLine()))
            case 19 => optional(map(ValueRow, valueLine()))
            case _  => return(None)
        }

    def classLine(): TextParser[ClassRow, t] =
        use TextParser.{flatMap};
        let* ctype  = content(4);
        let* name   = content(33);
        let* desc   = content(36);
        let* _      = restOfLine(true);
        return({ classType = ctype, name = name, description = desc })

    def characteristicLine(): TextParser[CharacteristicRow, t] =
        use TextParser.{flatMap};
        let* name   = content(33);
        let* desc   = content(47);
        let* dtype  = datatype();
        return({ name = name, description = desc, datatype = dtype})

    def datatype(): TextParser[Datatype, t] = 
        use TextParser.{flatMap};
        let* tyname = lookingAts("\p{Upper}+");
        let* length = int32();
        let* dprec  = optional(int32());
        match (tyname, dprec) {
            case ("CHAR", _)        => return(Text(length))
            case ("DATE", _)        => return(Date(length))
            case ("NUM", None)      => return(NumInt(length))
            case ("NUM", Some(p))   => return(NumDecimal(length, p))
            case _                  => failure("Unknown datatype: " + tyname)
        }

    def valueLine(): TextParser[String, t] = 
        map(String.trim, restOfLine(false))


    def indentingLevel(): TextParser[Int32, t] = 
        map(String.length, lookingAts("(\||\-|\s)+")) `swapError` "indentingLevel"

}