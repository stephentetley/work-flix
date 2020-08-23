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

use FactIO.CsvExport;
use FactIO.CsvRowWriter;

use AssetLib/S4/FileIO/EntityFile/Datatypes.{EntityData, Headers, DataRow};
use AssetLib/S4/FileIO/EntityFile/Datatypes.EntityData.{EntityData};
use AssetLib/S4/FileIO/EntityFile/Datatypes.Headers.{Headers};
use AssetLib/S4/FileIO/EntityFile/Datatypes.DataRow.{DataRow};


namespace AssetLib/S4/FileIO/EntityFile/ExportCsv {

        
    pub def exportCsv(rowWriter: r -> CsvExport[Unit], x: EntityData[r], path: System.FilePath): Result[Unit, System.Error] & Impure =
        use Result.{flatMap};
        use FactIO/CsvExport.{runCsvExport, traverseX};
        let EntityData(x1) = x;
        let Headers(headers) = x1.headers;
        let* _ = runCsvExport(traverseX(rowWriter, x1.dataRows), path, FactIO/CsvFormat.default(), headers, Text/Charset.utf_8());
        Ok()


    pub def writeDataRow(row: DataRow): CsvExport[Unit] = 
        use FactIO/CsvExport.{writeLine};
        let DataRow(row1) = row;
        writeLine(row1)



}