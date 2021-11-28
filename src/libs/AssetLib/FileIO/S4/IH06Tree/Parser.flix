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


namespace AssetLib/FileIO/S4/IH06Tree/Parser {

    use Time.LocalDate;

    use FlixParsec.Parser;
    use FlixParsec/Prim.{point, map, swapError, bounded, parseError,  tryparse, endOfInput, liftResult, liftOption};
    use FlixParsec/Regex.{lookingAts};
    use FlixParsec/Combinators.{tuple2, many1Till, seqRight, ignore, choice};
    use FlixParsec/Text.{whiteSpace,  skip1OneOf, content, restOfLine, peekRestOfLine};
    use FlixParsec/TokenSimple.{symbol, lexeme};

    use AssetLib/FileIO/S4/IH06Tree/Datatypes.{IH06File, Header, IH06Row, FlocRow, EquiRow};
    use AssetLib/FileIO/S4/IH06Tree/Datatypes.IH06Row.{FlocRow, EquiRow};

    /// Always UTF-8? No need to handle utf8+BOM...
    pub def parseFile(path: System.FilePath, cs: Text.Charset) : Result[IH06File, String] & Impure = 
        FlixParsec/Extras.parsesFile(ih06FileParser(), 4, path, cs) 

    pub def parseFileWithBOM(path: System.FilePath) : Result[IH06File, String] & Impure = 
        FlixParsec/Extras.parsesFileWithBOM(ih06FileParser(), 4, path) 


    pub def ih06FileParser(): Parser[t1, IH06File] = 
        use FlixParsec/Prim.{flatMap};
        let* h1 = header();
        let* rows = many1Till(ih06Row(), endOfInput());
        point({ header = h1, rows = rows })

    def header(): Parser[t1, Header] = 
        use FlixParsec/Prim.{flatMap};
        let* (floc, date) = funcLocHeaderLine();
        let* desc = descriptionHeaderLine();
        let* _ = restOfLine(true);      // one blank line
        point({ floc = floc, description = desc, validForm = date })

    def ih06Row(): Parser[t1, IH06Row] = 
        use FlixParsec/Prim.{flatMap};
        let* _ = indenting(); 
        choice(    (equiLine() |> map(EquiRow))
                :: (flocLine() |> map(FlocRow))
                :: Nil
            ) // `swapError` "ih06Row"


    /// May or may not contain a parent floc
    def flocLine(): Parser[t1, FlocRow] = 
        use FlixParsec/Prim.{flatMap};
        let* floc = bounded(41, funcloc());
        let* rest = peekRestOfLine() |> map(String.length);
        if (rest <= 41)
            flocLine2(floc)
        else
            flocLine3(floc)

    def flocLine2(floc: String): Parser[t1, FlocRow] = 
        use FlixParsec/Prim.{flatMap};
        let* desc = restOfLine(true) |> map(String.trim);
        point({ floc = floc, description = desc, parent = "" })
        

    def flocLine3(floc: String): Parser[t1, FlocRow] = 
        use FlixParsec/Prim.{flatMap};
        let* desc = content(41);
        let* parent = restOfLine(true) |> map(String.trim);
        point({ floc = floc, description = desc, parent = parent })
    
    def equiLine(): Parser[t1, EquiRow] = 
        use FlixParsec/Prim.{flatMap};
        let* equiId = bounded(19, equipmentId());
        let* desc = content(41);
        let* rest = peekRestOfLine() |> map(String.length);
        if (rest <= 41)
            equiLine3(equiId, desc)
        else
            equiLine4(equiId, desc)


    def equiLine3(equiId: String, desc: String): Parser[t1, EquiRow] = 
        use FlixParsec/Prim.{flatMap};
        let* floc = restOfLine(true) |> map(String.trim);
        point({ equiId = equiId, description = desc, floc = floc, superordinate = "" })


    def equiLine4(equiId: String, desc: String): Parser[t1, EquiRow] = 
        use FlixParsec/Prim.{flatMap};
        let* floc = content(41);
        let* supero = restOfLine(true) |> map(String.trim);
        point({ equiId = equiId, description = desc, floc = floc, superordinate = supero })


    def validFrom(): Parser[t1, LocalDate] = 
        symbol("Valid From") `seqRight` lexeme(dateStamp())

    def indenting(): Parser[t1, Unit] = 
        ignore(lookingAts("(\\||\\-|\\s)+")) `swapError` "indenting"
    
    def equipmentId(): Parser[t1, String] = 
        lookingAts("\\$?\\d+") `swapError` "equipmentId"

    pub def funcLocHeaderLine(): Parser[t1, (String, LocalDate)] = 
        use FlixParsec/Prim.{flatMap};
        let* _ = symbol("Functional Location");
        let* floc = funcloc();
        let* dt = validFrom();
        point((floc, dt))

    def descriptionHeaderLine(): Parser[t1, String] = 
        symbol("Description") `seqRight` map(String.trim, restOfLine(true))
    
    pub def funcloc(): Parser[t1, String] = 
        (lookingAts("[A-Z]{1}([A-Z0-9]|\\-)*") |> lexeme) `swapError` "funcloc"

    def dateStamp(): Parser[t1, LocalDate] = 
        use FlixParsec/Prim.{flatMap};
        let* s = lookingAts("\\d{2}\\.\\d{2}\\.\\d{2}");
        let* fmt = liftOption(Time/Format/DateFormatter.ofPattern("dd.MM.yy"),  "DateFormatter.fromPattern failed");
        let* ans = liftOption(Time/LocalDate.parse(fmt, s), "LocalDate.parse failed");
        point(ans)


 }