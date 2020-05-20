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

use S4Lib/IH06Tree/Datatypes.{IH06File, IH06Row, FlocRow, EquiRow};
use S4Lib/IH06Tree/Datatypes.IH06Row.{FlocRow, EquiRow};


namespace S4Lib/IH06Tree/ExportCsv {

    def headers(): Array[String] & Impure = 
        ["Type", "Floc or EquiId", "Description", "Parent Floc", "Superordinate EquiId"]

    def getFlocRowCells(x: FlocRow): Array[String] & Impure = 
        [ "Floc", x.floc, x.description, Option.getWithDefault(x.parent, ""), "" ]

    def getEquiRowCells(x: EquiRow): Array[String] & Impure = 
        [ "Equi", x.equiId, x.description, x.floc, Option.getWithDefault(x.superordinate, "")]

    def getRowCells(x: IH06Row): Array[String] & Impure = 
        match x {
            case FlocRow(a) => getFlocRowCells(a)
            case EquiRow(b) => getEquiRowCells(b)
        }

    def writeRows(writer: CsvWriter, rows: List[IH06Row]): Result[Unit, System.Error] & Impure = 
        use Result.flatMap;
        match rows {
            case Nil => Ok()
            case x :: rs => {
                let row1 = getRowCells(x);
                let* _ = writeRow(writer, row1);
                writeRows(writer, rs)
            }
        }
        
    pub def exportCsv(x: IH06File, path: String): Result[Unit, System.Error] & Impure =
        use Result.flatMap;
        let* writer = newCsvWriter(path, Text/Charset.utf_8(), headers());
        let* _ = writeRows(writer, x.rows);
        let _ = writer.close();
        Ok()

}