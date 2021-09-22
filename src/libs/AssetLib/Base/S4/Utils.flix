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



namespace AssetLib/Base/S4/Utils {


    pub def printS4Date(x: Time.LocalDate): String = 
        match Time/Format/DateFormatter.ofPattern("dd.MM.yyyy") { 
            case Some(fmt) => Time/LocalDate.format(x, fmt)
            case None => bug!("printS4Date format string")
        }


    pub def getIntSuffix(s: String): Option[Int32] & Impure = 
        use Option.{flatMap};
        let* patt = Text/Regex/Pattern.compile("[A-Z]{3}(?<idx>\\d{2})$") |> Result.toOption;
        let eval = Text/Regex/MatchEvaluator.getInt32Named("idx");
        Result.toOption(Text/Regex.evalContains(patt, eval, s))


    pub def getFlocIndex(leaf: String, s: String): Option[Int32] & Impure = 
        use Option.{flatMap};
        let* patt = Text/Regex/Pattern.compile("${leaf}{3}(?<idx>\\d{2})") |> Result.toOption;
        let eval = Text/Regex/MatchEvaluator.getInt32Named("idx");
        Result.toOption(Text/Regex.evalContains(patt, eval, s))

}    