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

namespace AutoLifting/Phase1/Naming {

    use AssetLib/Aib/FileIO/AideChangeSummary/Datatypes.AibExportRow;

    use AutoLifting/Common.ReportMonad;
    use AutoLifting/Common/Datatypes.{FixedOrPortable, AibWorkItem};
    use AutoLifting/Common/Datatypes.FixedOrPortable.{Fixed, Portable};


    type alias AibNames = 
        { equiName: String
        , equiType: String
        , siteName: String
        }

    pub def getAibNames(x: AibExportRow): ReportMonad[AibNames] = 
        use AutoLifting/Common/ReportMonad.{return, flatMap};
        let* name       = getAibEquiNameFromCommonName(x.assetName);
        let* typ        = getAibEquiTypeFromCommonName(x.assetName);
        let* site       = getAibSiteNameFromCommonName(x.assetName);
        return({ equiName   = name
               , equiType   = typ
               , siteName   = site
               })


    def getAibEquiNameFromCommonName(commonName: String): ReportMonad[String] = 
        use AutoLifting/Common/ReportMonad.{flatMap, liftResult, liftActionResult};
        use Text/Regex.{evalContains};
        use Text/Regex/MatchEvaluator.{getCaptureNamed};
        let* patt = liftResult(_ -> Text/Regex/Pattern.compile("LIFTING EQUIPMENT/(?<name>.*)/EQUIPMENT"));
        liftActionResult(_ -> Text/Regex.evalContains(commonName, patt, getCaptureNamed("name")))
       


    def getAibEquiTypeFromCommonName(commonName: String): ReportMonad[String] = 
        use AutoLifting/Common/ReportMonad.{flatMap, liftResult, liftActionResult};
        use Text/Regex/MatchEvaluator.{getCaptureNamed};
        let* patt = liftResult(_ -> Text/Regex/Pattern.compile("LIFTING EQUIPMENT/.*/(?<name>EQUIPMENT: .*)"));
        liftActionResult(_ -> Text/Regex.evalContains(commonName, patt, getCaptureNamed("name")))
        

    def getAibSiteNameFromCommonName(commonName: String): ReportMonad[String] = 
        use AutoLifting/Common/ReportMonad.{flatMap, liftResult, liftActionResult};
        use Text/Regex.{evalStartsWith};
        use Text/Regex/MatchEvaluator.{getCaptureNamed};
        let* patt = liftResult(_ -> Text/Regex/Pattern.compile("(?<name>.*)/STATUTORY/"));
        liftActionResult(_ -> evalStartsWith(commonName, patt, getCaptureNamed("name")))

}