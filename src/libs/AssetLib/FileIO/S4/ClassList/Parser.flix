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




namespace AssetLib/FileIO/S4/ClassList/Parser {

    use Time.LocalDate;

    use FlixParsec.Parser;
    use FlixParsec/Prim.{parseFile, point, map, alt, throwError, liftResult, liftOption, swapError};
    use FlixParsec/Regex.{lookingAts};
    use FlixParsec/Combinators.{optional, manyWith};
    use FlixParsec/Text.{parseLine, restOfLine, restOfLineLength, content, anchorLine, upperLetters};
    use FlixParsec/TokenSimple.{lexeme, symbol, int32};

    use AssetLib/FileIO/S4/ClassList/Datatypes.{SourceType, ClassListFile, ClassListRow, ClassRow, CharacteristicRow, Datatype};
    use AssetLib/FileIO/S4/ClassList/Datatypes.SourceType.{FlocClasses, EquiClasses};
    use AssetLib/FileIO/S4/ClassList/Datatypes.ClassListRow.{ClassRow, CharacteristicRow, ValueRow};
    use AssetLib/FileIO/S4/ClassList/Datatypes.Datatype.{Text, Date, NumInt, NumDecimal};

    /// Always UTF-8 with BOM? 
    pub def parseEquiClassFile(path: System.FilePath) : Result[ClassListFile, String] & Impure = 
        FlixParsec/Extras.parsesFileWithBOM(classListParser(EquiClasses), 4, path) 

    pub def parseFlocClassFile(path: System.FilePath) : Result[ClassListFile, String] & Impure =  
        FlixParsec/Extras.parsesFileWithBOM(classListParser(FlocClasses), 4, path) 

    def classListParser(srctype: SourceType): Parser[t1, ClassListFile] = 
        use FlixParsec/Prim.{flatMap};
        let* _  = symbol("Class List");
        let* d  = pDateStamp();
        let* _  = anchorLine(Text/Regex/Pattern.quote("Class -> Characteristic"));
        let* _  = anchorLine("\\-{40,}");
        let* rows = manyWith(append, Chain.empty(), parseLine(classListRow(srctype), true));
        point({ dateStamp = d, rows = Chain.toList(rows)})

    def pDateStamp(): Parser[t1, LocalDate] = 
        use FlixParsec/Prim.{flatMap};
        let* d = lexeme(lookingAts("\\d{2}\\.\\d{2}\\.\\d{4}"));
        let* fmt = liftOption(Time/Format/DateFormatter.ofPattern("dd.MM.yyyy"), "pDateStamp");
        let* ans = liftOption(Time/LocalDate.parse(fmt, d), "pDateStamp");
        point(ans)
        

    def classListRow(srctype: SourceType): Parser[t1, Option[ClassListRow]] = 
        use FlixParsec/Prim.{flatMap};        
        let* indent = indentingLevel();
        match indent { 
            case 11 => optional(map(ClassRow, classLine(srctype)))
            case 15 => optional(map(CharacteristicRow, characteristicLine(srctype)))
            case 19 => optional(map(ValueRow, valueLine()))
            case _  => point(None)
        }

    def classLine(srctype: SourceType): Parser[t1, ClassRow] =
        use FlixParsec/Prim.{flatMap};
        let namelen = getNameSize(srctype);
        let desclen = getClassDescSize(srctype);
        let* ctype  = content(4);
        let* name   = content(namelen);
        let* len    = restOfLineLength();
        let* desc   = if (len > desclen) content(desclen) else restOfLine(false);
        point({name = name, description = desc, classtype = ctype})

    def characteristicLine(srctype: SourceType): Parser[t1, CharacteristicRow] =
        use FlixParsec/Prim.{flatMap};
        let namelen = getNameSize(srctype);
        let desclen = getCharacteristicDescSize(srctype);
        let* name   = content(namelen);
        let* desc   = content(desclen);
        let* dtype  = datatype();
        point({name = name, description = desc, chartype = dtype})

    def datatype(): Parser[t1, Datatype] = 
        use FlixParsec/Prim.{flatMap};
        let* tyname = lexeme(upperLetters());
        let* length = int32();
        let* dprec  = optional(int32());
        match (tyname, dprec) {
            case ("CHAR", _)        => point(Text(length))
            case ("DATE", _)        => point(Date(length))
            case ("NUM", None)      => point(NumInt(length))
            case ("NUM", Some(p))   => point(NumDecimal(length, p))
            case _                  => throwError("Unknown datatype: ${tyname}")
        }

    def valueLine(): Parser[t1, String] = 
        map(String.trim, restOfLine(false))


    def indentingLevel(): Parser[t1, Int32] = 
        map(String.length, lookingAts("(\\||\\-|\\s)+")) `swapError` "indentingLevel"

    /// Utils
    
    def append(ac: Chain[a], x: Option[a]): Chain[a] = 
        match x { 
            case Some(a) => Chain.snoc(ac, a)
            case None => ac
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

}
