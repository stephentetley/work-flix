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

namespace AutoLifting/Phase1/SiteMapping {

    use AutoLifting.ReportMonad;
    use AutoLifting/Datatypes.{EquiWorkItem2, EquiWorkItem3};

    use AssetLib/Aib/FileIO/AideChangeSummary/Datatypes.AibExportRow;
    use SheetIO.SheetReader;
    use SheetIO.NamedRowEvaluator;
    
    /// Use a Map rather than Datalog for this because it is so simple
    
    pub def updateSiteCodes[r](m: Map[String, String], 
                               xs: List[{aibSiteName: String, aibEquiName: String | r}]): ReportMonad[List[{s4SiteCode: String, aibEquiName: String | r}]] = 
        AutoLifting/ReportMonad.mapM(updateSiteCode1(m), xs)

    def updateSiteCode1[r](m: Map[String, String], 
                           x: {aibSiteName: String, aibEquiName: String | r}): ReportMonad[{s4SiteCode: String, aibEquiName: String | r}] = 
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
        let* ans    = liftActionResult(_ -> SheetIO/SheetReader.runXlsx(readSiteMapTable(), path));
        return(ans)

    def readSiteMapTable(): SheetReader[Map[String, String]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, allNamedRows};      
        let* s1     = getSheetNamed("inst to SAP migration");
        let* xs     = allNamedRows(s1, evalSiteMapRow());
        let m1      = buildSitesMap(xs);
        return(m1)


    def buildSitesMap(xs: List[(String, Option[String])]): Map[String, String] = 
        let add1 = (ac, pair) -> match pair { 
            case (n, Some(v)) => Map.insert(String.trim(n), String.trim(v), ac)
            case (_, _) => ac
        };
        List.foldLeft(add1, Map.empty(), xs)


    
    def evalSiteMapRow(): NamedRowEvaluator[(String, Option[String])] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, getStringNamed, optional, tuple2};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        tuple2( getStringNamed("AI2_InstallationCommonName")
              , optional(getStringNamed("L1 exists in S4 01/10/2019"))
              )

    /// def logEval(ma: NamedRowEvaluator[String]): NamedRowEvaluator[String] = 
    ///     use SheetIO/NamedRowEvaluator.{flatMap, return, liftAction};
    ///     let* ans = ma;
    ///     let* _ = liftAction(_ -> Console.printLine(ans));
    ///     return(ans)

}
