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
    use AutoLifting.ReportMonad;
    use AutoLifting/Datatypes.EquiWorkItem;




    pub def getWorkList(path: System.FilePath): ReportMonad[List[EquiWorkItem]] =
        use AutoLifting/ReportMonad.{return, flatMap, liftActionResult, mapM}; 
        let* src = liftActionResult(_ -> AssetLib/Aib/FileIO/AideChangeSummary/XlsxReader.readFile(path));
        let xs   = List.filterMap(childNew, src);
        mapM(makeWorkItem, xs)

    def childNew(x: AibExportRow): Option[AibExportRow] =  
        if (x.change == "Child New" && String.startsWith(x.reference, "PLI"))
            Some(x)
        else 
            None

    def makeWorkItem(x: AibExportRow): ReportMonad[EquiWorkItem] = 
        use AutoLifting/ReportMonad.{return, flatMap};
        use AutoLifting/Common.{getEquiNameFromCommonName, getEquiTypeFromCommonName};        
        let* name   = getEquiNameFromCommonName(x.assetName);
        let* typ    = getEquiTypeFromCommonName(x.assetName);
        return( { equiName      = name
                , equiType      = typ
                , pliReference  = x.reference
                , parentName    = x.newParentName 
                } )

}