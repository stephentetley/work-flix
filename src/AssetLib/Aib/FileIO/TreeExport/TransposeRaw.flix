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

use AssetLib/Common/ExportHtmlTree.{writeHtmlForest};
use AssetLib/Aib/FileIO/TreeExport/Raw/Datatypes.{AibTreeFile, AibTree};
use AssetLib/Aib/FileIO/TreeExport/Raw/Builder.{buildAibTrees, allTrees};
use AssetLib/Aib/FileIO/TreeExport/Raw/XlsxReader.{readAibTreeFile};
use AssetLib/Aib/FileIO/TreeExport/Raw/CsvExport.{exportAibTreesCsv};



namespace AssetLib/Aib/FileIO/TreeExport/TransposeRaw {



    pub def transposeRawInput(sourceFile: System.FilePath, level: Int32, csvOutpath: System.FilePath): Result[Unit, System.Error] & Impure = 
        use Result.flatMap;
        let* rows   = readAibTreeFile(sourceFile);
        let ans     = buildAibTrees(rows, level);
        let* _      = exportAibTreesCsv(ans, csvOutpath);
        Ok()

    pub def generateHtml(sourceFile: System.FilePath, level: Int32, htmlOutpath: System.FilePath): Result[Unit, System.Error] & Impure = 
        use Result.flatMap;
        let* rows   = readAibTreeFile(sourceFile);
        let ans     = buildAibTrees(rows, level);
        let* _      = writeHtmlForest(htmlOutpath, allTrees(ans));
        Ok()

}