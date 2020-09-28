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

namespace AutoLifting/WorkList {
    
    use AssetLib/Aib/FileIO/AideChangeSummary/Datatypes.AibExportRow;

    type alias EquiWorkItem = 
        { equiName: String
        , equiType: String
        }



    pub def getWorkList(path: System.FilePath): Result[List[EquiWorkItem], System.Error] & Impure =        
        use Result.flatMap; 
        let* xs = AssetLib/Aib/FileIO/AideChangeSummary/XlsxReader.readFile(path) |> Result.map(List.filterMap(childNew));
        let _   = Console.printLine("Length1 = ${Int32.toString(List.length(xs))}");
        Result.traverse(makeWorkItem, xs)

    def childNew(x: AibExportRow): Option[AibExportRow] =  
        if (x.change == "Child New" && String.startsWith(x.reference, "PLI"))
            Some(x)
        else 
            None

    def makeWorkItem(x: AibExportRow): Result[EquiWorkItem, System.Error] & Impure = 
        use AutoLifting/Common.{getEquiNameFromCommonName, getEquiTypeFromCommonName};
        use Result.flatMap;
        let* name = getEquiNameFromCommonName(x.assetName);
        let* typ = getEquiTypeFromCommonName(x.assetName);
        Ok({ equiName = name, equiType = typ})

}