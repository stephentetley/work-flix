/*
 * Copyright 2021 Stephen Tetley
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

namespace ValveReport/Relations {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;
    use AssetLib/GenS4/UxlRelations.{EquiSortOrder};

    pub rel ValveWorkItem(aibref: String, 
                            s4Name: String, 
                            s4Floc: String, 
                            superEqui: String, 
                            s4Category: String, 
                            s4EquiType: String, 
                            s4EquiClass: String)


    /// This is a (equipment specific) "AibFact"...
    /// sizeMillimeters may not have been specified so has to be an Option
    pub rel ValveAttribs(aibref: String, valveType: String, sizeMillimeters: Option[Float64], locationOnSite: String)


    /// Read from Aib xlsx export file...
    pub def readWorkItemData(sheetName: String, 
                                path: System.FilePath): Result[#{EquiSortOrder, ValveWorkItem | r}, String] & Impure =
        SheetIO/SheetReader.runXlsx(readWorkItemsSheet(sheetName), path)
        

    pub def readWorkItemsSheet(sheetName: String): SheetReader[#{EquiSortOrder, ValveWorkItem | r}] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, allNamedRows};         
        let* s1     = getSheetNamed(sheetName);
        let* xs     = allNamedRows(s1, evalValveWorkItemRow());
        let relns   = List.foldLeft((ac, x) -> ac <+> x, #{}, xs);
        return(relns)


    def evalValveWorkItemRow(): NamedRowEvaluator[#{EquiSortOrder, ValveWorkItem | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, map, getRowNum, getContentNamed}; 
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7, x8) -> 
                if (String.isEmpty(x3) or String.isEmpty(x4)) 
                    #{} 
                else #{ 
                    EquiSortOrder(x2, x1).
                    ValveWorkItem(x2, x3, x4, x5, x6, x7, x8). 
                })
            <&> getRowNum()
            <*> getContentNamed("Reference")
            <*> map(String.trim, getContentNamed("S4 Equi Name"))
            <*> map(String.trim, getContentNamed("S4 Floc"))
            <*> map(String.trim, getContentNamed("Super Equi"))
            <*> map(String.trim, getContentNamed("S4 Category"))
            <*> map(String.trim, getContentNamed("Equi Type"))
            <*> map(String.trim, getContentNamed("Equi Class"))



}
