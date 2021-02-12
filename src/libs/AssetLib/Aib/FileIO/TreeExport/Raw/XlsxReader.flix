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

namespace AssetLib/Aib/FileIO/TreeExport/Raw/XlsxReader {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;

    use AssetLib/Aib/FileIO/TreeExport/Raw/Datatypes.{AibTreeFile, AibRow};

    pub def readAibTreeFile(path: System.FilePath): Result[AibTreeFile, String] & Impure =    
        SheetIO/SheetReader.runXlsx(readAibSheet(), path)

    pub def readAibSheet(): SheetReader[List[AibRow]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, allNamedRows};      
        let* s1     = getSheetNamed("Sheet1");
        let* xs     = allNamedRows(s1, evalAibRow());
        return(xs)


    def evalAibRow(): NamedRowEvaluator[AibRow] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getStringNamed}; 
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3) -> 
                { reference     = x1
                , commonName    = x2
                , status        = x3
                })
            <&> getStringNamed("Reference")
            <*> getStringNamed("Common Name")
            <*> getStringNamed("AssetStatus")
        
        

}