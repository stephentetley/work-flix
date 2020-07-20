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

use FactIO.CsvWriter;
use FactIO/CsvExport.{new => newCsvWriter, writeRow, close};

use AssetLib/S4/FileIO/ChangeFile/Datatypes.{PrimChangeFile, Headers, DataRow};
use AssetLib/S4/FileIO/ChangeFile/Datatypes.ChangeFile.{ChangeFile};
use AssetLib/S4/FileIO/ChangeFile/Datatypes.Headers.{Headers};
use AssetLib/S4/FileIO/ChangeFile/Datatypes.DataRow.{DataRow};


namespace AssetLib/S4/FileIO/ChangeFile/ExportCsv {

        
    pub def exportCsv(x: PrimChangeFile, path: String): Result[Unit, System.Error] & Impure =
        use Result.{flatMap, traverseX};
        let ChangeFile(x1) = x;
        let Headers(headers) = x1.headers;
        let* writer = newCsvWriter(path, Text/Charset.utf_8(), headers);
        let* _ = traverseX(writeDataRow(writer), x1.dataRows);
        let _ = writer.close();
        Ok()



    def writeDataRow(writer: CsvWriter, row: DataRow): Result[Unit, System.Error] & Impure = 
        let DataRow(row1) = row;
        writeRow(writer, row1)



}