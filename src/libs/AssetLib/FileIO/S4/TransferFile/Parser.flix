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

    use Time.LocalDateTime;

    use FlixParsec.Parser;
    use FlixParsec/Prim.{return, map, fail, endOfInput, liftAction, liftResult};
    use FlixParsec/Regex.{lookingAts};
    use FlixParsec/Combinators.{alt, choice, ignore, many, manyTill, seqRight};
    use FlixParsec/Char.{string};
    use FlixParsec/Text.{many1UpperCase, restOfLine, makePattern, makePatternWithFlags};
    use FlixParsec/TokenSimple.{symbol, lexeme};

    use AssetLib/FileIO/S4/TransferFile/Datatypes.{TransferFile, FileHeader, FileType, DataModel, EntityType, Headers, DataRow};
    use AssetLib/FileIO/S4/TransferFile/Datatypes.FileType.{Download, Upload};
    use AssetLib/FileIO/S4/TransferFile/Datatypes.DataModel.{U1};
    use AssetLib/FileIO/S4/TransferFile/Datatypes.EntityType.{FuncLoc, ClassFloc, ValuaFloc, Iflotx, Equi, ClassEqui, ValuaEqui, Eqmltxt};

    /// Always UTF-8?
    pub def parseFile(path: System.FilePath) : Result[TransferFile, String] & Impure = 
        FlixParsec/Prim.parsesFile(transferFileParser(), 4, path, Text/Charset.utf_8())

    /// TODO - there's scope for a robust parser that doesn't interpret the initial "header" lines and 
    /// just interprets the last one for column headings.

    pub def transferFileParser(): Parser[t1, TransferFile] = 
        use FlixParsec/Prim.{flatMap};
        let* hdr = pHeader();
        let* sel = alt(pSelection(), pEmptySelection());        
        let* cols = pColumnHeaders();
        let* rows = manyTill(pDataRow(), endOfInput());
        return({fileHeader = hdr, selection = sel, headers = cols, dataRows = rows})



    def pHeader(): Parser[t1, FileHeader] = 
        use FlixParsec/Prim.{flatMap};
        let* ft     = pFileType();
        let* dm     = pDataModel();
        let* et     = pEntityType();
        let* v      = pVariant();
        let* u      = pUser();
        let* dt     = pDateTime();
        return({ fileType = ft, dataModel = dm, entityType = et
               , variant = v, user = u, dateTime = dt})

                    
    def asterisk(): Parser[t1, Unit] =  
        symbol("*") |> ignore
    


    def pFileType(): Parser[t1, FileType] = 
        use FlixParsec/Prim.{flatMap};
        let body = () -> {
            choice( 
                   (symbol("Download")  `seqRight` return(Download))
                :: (symbol("Upload")    `seqRight` return(Upload))
                :: Nil
            )
        };
        let* _ = asterisk();
        body()
        

    def pDataModel(): Parser[t1, DataModel] = 
        use FlixParsec/Prim.{flatMap};
        let body = () -> symbol("U1") `seqRight` return(U1);
        let* _ = symbol("* Data Model:"); 
        body()
        

    def pEntityType(): Parser[t1, EntityType] =
        use FlixParsec/Prim.{flatMap};
        let body = () -> {
            let* s = lexeme(lookingAts("\\p{Upper}+"));
            match s {
                case "FUNCLOC"      => return(FuncLoc)
                case "CLASSFLOC"    => return(ClassFloc)
                case "VALUAFLOC"    => return(ValuaFloc)
                case "IFLOTX"       => return(Iflotx)
                case "EQUI"         => return(Equi)
                case "CLASSEQUI"    => return(ClassEqui)
                case "VALUAEQUI"    => return(ValuaEqui)
                case "EQMLTXT"      => return(Eqmltxt)
                case _              => fail("EntityType")
            }
        };
        let* _ = symbol("* Entity Type:");
        body()

    def pVariant(): Parser[t1, String] = 
        use FlixParsec/Prim.{flatMap};
        let* _ = string("* Variant:");      // use `string` so we don't consume newline
        let* ans = restOfLine(true);
        return(String.trim(ans))
    
    def pUser(): Parser[t1, String] =
        use FlixParsec/Prim.{flatMap};
        let* _ = symbol("* User:");
        let* ans = restOfLine(true);
        return(String.trim(ans))

    def pDateTime(): Parser[t1, LocalDateTime] = 
        use FlixParsec/Prim.{flatMap, liftOption};
        let* d = symbol("* Date:")  `seqRight` lexeme(lookingAts("\\d{8}"));
        let* t = symbol("/ Time:")  `seqRight` lexeme(lookingAts("\\d{6}"));
        let* fmt = liftOption(Time/Format/DateTimeFormatter.ofPattern("yyyyMMdd HHmmss"), "pDateTime");
        let* ans = liftOption(Time/LocalDateTime.parse(fmt, d + " " + t), "pDateTime");
        return(ans)

    def pEmptySelection(): Parser[t1, List[String]] = 
        return(Nil)

    def pSelection(): Parser[t1, List[String]] = 
        use FlixParsec/Prim.{flatMap};
        let* _ = pSelectionHeader();
        let* xs = pSelectionLines();
        return(xs)

    def pSelectionHeader(): Parser[t1, Unit] = 
        symbol("* Selection:") |> ignore         // blank header, consumes newline
        


    def pSelectionLines(): Parser[t1, List[String]] = 
        use FlixParsec/Prim.{flatMap};
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
    def pColumnHeaders(): Parser[t1, Headers] = 
        use FlixParsec/Prim.{flatMap};
        let* _ = asterisk();
        let* nl = makePattern("\\R");
        let* str = restOfLine(true) |> map(s -> Text/Regex.replace(nl, "", s));
        let* arr = liftAction(_ -> String.splitOn({substr = Char.toString('\u0009')}, str) |> List.toArray);
        return(arr)

    
    /// Note - datarows are `sepEndBy` tab, hence dropRight(1)
    /// Also use `splitOn` rather than `split` because `split` coalesces adjacent splitters
    def pDataRow(): Parser[t1, DataRow] = 
        use FlixParsec/Prim.{flatMap};
        use FlixParsec/Regex.{lookingAt};
        let* tabnl  = makePatternWithFlags(".+?\\u0009\\R", Text/Regex/Pattern/Flag.Dotall :: Nil);
        let* str    = lookingAt(tabnl);
        let* arr    = liftAction(_ -> String.splitOn({substr = Char.toString('\u0009')}, str) |> List.toArray |> Array.dropRight(1));
        return(arr)

}
