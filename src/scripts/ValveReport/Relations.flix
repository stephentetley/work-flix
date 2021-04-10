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


    pub rel ValveWorkItem(aibref: String, s4Name: String, s4Floc: String)
    
    pub rel ValveAttribs(aibref: String, valveType: String, sizeMillimeters: Option[Float64], locationOnSite: String)


    /// Read from Aib xlsx export file...
    pub def readWorkItemData(sheetName: String, 
                                path: System.FilePath): Result[#{ValveWorkItem| r}, String] & Impure =
        SheetIO/SheetReader.runXlsx(readWorkItemsSheet(sheetName), path)
        

    pub def readWorkItemsSheet(sheetName: String): SheetReader[#{ValveWorkItem| r}] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, allNamedRows};         
        let* s1     = getSheetNamed(sheetName);
        let* xs     = allNamedRows(s1, evalValveWorkItemRow());
        let relns   = List.foldLeft((ac, x) -> ac <+> x, #{}, xs);
        return(relns)


    def evalValveWorkItemRow(): NamedRowEvaluator[#{ValveWorkItem| r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, map, getContentNamed}; 
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3) -> if (String.isEmpty(x2) or String.isEmpty(x3)) #{} else #{ ValveWorkItem(x1, x2, x3). })
            <&> getContentNamed("Reference")
            <*> getContentNamed("S4 Equi Name")
            <*> getContentNamed("S4 Floc")

    /// Read from Aib xlsx export file...
    pub def readValveAttribsData(sheetName: String, 
                                path: System.FilePath): Result[#{ValveAttribs| r}, String] & Impure =
        SheetIO/SheetReader.runXlsx(readValveAttribsSheet(sheetName), path)
        

    pub def readValveAttribsSheet(sheetName: String): SheetReader[#{ValveAttribs| r}] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, allNamedRows};         
        let* s1     = getSheetNamed(sheetName);
        let* xs     = allNamedRows(s1, evalValveAttribsRow());
        let relns   = List.foldLeft((ac, x) -> ac <+> x, #{}, xs);
        return(relns)

    def evalValveAttribsRow(): NamedRowEvaluator[#{ValveAttribs| r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, map, getContentNamed, getOptionFloat64Named}; 
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5) -> { 
                let sizeMM = Option.map(flip(decodeSize, x4), x3);
                #{ ValveWorkItem(x1, x2, sizeMM, x5). }
            })
            <&> getContentNamed("Reference")
            <*> getContentNamed("Valve Type")
            <*> getOptionFloat64Named("Size")
            <*> getContentNamed("Size Units")
            <*> getContentNamed("Location On Site")


    def decodeSize(size: Float64, units: String): Option[Float64] = match units { 
        case "MILLIMETRES" => Some(size)
        case _ => None
    }

}
