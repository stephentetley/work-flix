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

use FactIO.{CsvWriter};
use FactIO/CsvExport.{new => newCsvWriter, writeRow, close};

use S4Lib/ChangeFile/Datatypes.{Headers, DataRow, ChangeFile};
use S4Lib/ChangeFile/Datatypes.Headers.{Headers};
use S4Lib/ChangeFile/Datatypes.DataRow.{DataRow};


namespace S4Lib/ChangeFile/ExportCsv {

    def getHeaderArray(x: ChangeFile): Array[String] & Impure = 
        let Headers(xs) = x.headers;
        List.toArray(xs)

    def getRowArray(x: DataRow): Array[String] & Impure = 
        let DataRow(xs) = x;
        List.toArray(xs)

    def writeRows(writer: CsvWriter, rows: List[DataRow]): Result[Unit, String] & Impure = 
        use Result.flatMap;
        match rows {
            case Nil => Ok()
            case x :: rs => {
                let row1 = getRowArray(x);
                let* _ = writeRow(writer, row1);
                writeRows(writer, rs)
            }
        }
        
    pub def exportCsv(x: ChangeFile, path: String): Result[Unit, String] & Impure =
        use Result.flatMap;
        let headers = x.getHeaderArray();
        let* writer = newCsvWriter(path, Text/Charset.utf_8(), headers);
        let _ = Console.printLine("wrote Header...");
        let* _ = writeRows(writer, x.dataRows);
        let _ = writer.close();
        Ok()

}