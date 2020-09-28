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

namespace AutoLifting/Common {

    pub def getEquiNameFromCommonName(commonName: String): Result[String, System.Error] & Impure = 
        use Text/Regex.{evalContains};
        use Text/Regex/MatchEvaluator.{getCaptureNamed};
        use Result.flatMap;
        let* patt = Text/Regex/Pattern.compile("LIFTING EQUIPMENT/(?<name>.*)/EQUIPMENT");
        evalContains(commonName, patt, getCaptureNamed("name"))
        

    pub def getEquiTypeFromCommonName(commonName: String): Result[String, System.Error] & Impure = 
        use Text/Regex.{evalContains};
        use Text/Regex/MatchEvaluator.{getCaptureNamed};
        use Result.flatMap;
        let* patt = Text/Regex/Pattern.compile("LIFTING EQUIPMENT/.*/(?<name>EQUIPMENT: .*)");
        evalContains(commonName, patt, getCaptureNamed("name"))

    ///
    /// Only proper-cases words made solely of letters, it should not proper-case codes like "SAB0665"
    /// 
    pub def toProperCase(s: String): Result[String, System.Error] & Impure = 
        use Result.flatMap;        
        use Text/Regex/MatchEvaluator.{lift2, getCaptureNamed};
        let* patt = Text/Regex/Pattern.compile("\b(?<first>\p{IsAlphabetic})(?<rest>\p{IsAlphabetic}*)\b");
        let eval = lift2((c,rs) -> String.toUpperCase(c) + String.toLowerCase(rs)
                        , getCaptureNamed("first")
                        , getCaptureNamed("rest")
                        );
        Text/Regex.rewriteWith(s, patt, eval)
        

}