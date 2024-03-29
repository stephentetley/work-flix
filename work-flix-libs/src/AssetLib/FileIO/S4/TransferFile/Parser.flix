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



namespace AssetLib/FileIO/S4/TransferFile/Parser {

    use Functor.{map, ignore};
    use Applicative.{*>};

    use Basis/System.FilePath;
    use Time.LocalDateTime;

    use FlixParsec.Parser;
    use FlixParsec/Prim.{point, flatMap, fail, endOfInput, liftAction, liftResult};
    use FlixParsec/Regex.{lookingAt, lookingAts};
    use FlixParsec/Combinators.{alt, choice, many, manyTill};
    use FlixParsec/Char.{string};
    use FlixParsec/Text.{many1UpperCase, restOfLine, makePattern, makePatternWithFlags};
    use FlixParsec/TokenSimple.{symbol, lexeme};

    use AssetLib/FileIO/S4/TransferFile/Datatypes.{TransferFile, FileHeader, FileType, DataModel, EntityType, Headers, DataRow};
    use AssetLib/FileIO/S4/TransferFile/Datatypes.FileType.{Download, Upload};
    use AssetLib/FileIO/S4/TransferFile/Datatypes.DataModel.{U1};
    use AssetLib/FileIO/S4/TransferFile/Datatypes.EntityType.{FuncLoc, ClassFloc, ValuaFloc, Iflotx, Equi, ClassEqui, ValuaEqui, Eqmltxt};

    /// Always UTF-8?
    pub def parseFile(r: Region[r], path: FilePath) : Result[TransferFile[r], String] \ { Write(r), Impure } = 
        FlixParsec/Extras.parsesFile(transferFileParser(r), 4, path, Text/Charset.utf_8())

    /// TODO - there's scope for a robust parser that doesn't interpret the initial "header" lines and 
    /// just interprets the last one for column headings.

    pub def transferFileParser(r: Region[r]): Parser[t1, TransferFile[r]] \ Write(r) = 
        let* hdr = pHeader();
        let* sel = alt(pSelection(), pEmptySelection());        
        let* cols = pColumnHeaders(r);
        let* rows = manyTill(pDataRow(r), endOfInput());
        point({fileHeader = hdr, selection = sel, headers = cols, dataRows = rows})



    def pHeader(): Parser[t1, FileHeader] = 
        let* ft     = pFileType();
        let* dm     = pDataModel();
        let* et     = pEntityType();
        let* v      = pVariant();
        let* u      = pUser();
        let* dt     = pDateTime();
        point({ fileType = ft, dataModel = dm, entityType = et
               , variant = v, user = u, dateTime = dt})

                    
    def asterisk(): Parser[t1, Unit] =  
        symbol("*") |> ignore
    


    def pFileType(): Parser[t1, FileType] = 
        let body = () -> {
            choice( 
                   (symbol("Download")  *> point(Download))
                :: (symbol("Upload")    *> point(Upload))
                :: Nil
            )
        };
        let* _ = asterisk();
        body()
        

    def pDataModel(): Parser[t1, DataModel] = 
        let body = () -> symbol("U1") *> point(U1);
        let* _ = symbol("* Data Model:"); 
        body()
        

    def pEntityType(): Parser[t1, EntityType] =
        let body = () -> {
            let* s = lexeme(lookingAts("\\p{Upper}+"));
            match s {
                case "FUNCLOC"      => point(FuncLoc)
                case "CLASSFLOC"    => point(ClassFloc)
                case "VALUAFLOC"    => point(ValuaFloc)
                case "IFLOTX"       => point(Iflotx)
                case "EQUI"         => point(Equi)
                case "CLASSEQUI"    => point(ClassEqui)
                case "VALUAEQUI"    => point(ValuaEqui)
                case "EQMLTXT"      => point(Eqmltxt)
                case _              => fail("EntityType")
            }
        };
        let* _ = symbol("* Entity Type:");
        body()

    def pVariant(): Parser[t1, String] = 
        let* _ = string("* Variant:");      // use `string` so we don't consume newline
        let* ans = restOfLine(true);
        point(String.trim(ans))
    
    def pUser(): Parser[t1, String] =
        let* _ = symbol("* User:");
        let* ans = restOfLine(true);
        point(String.trim(ans))

    def pDateTime(): Parser[t1, LocalDateTime] = 
        use FlixParsec/Prim.{liftOption};
        let* d = symbol("* Date:")  *> lexeme(lookingAts("\\d{8}"));
        let* t = symbol("/ Time:")  *> lexeme(lookingAts("\\d{6}"));
        let* fmt = liftResult(Time/Format/DateTimeFormatter.fromPattern("yyyyMMdd HHmmss"));
        let* ans = liftResult(Time/LocalDateTime.parse(fmt, d + " " + t));
        point(ans)

    def pEmptySelection(): Parser[t1, List[String]] = 
        point(Nil)

    def pSelection(): Parser[t1, List[String]] = 
        let* _ = pSelectionHeader();
        let* xs = pSelectionLines();
        point(xs)

    def pSelectionHeader(): Parser[t1, Unit] = 
        symbol("* Selection:") |> ignore         // blank header, consumes newline
        


    def pSelectionLines(): Parser[t1, List[String]] = 
        let selection1  = () -> {
            let* _ = symbol("* ");
            let* s = restOfLine(true);
            point(String.trim(s))
        };
        many(selection1())


    
    /// Note - the first header is prefixed by an asterisk, we can't use `asterisk` to find this 
    /// because `asterisk` can only see a token and there is no whitespace.
    /// Note - headers are `sepBy` tab
    /// Also use `splitOn` rather than `split` because `split` coalesces adjacent splitters
    def pColumnHeaders(r: Region[r]): Parser[t1, Headers[r]] \ Write(r) = 
        let* _      = asterisk();
        let* nl     = makePattern("\\R");
        let* str    = restOfLine(true) |> map(s -> Text/Regex.replace(from = nl, to = "", s));
        let* arr    = liftAction(_ -> String.splitOn({substr = Char.toString('\u0009')}, str) |> List.toArray(r));
        point(arr)

    
    /// Note - datarows are `sepEndBy` tab, hence dropRight(1)
    /// Also use `splitOn` rather than `split` because `split` coalesces adjacent splitters
    def pDataRow(r: Region[r]): Parser[t1, DataRow[r]] \ Write(r) = 
        let* tabnl  = makePatternWithFlags(".+?\\u0009\\R", Text/Regex/Pattern/Flag.Dotall :: Nil);
        let* str    = lookingAt(tabnl);
        let* arr    = liftAction(_ -> String.splitOn({substr = Char.toString('\u0009')}, str) |> List.toArray(r) |> Array.dropRight(1));
        point(arr)

}
