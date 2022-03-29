/*
 * Copyright 2022 Stephen Tetley
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

namespace S4Loader/PDT/BuildDb/FieldEval {

    use Text/RegexEval.MatchEvaluator;

    use RelLib/Lattice/Constant.Constant;
    use RelLib/Lattice/Constant.Constant.{Bottom, Constant};

    def ofOption(x: Option[a]): Constant[a] = match x { 
        case Some(x1) => Constant(x1)
        case None     => Bottom
    }

    def ofResult(x: Result[a, err]): Constant[a] = match x { 
        case Ok(x1) => Constant(x1)
        case Err(_) => Bottom
    }

    pub def stringAny(s: String): Constant[String] = Constant(String.trim(s))

    pub def stringNonEmptyString(s: String): Constant[String] = match String.trim(s) {
        case s1 if String.isEmpty(s1) => Bottom
        case s1                       => Constant(s1)
    }


    pub def stringRegex(r: {patt :: String}, s: String): Constant[String] =
        evalRegex(r, Text/RegexEval/MatchEvaluator.getCaptureNamed("value"), s)


    pub def stringIPRating(s: String): Constant[String] = 
        stringRegex(patt = "(?i)(IP)?\\s*(?<value>\\d{2})\\s*", s)


    /// To improve...
    pub def stringFloc(s: String): Constant[String] = stringNonEmptyString(s)

    /// TODO...
    pub def stringEnum(s: String): Constant[String] = Constant(String.trim(s))

    pub def stringAssetStatus(s: String): Constant[String] = match String.trim(s) {
        case "New"         => Constant("OPER")
        case "Replacement" => Constant("OPER")
        case _             => Bottom
    }

    pub def stringAssetType(s: String): Constant[String] = stringNonEmptyString(s)

    pub def stringManufacturer(s: String): Constant[String] = Constant(s |> String.trim |> String.toUpperCase)


    pub def dateLocalDate(s: String): Constant[Time.LocalDate] =  
        let fmt = Time/Format/DateTimeFormatter.iso_local_date_time();
        Time/LocalDateTime.parse(fmt, s) 
            |> Option.map(Time/LocalDateTime.toLocalDate)
            |> ofOption


    pub def intInteger(s: String): Constant[Int32] = 
        Int32.fromString(s) |> ofResult

    pub def intIntegerWithUnits(r: {unitsName :: String}, s: String): Constant[Int32] = 
        let patt = "(?i)(?<value>\\d+)\\s?(${r.unitsName})?";
        intRegex(patt = patt, s)

    pub def intRegex(r: {patt :: String}, s: String): Constant[Int32] =
        evalRegex(r, Text/RegexEval/MatchEvaluator.getInt32Named("value"), s)



    pub def decimalDecimal(s: String): Constant[Float64] = 
        Float64.fromString(s) |> ofResult

    pub def decimalDecimalWithUnits(r: {unitsName :: String}, s: String): Constant[Float64] = 
        let patt = "(?i)(?<value>\\d+\\.?\\d*)\\s*(${r.unitsName})?";
        decimalRegex(patt = patt, s)

    pub def decimalRegex(r: {patt :: String}, s: String): Constant[Float64] =
        evalRegex(r, Text/RegexEval/MatchEvaluator.getFloat64Named("value"), s)


    def evalRegex(r: {patt :: String}, eval: MatchEvaluator[a], s: String): Constant[a] =
        match Result.flatMap(patt -> Text/RegexEval/Regex.matches(patt, eval, s) as & Pure, Text/Regex/Pattern.compile(r.patt))  {
            case Ok(i)  => Constant(i)
            case Err(_) => Bottom
        }


}
