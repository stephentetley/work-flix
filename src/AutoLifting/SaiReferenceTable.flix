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

namespace AutoLifting/SaiReferenceTable {

    use AutoLifting/Datatypes.{EquiWorkItem, EquiWorkItem1};

    use AssetLib/Aib/FileIO/AideChangeSummary/Datatypes.AibExportRow;
    
    /// Use a Map rather than Datalog because this is so simple


    pub def getSaiReferenceTable(path: System.FilePath): Result[Map[String, String], System.Error] & Impure =        
        use Result.flatMap; 
        let* xs = AssetLib/Aib/FileIO/AideChangeSummary/XlsxReader.readFile(path);
        let _   = Console.printLine("Length1 = ${Int32.toString(List.length(xs))}");
        let ans = buildAssetReferences(xs);
        Ok(ans)

    pub def getSaiParentReference(x: EquiWorkItem, m: Map[String, String]): Option[String] = 
        Map.get(x.parentName, m)

    pub def updateParentReference(x: EquiWorkItem, m: Map[String, String]): Result[EquiWorkItem1, System.Error] = 
        match Map.get(x.parentName, m) {
            case None => Err(System/Error.Generic("No parent"))
            case Some(sai) => { 
                let x1 = { -parentName | x }; 
                Ok({ +parentSaiReference = sai | x1 })
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
