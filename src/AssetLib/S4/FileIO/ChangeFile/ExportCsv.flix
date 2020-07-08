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

use FactIO/Csv.CsvWriter;
use FactIO/Csv/Export.{new => newCsvWriter, writeRow, close};

use AssetLib/S4/FileIO/ChangeFile/Datatypes.{Headers, DataRow, ChangeFile};
use AssetLib/S4/FileIO/ChangeFile/Datatypes.Headers.{Headers};
use AssetLib/S4/FileIO/ChangeFile/Datatypes.DataRow.{DataRow};


namespace AssetLib/S4/FileIO/ChangeFile/ExportCsv {

        
    pub def exportCsv(x: ChangeFile, path: String): Result[Unit, System.Error] & Impure =
        use Result.flatMap;
        let headers = x.getHeaderArray();
        let* writer = newCsvWriter(path, Text/Charset.utf_8(), headers);
        let* _ = writeRows(writer, x.dataRows);
        let _ = writer.close();
        Ok()


    def getHeaderArray(x: ChangeFile): Array[String] = 
        let Headers(arr) = x.headers;
        arr

    def writeRows(writer: CsvWriter, rows: List[DataRow]): Result[Unit, System.Error] & Impure = 
        use Result.flatMap;
        match rows {
            case Nil => Ok()
            case x :: rs => {
                let row1 = getRowArray(x);
                let* _ = writeRow(writer, row1);
                writeRows(writer, rs)
            }
        }

    def getRowArray(x: DataRow): Array[String] = 
        let DataRow(arr) = x;
        arr


}