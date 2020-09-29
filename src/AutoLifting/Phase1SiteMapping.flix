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

namespace AutoLifting/Phase1SiteMapping {

    use AutoLifting.ReportMonad;
    use AutoLifting/Datatypes.{EquiWorkItem2, EquiWorkItem3};

    use AssetLib/Aib/FileIO/AideChangeSummary/Datatypes.AibExportRow;
    use SheetIO.SheetReader;
    use SheetIO.NamedRowEvaluator;
    
    /// Use a Map rather than Datalog for this because it is so simple
    
    pub def updateSiteCodes(m: Map[String, String], xs: List[EquiWorkItem2]): ReportMonad[List[EquiWorkItem3]] = 
        AutoLifting/ReportMonad.mapM(updateSiteCode1(m), xs)

    pub def updateSiteCode1(m: Map[String, String], x: EquiWorkItem2): ReportMonad[EquiWorkItem3] = 
        use AutoLifting/ReportMonad.{throwError, return};
        match Map.get(x.aibSiteName, m) {
            case None => throwError("updateSiteCode1 - No S$ site for ${x.aibEquiName}")
            case Some(site) => { 
                let x1 = { -aibSiteName | x }; 
                return({ +s4SiteCode = site | x1 })
            }
        }

    pub def loadSiteMapTable(path: System.FilePath): ReportMonad[Map[String, String]] =
        use AutoLifting/ReportMonad.{return, flatMap, liftActionResult}; 
        let* xs = liftActionResult(_ -> SheetIO/SheetReader.runXlsx(readSiteMapTable(), path));
        let ans = buildSitesMap(xs);
        return(ans)

    pub def readSiteMapTable(): SheetReader[List[(String, String)]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheet, allNamedRows};      
        let* s1     = getSheet("Sheet1");
        let* xs     = allNamedRows(s1, evalSiteMapRow());
        return(xs)


    def buildSitesMap(xs: List[(String, String)]): Map[String, String] = 
        List.foldLeft((ac, pair) -> { let (x,y) = pair; Map.insert(String.trim(x), String.trim(y), ac)}, Map.empty(), xs)


    // Change,Reference,Asset Name,OldParentName,NewParentName
    def evalSiteMapRow(): NamedRowEvaluator[(String, String)] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, getStringNamed, tuple2};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        tuple2( getStringNamed("AI2_InstallationCommonName")
              , getStringNamed("S/4 Hana Floc Lvl1_Code")
              )


}
