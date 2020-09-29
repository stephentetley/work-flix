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

namespace AutoLifting/Phase1ParentRef {

    use AutoLifting.ReportMonad;
    use AutoLifting/Datatypes.{EquiWorkItem1, EquiWorkItem2};

    use AssetLib/Aib/FileIO/AideChangeSummary/Datatypes.AibExportRow;
    
    /// Use a Map rather than Datalog for this because it is so simple


    pub def loadSaiReferenceTable(path: System.FilePath): ReportMonad[Map[String, String]] =
        use AutoLifting/ReportMonad.{return, flatMap, liftActionResult}; 
        let* xs = liftActionResult(_ -> AssetLib/Aib/FileIO/AideChangeSummary/XlsxReader.readFile(path));
        let ans = buildAssetReferences(xs);
        return(ans)

    pub def updateParentReferences(m: Map[String, String], xs: List[EquiWorkItem1]): ReportMonad[List[EquiWorkItem2]] = 
        AutoLifting/ReportMonad.mapM(updateParentReference1(m), xs)

    pub def updateParentReference1(m: Map[String, String], x: EquiWorkItem1): ReportMonad[EquiWorkItem2] = 
        use AutoLifting/ReportMonad.{throwError, return};
        match Map.get(x.parentName, m) {
            case None => throwError("updateParentReference - No parent for ${x.aibEquiName}")
            case Some(sai) => { 
                let x1 = { -parentName | x }; 
                return({ +parentSaiReference = sai | x1 })
            }
        }

    def buildAssetReferences(xs: List[AibExportRow]): Map[String, String] = 
        List.foldLeft((ac, x) ->  insertStep(x, ac), Map.empty(), xs)


    def insertStep(x: AibExportRow, ac: Map[String, String]): Map[String, String] = 
        if (String.startsWith(x.reference, "PLI"))
            ac
        else 
            Map.insert(String.trim(x.assetName), String.trim(x.reference), ac)



}
