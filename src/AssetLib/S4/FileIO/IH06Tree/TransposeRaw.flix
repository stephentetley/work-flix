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
    
use AssetLib/S4/FileIO/IH06Tree/Raw/Datatypes.{SourceType, ClassList, ClassListFile};
use AssetLib/S4/FileIO/IH06Tree/Raw/Builder.{buildIH06Trees};
use AssetLib/S4/FileIO/IH06Tree/Raw/Parser.{parseFile};
use AssetLib/S4/FileIO/IH06Tree/Raw/CsvExport.{exportFlocCsv, exportEquiCsv};

/// Because the text file exports from the master system do not feel 'robust' (charset anomalies, 
/// padding differences, ...) we consider them 'single use' raw input to be transposed to Csv for 
/// 'real use'.

namespace AssetLib/S4/FileIO/IH06Tree/TransposeRaw {

    pub type alias TransposeRawParams = 
        { flocOutpath: System.FilePath
        , equiOutpath: System.FilePath
        }

    pub def transposeRawInput(sourceFile: System.FilePath, params: TransposeRawParams): Result[Unit, System.Error] & Impure = 
        use Result.flatMap;
        let* ast    = parseFile(sourceFile);
        let ans     = buildIH06Trees(ast);
        let* _      = exportFlocCsv(ans, params.flocOutpath);        
        let* _      = exportEquiCsv(ans, params.equiOutpath);
        Ok()

}