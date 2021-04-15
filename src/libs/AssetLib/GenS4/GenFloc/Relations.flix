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

namespace AssetLib/GenS4/GenFloc/Relations {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;


    pub rel FlocWorkItem(funcloc: String, 
                        description: String, 
                        level: Int32, 
                        objectType: String, 
                        systemClass: String,        /// Level 5 flocs only
                        systemType: String,         /// Level 5 flocs only
                        gridRef: String
                        )

    

    /// Read from Aib xlsx export file...
    pub def readWorkItemData(sheetName: String, 
                                path: System.FilePath): Result[#{FlocWorkItem| r}, String] & Impure =
        SheetIO/SheetReader.runXlsx(readWorkItemsSheet(sheetName), path)
        

    pub def readWorkItemsSheet(sheetName: String): SheetReader[#{FlocWorkItem| r}] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, allNamedRows};         
        let* s1     = getSheetNamed(sheetName);
        let* xs     = allNamedRows(s1, evalValveWorkItemRow());
        let relns   = List.foldLeft((ac, x) -> ac <+> x, #{}, xs);
        return(relns)


    def evalValveWorkItemRow(): NamedRowEvaluator[#{FlocWorkItem| r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, map, getContentNamed}; 
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6) -> 
                if (String.isEmpty(x1) or String.isEmpty(x2)) 
                    #{} 
                else {
                    let ofloc = AssetLib/S4/Base/Floc.new(x1);
                    let level = Option.getWithDefault(Option.map(AssetLib/S4/Base/Floc.level, ofloc), 0);
                    #{ FlocWorkItem(x1, x2, level, x3, x4, x5, x6). }
                })                    
            <&> map(String.trim, getContentNamed("Functional Location"))
            <*> map(String.trim, getContentNamed("Description"))
            <*> map(String.trim, getContentNamed("Object Type"))
            <*> map(String.trim, getContentNamed("System Class"))
            <*> map(String.trim, getContentNamed("System Type"))
            <*> map(String.trim, getContentNamed("NGR"))



}
