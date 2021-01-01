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

namespace AutoLifting/Build/ChildNew/DecodeCommonName {

    pub def getAibEquiNameFromCommonName(commonName: String): Option[String] = 
        use Option.{flatMap};
        use Text/Regex.{evalContains};
        use Text/Regex/MatchEvaluator.{getCaptureNamed};
        let* patt = Text/Regex/Pattern.compile("LIFTING EQUIPMENT/(?<name>.*)/EQUIPMENT");
        Text/Regex.evalContains(commonName, patt, getCaptureNamed("name")) as & Pure |> Result.toOption
       
    pub def getS4DescriptionFromCommonName(commonName: String): Option[String] = 
        use Option.{flatMap};
        let* s1   = getAibEquiNameFromCommonName(commonName);
        AutoLifting/Base/Utils.properCaseEquiName(s1)

    pub def getAibEquiTypeFromCommonName(commonName: String): Option[String] = 
        use Option.{flatMap};
        use Text/Regex/MatchEvaluator.{getCaptureNamed};
        let* patt   = Text/Regex/Pattern.compile("LIFTING EQUIPMENT/.*/(?<name>EQUIPMENT: .*)");
        Text/Regex.evalContains(commonName, patt, getCaptureNamed("name")) as & Pure |> Result.toOption
        

    pub def getAibSiteNameFromCommonName(commonName: String): Option[String] = 
        use Option.{flatMap};
        use Text/Regex.{evalStartsWith};
        use Text/Regex/MatchEvaluator.{getCaptureNamed};
        let* patt = Text/Regex/Pattern.compile("(?<name>.*)/STATUTORY/");
        evalStartsWith(commonName, patt, getCaptureNamed("name")) as & Pure |> Result.toOption


    pub def getAibParentNameFromCommonName(commonName: String): Option[String] = 
        use Option.{flatMap};
        use Text/Regex.{evalStartsWith};
        use Text/Regex/MatchEvaluator.{getCaptureNamed};
        let* patt = Text/Regex/Pattern.compile("(?<name>.*)/EQUIPMENT:");
        evalStartsWith(commonName, patt, getCaptureNamed("name")) as & Pure |> Result.toOption

}