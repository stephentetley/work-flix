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
use TextParser.{parseFile, return, failure, map, alt, lookingAts, liftResult, swapError, parseLine};
use TextParser/Combinators.{optional, manyWith};
use TextParser/Text.{restOfLine, restOfLineLength, content, anchorLine, upperLetters};
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

    pub enum SourceType {
        case FlocClasses,
        case EquiClasses
    }

    def getNameSize(x: SourceType): Int32 = match x {
        case FlocClasses => 33
        case EquiClasses => 35
    }

    def getClassDescSize(x: SourceType): Int32 = match x {
        case FlocClasses => 36
        case EquiClasses => 10
    }

    def getCharacteristicDescSize(x: SourceType): Int32 = match x {
        case FlocClasses => 47
        case EquiClasses => 51
    }

    /// Always UTF-8? no if parsing fails try iso_8859_1()
    pub def parseFile(path: String, srctype: SourceType, cs: Text.Charset) : Result[ClassListFile, System.Error] & Impure = 
        let path1 = System/FilePath.new(path);
        TextParser.parseFile(classListParser(srctype), path1, cs) 


    def classListParser(srctype: SourceType): TextParser[ClassListFile, t] = 
        use TextParser.flatMap;
        use TextParser/Trace.{tell};
        use Data/Transient/DList.{empty, toList};
        let* _ = tell("Parser Start");
        let* _  = symbol("Class List");
        let* d  = pDateStamp();
        let* _  = anchorLine(Text/Regex/Pattern.quote("Class -> Characteristic"));
        let* _  = anchorLine("\-{40,}");
        let* rows = manyWith(append, empty(), parseLine(classListRow(srctype), true));
        return({ dateStamp = d, rows = toList(rows)})

    def pDateStamp(): TextParser[LocalDate, t] = 
        use TextParser.flatMap;
        let* d = lexeme(lookingAts("\d{2}\.\d{2}\.\d{4}"));
        let* fmt = liftResult(Time/Format/DateFormatter.fromPattern("dd.MM.yyyy"));
        let* ans = liftResult(Time/LocalDate.parse(d, fmt));
        return(ans)
        

    def classListRow(srctype: SourceType): TextParser[Option[ClassListRow], t] = 
        use TextParser.flatMap;
        use TextParser/Trace.{trace};
        let* indent = trace("row", indentingLevel());
        match indent { 
            case 11 => optional(map(ClassRow, classLine(srctype)))
            case 15 => optional(map(CharacteristicRow, characteristicLine(srctype)))
            case 19 => optional(map(ValueRow, valueLine()))
            case _  => return(None)
        }

    def classLine(srctype: SourceType): TextParser[ClassRow, t] =
        use TextParser.{flatMap};
        let namelen = getNameSize(srctype);
        let desclen = getClassDescSize(srctype);
        let* ctype  = content(4);
        let* name   = content(namelen);
        let* len    = restOfLineLength();
        let* desc   = if (len > desclen) content(desclen) else restOfLine(false);
        return({ classType = ctype, name = name, description = desc })

    def characteristicLine(srctype: SourceType): TextParser[CharacteristicRow, t] =
        use TextParser.{flatMap};
        let namelen = getNameSize(srctype);
        let desclen = getCharacteristicDescSize(srctype);
        let* name   = content(namelen);
        let* desc   = content(desclen);
        let* dtype  = datatype();
        return({ name = name, description = desc, datatype = dtype})

    def datatype(): TextParser[Datatype, t] = 
        use TextParser.{flatMap};
        let* tyname = lexeme(upperLetters());
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