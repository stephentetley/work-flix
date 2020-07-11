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

use TextParser.TextParser;
use TextParser.{return, map, failure, alt, seqRight, lookingAts, endOfInput, liftAction, liftResult, string};
use TextParser/Combinators.{ignore, choice, many, manyTill};
use TextParser/Text.{many1UpperCase, restOfLine, makePattern};
use TextParser/Token1.{symbol, lexeme};

use AssetLib/S4/FileIO/ChangeFile/Datatypes.{PrimChangeFile, FileType, DataModel, EntityType, Headers, Selection, DataRow, FileHeader, ChangeFile};
use AssetLib/S4/FileIO/ChangeFile/Datatypes.ChangeFile.{ChangeFile};
use AssetLib/S4/FileIO/ChangeFile/Datatypes.FileType.{Download, Upload};
use AssetLib/S4/FileIO/ChangeFile/Datatypes.DataModel.{U1};
use AssetLib/S4/FileIO/ChangeFile/Datatypes.EntityType.{FuncLoc, ClassFloc, ValuaFloc, Iflotx, Equi, ClassEqui, ValuaEqui, Eqmltxt};
use AssetLib/S4/FileIO/ChangeFile/Datatypes.Headers.{Headers};
use AssetLib/S4/FileIO/ChangeFile/Datatypes.Selection.{Selection};
use AssetLib/S4/FileIO/ChangeFile/Datatypes.DataRow.{DataRow};


namespace AssetLib/S4/FileIO/ChangeFile/Parser {

    /// Always UTF-8?
    pub def parseFile(path: String) : Result[PrimChangeFile, System.Error] & Impure = 
        let path1 = System/FilePath.new(path);
        TextParser.parseFile(changeFileParser(), path1, Text/Charset.utf_8())    

    /// TODO - there's scope for a parser that doesn't interpret the initial "header" lines and 
    /// just interprets the last one for column headings.

    pub def changeFileParser(): TextParser[PrimChangeFile, t] = 
        use TextParser.flatMap;
        let* hdr = pHeader();
        let* sel = alt(pSelection(), pEmptySelection());        
        let* cols = pColumnHeaders();
        let* rows = manyTill(pDataRow(), endOfInput());
        return(ChangeFile({ fileHeader = hdr, selection = sel, headers = cols, dataRows = rows }))



    def pHeader(): TextParser[FileHeader, t] = 
        use TextParser.flatMap;
        let* ft = pFileType();
        let* dm = pDataModel();
        let* et = pEntityType();
        let* v = pVariant();
        let* u = pUser();
        let* dt = pDateTime();
        return({ fileType = ft, dataModel = dm, entityType = et, 
                    variant = v, user = u, dateTime = dt })

                    
    def asterisk(): TextParser[Unit, t] =  
        symbol("*") |> ignore
    


    def pFileType(): TextParser[FileType, t] = 
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
        

    def pDataModel(): TextParser[DataModel, t] = 
        use TextParser.flatMap;
        let body = () -> symbol("U1") `seqRight` return(U1);
        let* _ = symbol("* Data Model:"); 
        body()
        

    def pEntityType(): TextParser[EntityType, t] =
        use TextParser.flatMap;
        let body = () -> {
            let* s = lexeme(lookingAts("\p{Upper}+"));
            match s {
                case "FUNCLOC"      => return(FuncLoc)
                case "CLASSFLOC"    => return(ClassFloc)
                case "VALUAFLOC"    => return(ValuaFloc)
                case "IFLOTX"       => return(Iflotx)
                case "EQUI"         => return(Equi)
                case "CLASSEQUI"    => return(ClassEqui)
                case "VALUAEQUI"    => return(ValuaEqui)
                case "EQMLTXT"      => return(Eqmltxt)
                case _              => failure("EntityType")
            }
        };
        let* _ = symbol("* Entity Type:");
        body()

    def pVariant(): TextParser[String, t] = 
        use TextParser.flatMap;
        let* _ = string("* Variant:");      // use `string` so we don't consume newline
        let* ans = restOfLine(true);
        return(String.trim(ans))
    
    def pUser(): TextParser[String, t] =
        use TextParser.flatMap;
        let* _ = symbol("* User:");
        let* ans = restOfLine(true);
        return(String.trim(ans))

    def pDateTime(): TextParser[LocalDateTime, t] = 
        use TextParser.flatMap;
        let* d = symbol("* Date:")  `seqRight` lexeme(lookingAts("\d{8}"));
        let* t = symbol("/ Time:")  `seqRight` lexeme(lookingAts("\d{6}"));
        let* fmt = liftResult(Time/Format/DateTimeFormatter.fromPattern("yyyyMMdd HHmmss"));
        let* ans = liftResult(Time/LocalDateTime.parse(d + " " + t, fmt));
        return(ans)

    def pEmptySelection(): TextParser[Selection, t] = 
        return(Selection(Nil))

    def pSelection(): TextParser[Selection, t] = 
        use TextParser.flatMap;
        let* _ = pSelectionHeader();
        let* xs = pSelectionLines();
        return(Selection(xs))

    def pSelectionHeader(): TextParser[Unit, t] = 
        symbol("* Selection:") |> ignore         // blank header, consumes newline
        


    def pSelectionLines(): TextParser[List[String], t] = 
        use TextParser.flatMap;
        let selection1  = () -> {
            let* _ = symbol("* ");
            let* s = restOfLine(true);
            return(String.trim(s))
        };
        many(selection1())


    
    /// Note - the first header is prefixed by an asterisk, we can't use `asterisk` to find this 
    /// because `asterisk` can only see a token and there is no whitespace.
    /// Note - headers are `sepBy` tab
    /// Also use `splitOn` rather than `split` because `split` coalesces adjacent splitters
    def pColumnHeaders(): TextParser[Headers, t] = 
        use TextParser.flatMap;
        let* _ = asterisk();
        let* nl = makePattern("\R");
        let* str = restOfLine(true) |> map(s -> Text/Regex.replace(s, nl, ""));
        let* arr = liftAction(_ -> String.splitOn(str, Char.toString('\u0009')) |> List.toArray);
        return(Headers(arr))

    /// Note - datarows are `sepEndBy` tab, hence dropRight(1)
    /// Also use `splitOn` rather than `split` because `split` coalesces adjacent splitters
    def pDataRow(): TextParser[DataRow, t] = 
        use TextParser.flatMap;
        let* nl = makePattern("\R");
        let* str = restOfLine(true) |> map(s -> Text/Regex.replace(s, nl, ""));
        let* arr = liftAction(_ -> String.splitOn(str, Char.toString('\u0009')) |> List.toArray |> Array.dropRight(1));
        return(DataRow(arr))




}