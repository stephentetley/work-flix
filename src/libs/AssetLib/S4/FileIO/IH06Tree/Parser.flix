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


namespace AssetLib/S4/FileIO/IH06Tree/Parser {

    use Time.LocalDate;

    use TextParser.TextParser;
    use TextParser.{return, map, swapError, bounded, parseError, choice, seqRight, tryparse, endOfInput, lookingAts, liftResult, liftOption};
    use TextParser/Combinators.{tuple2, many1Till, ignore};
    use TextParser/Text.{whiteSpace,  skip1OneOf, content, restOfLine, peekRestOfLine};
    use TextParser/Token1.{symbol, lexeme};

    use AssetLib/S4/FileIO/IH06Tree/Datatypes.{IH06File, Header, IH06Row, FlocRow, EquiRow};
    use AssetLib/S4/FileIO/IH06Tree/Datatypes.IH06Row.{FlocRow, EquiRow};

    /// Always UTF-8? No need to handle utf8+BOM...
    pub def parseFile(path: System.FilePath, cs: Text.Charset) : Result[IH06File, String] & Impure = 
        TextParser.parsesFile(ih06FileParser(), path, cs) 

    pub def parseFileWithBOM(path: System.FilePath, cs: Text.Charset) : Result[IH06File, String] & Impure = 
        TextParser.parsesFileWithBOM(ih06FileParser(), path, cs) 


    pub def ih06FileParser(): TextParser[IH06File, t] = 
        use TextParser.flatMap;
        let* h1 = header();
        let* rows = many1Till(ih06Row(), endOfInput());
        return({ header = h1, rows = rows })

    def header(): TextParser[Header, t] = 
        use TextParser.flatMap;
        let* (floc, date) = funcLocHeaderLine();
        let* desc = descriptionHeaderLine();
        let* _ = restOfLine(true);      // one blank line
        return({ floc = floc, description = desc, validForm = date })

    def ih06Row(): TextParser[IH06Row, t] = 
        use TextParser.flatMap;
        let* _ = indenting(); 
        choice(    (equiLine() |> map(EquiRow))
                :: (flocLine() |> map(FlocRow))
                :: Nil
            ) // `swapError` "ih06Row"


    /// May or may not contain a parent floc
    def flocLine(): TextParser[FlocRow, t] = 
        use TextParser.flatMap;       
        let* floc = bounded(41, funcloc());
        let* rest = peekRestOfLine() |> map(String.length);
        if (rest <= 41)
            flocLine2(floc)
        else
            flocLine3(floc)

    def flocLine2(floc: String): TextParser[FlocRow, t] = 
        use TextParser.flatMap;
        let* desc = restOfLine(true) |> map(String.trim);
        return({ floc = floc, description = desc, parent = "" })
        

    def flocLine3(floc: String): TextParser[FlocRow, t] = 
        use TextParser.flatMap;
        let* desc = content(41);
        let* parent = restOfLine(true) |> map(String.trim);
        return({ floc = floc, description = desc, parent = parent })
    
    def equiLine(): TextParser[EquiRow, t] = 
        use TextParser.flatMap;
        let* equiId = bounded(19, equipmentId());
        let* desc = content(41);
        let* rest = peekRestOfLine() |> map(String.length);
        if (rest <= 41)
            equiLine3(equiId, desc)
        else
            equiLine4(equiId, desc)


    def equiLine3(equiId: String, desc: String): TextParser[EquiRow, t] = 
        use TextParser.flatMap;
        let* floc = restOfLine(true) |> map(String.trim);
        return({ equiId = equiId, description = desc, floc = floc, superordinate = "" })


    def equiLine4(equiId: String, desc: String): TextParser[EquiRow, t] = 
        use TextParser.flatMap;
        let* floc = content(41);
        let* supero = restOfLine(true) |> map(String.trim);
        return({ equiId = equiId, description = desc, floc = floc, superordinate = supero })


    def validFrom(): TextParser[LocalDate, t] = 
        symbol("Valid From") `seqRight` lexeme(dateStamp())

    def indenting(): TextParser[Unit, t] = 
        ignore(lookingAts("(\||\-|\s)+")) `swapError` "indenting"
    
    def equipmentId(): TextParser[String, t] = 
        lookingAts("\$?\d+") `swapError` "equipmentId"

    pub def funcLocHeaderLine(): TextParser[(String, LocalDate), t] = 
        use TextParser.flatMap;
        let* _ = symbol("Functional Location");
        let* floc = funcloc();
        let* dt = validFrom();
        return((floc, dt))

    def descriptionHeaderLine(): TextParser[String, t] = 
        symbol("Description") `seqRight` map(String.trim, restOfLine(true))
    
    pub def funcloc(): TextParser[String, t] = 
        (lookingAts("[A-Z]{1}([A-Z0-9]|\-)*") |> lexeme) `swapError` "funcloc"

    def dateStamp(): TextParser[LocalDate, t] = 
        use TextParser.flatMap;
        let* s = lookingAts("\d{2}\.\d{2}\.\d{2}");
        let* fmt = liftOption(Time/Format/DateFormatter.fromPattern("dd.MM.yy"),  "DateFormatter.fromPattern failed");
        let* ans = liftOption(Time/LocalDate.parse(s, fmt), "LocalDate.parse failed");
        return(ans)


 }