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
    
use Time.LocalDate;
use System.Error.{Generic};

use TextParser.Parser;
use TextParser.{return, map, bounded, parseError, tryparse, endOfInput};
use TextParser/Combinators.{liftResult, seqRight, tuple2, choice, many1Till, ignore};
use TextParser/Text.{whiteSpace, lookingAts, skip1OneOf, content, restOfLine, peekRestOfLine};
use TextParser/Token.{symbol, lexeme};

use S4Lib/IH06Tree/Datatypes.{IH06File, Header, IH06Row, FlocRow, EquiRow};
use S4Lib/IH06Tree/Datatypes.IH06Row.{FlocRow, EquiRow};

namespace S4Lib/IH06Tree/Parser {

    pub def funcloc(): Parser[String] = 
        lookingAts("[A-Z]{1}([A-Z0-9]|\-)*") |> lexeme

    def dateStamp(): Parser[LocalDate] = 
        use TextParser.flatMap;
        let* s = lookingAts("\d{2}\.\d{2}\.\d{2}");
        let* fmt = liftResult(Time/Format/DateFormatter.fromPattern("dd.MM.yy"));
        let* ans = liftResult(Time/LocalDate.parse(s, fmt));
        return(ans)

    def validFrom(): Parser[LocalDate] = 
        symbol("Valid From") `seqRight` lexeme(dateStamp())

    def indenting(): Parser[Unit] = 
        lookingAts("(\||\-|\s)+") |> ignore
    
    def equipmentId(): Parser[String] = 
        lookingAts("\$?\d+")

    def funcLocHeaderLine(): Parser[(String, LocalDate)] = 
        use TextParser.flatMap;
        let* _ = symbol("Functional Location");
        let* floc = funcloc();
        let* dt = validFrom();
        return((floc, dt))

    def descriptionHeaderLine(): Parser[String] = 
        symbol("Description") `seqRight` map(String.trim, restOfLine(true))


    def header(): Parser[Header] = 
        use TextParser.flatMap;
        let* (floc, date) = funcLocHeaderLine();
        let* desc = descriptionHeaderLine();
        let* _ = restOfLine(true);      // one blank line
        return({ floc = floc, description = desc, validForm = date })

    /// May or may not contain a parent floc
    def flocLine(): Parser[FlocRow] = 
        use TextParser.flatMap;
        let* _ = indenting();        
        let* floc = bounded(41, funcloc());
        let* rest = peekRestOfLine() |> map(String.length);
        if (rest <= 41)
            flocLine2(floc)
        else
            flocLine3(floc)


    def flocLine2(floc: String): Parser[FlocRow] = 
        use TextParser.flatMap;
        let* desc = restOfLine(true) |> map(String.trim);
        return({ floc = floc, description = desc, parent = None })
        

    def flocLine3(floc: String): Parser[FlocRow] = 
        use TextParser.flatMap;
        let* desc = content(41);
        let* parent = restOfLine(true) |> map(String.trim);
        return({ floc = floc, description = desc, parent = Some(parent) })
    
    def equiLine(): Parser[EquiRow] = 
        use TextParser.flatMap;
        let* _ = indenting();   
        let* equiId = bounded(19, equipmentId());
        let* desc = content(41);
        let* rest = peekRestOfLine() |> map(String.length);
        if (rest <= 41)
            equiLine3(equiId, desc)
        else
            equiLine4(equiId, desc)


    def equiLine3(equiId: String, desc: String): Parser[EquiRow] = 
        use TextParser.flatMap;
        let* floc = restOfLine(true) |> map(String.trim);
        return({ equiId = equiId, description = desc, floc = floc, superordinate = None })


    def equiLine4(equiId: String, desc: String): Parser[EquiRow] = 
        use TextParser.flatMap;
        let* floc = content(41);
        let* supero = restOfLine(true) |> map(String.trim);
        return({ equiId = equiId, description = desc, floc = floc, superordinate = Some(supero) })

    def ih06Row(): Parser[IH06Row] = 
        choice(    (equiLine() |> map(EquiRow))
                :: (flocLine() |> map(FlocRow))
                :: Nil
            )

    
    pub def ih06FileParser(): Parser[IH06File] = 
        use TextParser.flatMap;
        let* h1 = header();
        let* rows = many1Till(ih06Row(), endOfInput());
        return({ header = h1, rows = rows })

    /// Always UTF-8?
    pub def parseFile(path: String) : Result[IH06File, System.Error] & Impure = 
        let path1 = System/FilePath.new(path);
        match TextParser.parseFile(ih06FileParser(), path1, Text/Charset.utf_8() ) { 
            case Err(e) => Err(Generic(TextParser/Error.showParserError(e)))
            case Ok(a) => Ok(a)
        }


 }