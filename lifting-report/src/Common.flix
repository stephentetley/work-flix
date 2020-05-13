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


namespace LiftingReport/Common {

    pub def stripQuotes(input: String): String = 
        use Regex/Pattern.{quote, compile};
        use Result.flatMap;
        let step = () -> {
            let* patt = compile(quote(Char.toString('\u0022')));
            let ans = Regex.replace(patt, "", input);
            Ok(ans)
        }; 
        Result.getWithDefault(step() as & Pure, input)

    // Input is a list of names in double quotes separated with semi.
    pub def getQuotedNames(input: String): List[String] = 
        use Regex/Pattern.{quote, compile};
        use Result.flatMap;
        let step = () -> {
            let* patt = compile(quote(";"));
            let xs = Regex.split(patt, input) |> Array.toList |> List.map(stripQuotes) |> List.filter(x -> x != "");
            Ok(xs)
        };
        Result.getWithDefault(step() as & Pure, Nil)

    pub def getEquipmentName(commonName: String): String = 
        use Regex/Match.{findMatch, evaluate};
        use Regex/MatchEvaluator.{getCaptureByName};
        use Result.flatMap;
        let step = () -> {
            let* patt = Regex/Pattern.compile("LIFTING EQUIPMENT/(?<name>.*)/EQUIPMENT");
            let m1 = findMatch(patt, commonName);
            m1.evaluate(getCaptureByName("name"))
        };
        Result.getWithDefault(step() as & Pure, commonName)

    ///
    /// Only proper-cases words made solely of letters, shouldn't proper-case codes like "SAB0665"
    /// 
    pub def toProperCase(s: String): String = 
        use Result.flatMap;        
        use Regex/MatchEvaluator.{lift2, getCaptureByName};
        let step = () -> {
            let* patt = Regex/Pattern.compile("\b(?<first>\p{IsAlphabetic})(?<rest>\p{IsAlphabetic}*)\b");
            let eval = lift2((c,rs) -> String.toUpperCase(c) + String.toLowerCase(rs)
                            , getCaptureByName("first")
                            , getCaptureByName("rest")
                            );
            Regex.replaceWith(patt, eval, s)
        };
        Result.getWithDefault(step() as & Pure, s)



    pub def parseAI2Date (s: String) : Result[Time.LocalDate, Time.Error] = 
        use Result.flatMap;
        use Time/LocalDateTime.{parse, toLocalDate};
        let* patt = Time/Format/DateTimeFormatter.fromPattern("dd/MM/yyyy HH:mm");
        let* dt = parse(s, patt);
        let d = toLocalDate(dt);
        Ok(d)



}