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



namespace AssetLib/S4/Base/Utils {

    pub def getIntSuffix(s: String): Option[Int32] & Impure = 
        use Option.{flatMap};
        let* patt = Result.toOption(Text/Regex/Pattern.compile("[A-Z]{3}(?<idx>\d{2})$"));
        let eval = Text/Regex/MatchEvaluator.getInt32Named("idx");
        Result.toOption(Text/Regex.evalContains(s, patt, eval))


    pub def getFlocIndex(leaf: String, s: String): Option[Int32] & Impure = 
        use Option.{flatMap};
        let* patt = Result.toOption(Text/Regex/Pattern.compile("${leaf}{3}(?<idx>\d{2})"));
        let eval = Text/Regex/MatchEvaluator.getInt32Named("idx");
        Result.toOption(Text/Regex.evalContains(s, patt, eval))

}    