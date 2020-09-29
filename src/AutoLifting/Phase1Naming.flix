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

namespace AutoLifting/Phase1Naming {

    use AutoLifting.ReportMonad;
    use AutoLifting/Datatypes.{FixedOrPortable, EquiWorkItem1};
    use AutoLifting/Datatypes.FixedOrPortable.{Fixed, Portable};

    use AssetLib/Aib/FileIO/AideChangeSummary/Datatypes.AibExportRow;

    pub def expandNames(xs: List[AibExportRow]): ReportMonad[List[EquiWorkItem1]] = 
        AutoLifting/ReportMonad.mapM(expandNames1, xs)

    pub def expandNames1(x: AibExportRow): ReportMonad[EquiWorkItem1] = 
        use AutoLifting/ReportMonad.{return, flatMap, liftActionResult};
        let* name       = getAibEquiNameFromCommonName(x.assetName);
        let* typ        = getAibEquiTypeFromCommonName(x.assetName);
        let* s4Name     = liftActionResult(_ -> AutoLifting/Common.toProperCase(name));
        return( { aibEquiName   = name
                , aibEquiType   = typ
                , s4EquiName    = s4Name
                , pliReference  = x.reference
                , parentName    = x.newParentName 
                } )



    def getAibEquiNameFromCommonName(commonName: String): ReportMonad[String] = 
        use Text/Regex.{evalContains};
        use Text/Regex/MatchEvaluator.{getCaptureNamed};
        use Result.flatMap;
        let step = () -> {
            let* patt = Text/Regex/Pattern.compile("LIFTING EQUIPMENT/(?<name>.*)/EQUIPMENT");
            evalContains(commonName, patt, getCaptureNamed("name"))
        };
        AutoLifting/ReportMonad.liftActionResult(step)


    def getAibEquiTypeFromCommonName(commonName: String): ReportMonad[String] = 
        use Text/Regex.{evalContains};
        use Text/Regex/MatchEvaluator.{getCaptureNamed};
        use Result.flatMap;
        let step = () -> {
            let* patt = Text/Regex/Pattern.compile("LIFTING EQUIPMENT/.*/(?<name>EQUIPMENT: .*)");
            evalContains(commonName, patt, getCaptureNamed("name"))
        };
        AutoLifting/ReportMonad.liftActionResult(step)


        

}