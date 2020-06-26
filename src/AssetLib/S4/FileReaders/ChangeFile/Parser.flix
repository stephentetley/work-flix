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

use Time.LocalDateTime;

use TextParser.Parser;
use TextParser.{return, map, parseError, endOfInput, liftAction};
use TextParser/Combinators.{seqRight, ignore, choice, liftResult, many, manyTill};
use TextParser/Text.{many1UpperCase, restOfLine, lookingAts, string};
use TextParser/Token.{symbol, lexeme};

use AssetLib/S4/FileReaders/ChangeFile/Datatypes.{FileType, DataModel, EntityType, Headers, Selection, DataRow, FileHeader, ChangeFile};
use AssetLib/S4/FileReaders/ChangeFile/Datatypes.FileType.{Download, Upload};
use AssetLib/S4/FileReaders/ChangeFile/Datatypes.DataModel.{U1};
use AssetLib/S4/FileReaders/ChangeFile/Datatypes.EntityType.{FuncLoc, ClassFloc, ValuaFloc, Iflotx, Equi, ClassEqui, ValuaEqui, Eqmltxt};
use AssetLib/S4/FileReaders/ChangeFile/Datatypes.Headers.{Headers};
use AssetLib/S4/FileReaders/ChangeFile/Datatypes.Selection.{Selection};
use AssetLib/S4/FileReaders/ChangeFile/Datatypes.DataRow.{DataRow};


namespace AssetLib/S4/FileReaders/ChangeFile/Parser {

    

    def asterisk(): Parser[Unit] =  
        symbol("*") |> ignore
    


    def pFileType(): Parser[FileType] = 
        use TextParser.flatMap;
        let body = () -> {
            choice( 
                   (symbol("Download")  `seqRight` return(Download))
                :: (symbol("Upload")    `seqRight` return(Upload))
                :: Nil
            )
        };
        let* _ = asterisk();
        body()
        

    def pDataModel(): Parser[DataModel] = 
        use TextParser.flatMap;
        let body = () -> symbol("U1") `seqRight` return(U1);
        let* _ = symbol("* Data Model:"); 
        body()
        

    def pEntityType(): Parser[EntityType] =
        use TextParser.flatMap;
        let body = () -> {
            let* s = lexeme(many1UpperCase());
            match s {
                case "FUNCLOC"      => return(FuncLoc)
                case "CLASSFLOC"    => return(ClassFloc)
                case "VALUAFLOC"    => return(ValuaFloc)
                case "IFLOTX"       => return(Iflotx)
                case "EQUI"         => return(Equi)
                case "CLASSEQUI"    => return(ClassEqui)
                case "VALUAEQUI"    => return(ValuaEqui)
                case "EQMLTXT"      => return(Eqmltxt)
                case _              => parseError("EntityType")
            }
        };
        let* _ = symbol("* Entity Type:");
        body()

    def pVariant(): Parser[String] = 
        use TextParser.flatMap;
        let* _ = string("* Variant:");      // use `string` so we don't consume newline
        let* ans = restOfLine(true);
        return(String.trim(ans))
    
    def pUser(): Parser[String] =
        use TextParser.flatMap;
        let* _ = symbol("* User:");
        let* ans = restOfLine(true);
        return(String.trim(ans))

    def pDateTime(): Parser[LocalDateTime] = 
        use TextParser.flatMap;
        let* d = symbol("* Date:")  `seqRight` lexeme(lookingAts("\d{8}"));
        let* t = symbol("/ Time:")  `seqRight` lexeme(lookingAts("\d{6}"));
        let* fmt = liftResult(Time/Format/DateTimeFormatter.fromPattern("yyyyMMdd HHmmss"));
        let* ans = liftResult(Time/LocalDateTime.parse(d + " " + t, fmt));
        return(ans)
        

    def pHeader(): Parser[FileHeader] = 
        use TextParser.flatMap;
        let* ft = pFileType();
        let* dm = pDataModel();
        let* et = pEntityType();
        let* v = pVariant();
        let* u = pUser();
        let* dt = pDateTime();
        return({ fileType = ft, dataModel = dm, entityType = et, 
                    variant = v, user = u, dateTime = dt })

    def pSelectionHeader(): Parser[Unit] = 
        symbol("* Selection:") |> ignore         // blank header, consumes newline
        


    def pSelectionLines(): Parser[List[String]] = 
        use TextParser.flatMap;
        let selection1  = () -> {
            let* _ = symbol("* ");
            let* s = restOfLine(true);
            return(String.trim(s))
        };
        many(selection1())

    def pSelection(): Parser[Selection] = 
        use TextParser.flatMap;
        let* _ = pSelectionHeader();
        let* xs = pSelectionLines();
        return(Selection(xs))
    
    /// Note - the first header is prefixed by an asterisk, we can't use `asterisk` to find this 
    /// because `asterisk` can only see a token and there is no whitespace.
    def pColumnHeaders(): Parser[Headers] = 
        use TextParser.flatMap;
        let* _ = asterisk();
        let* str = restOfLine(true);
        let* arr = liftAction(_ -> String.split(String.trim(str), Char.toString('\u0009')));
        return(Headers(arr))

    
    def pDataRow(): Parser[DataRow] = 
        use TextParser.flatMap;
        let* str = restOfLine(true);
        let* arr = liftAction(_ -> String.split(String.trimRight(str), Char.toString('\u0009')));
        return(DataRow(arr))


    pub def changeFileParser(): Parser[ChangeFile] = 
        use TextParser.flatMap;
        let* hdr = pHeader();
        let* sel = pSelection();        
        let* cols = pColumnHeaders();
        let* rows = manyTill(pDataRow(), endOfInput());
        return({ fileHeader = hdr, selection = sel, headers = cols, dataRows = rows })


    /// Always UTF-8?
    pub def parseFile(path: String) : Result[ChangeFile, System.Error] & Impure = 
        let path1 = System/FilePath.new(path);
        match TextParser.parseFile(changeFileParser(), path1, Text/Charset.utf_8() ) { 
            case Err(e) => Err(Generic(TextParser/Error.showParserError(e)))
            case Ok(a) => Ok(a)
        }

}