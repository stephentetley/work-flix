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

    use RelLib/Lattice/Constant.Constant;
    use RelLib/Lattice/Constant.Constant.{Bottom, Constant};

    pub def evalIntRegex(r: {patt :: String}, s: String): Constant[Int32] =
        let eval = Text/RegexEval/MatchEvaluator.getInt32Named("value");
        match Result.flatMap(patt -> Text/RegexEval/Regex.matches(patt, eval, s) as & Pure, Text/Regex/Pattern.compile(r.patt))  {
            case Ok(i)  => Constant(i)
            case Err(_) => Bottom
        }


    pub def evalFloatRegex(r: {patt :: String}, s: String): Constant[Float64] =
        let eval = Text/RegexEval/MatchEvaluator.getFloat64Named("value");
        match Result.flatMap(patt -> Text/RegexEval/Regex.matches(patt, eval, s) as & Pure, Text/Regex/Pattern.compile(r.patt))  {
            case Ok(d)  => Constant(d)
            case Err(_) => Bottom
        }


    pub def evalAny(s: String): Constant[String] = Constant(String.trim(s))

    pub def evalEnum(s: String): Constant[String] = Constant(String.trim(s))

    pub def evalNonEmptyString(s: String): Constant[String] = match String.trim(s) {
        case s1 if String.isEmpty(s1) => Bottom
        case s1                       => Constant(s1)
    }

    /// To improve...
    pub def evalFloc(s: String): Constant[String] = Constant(String.trim(s))


}
