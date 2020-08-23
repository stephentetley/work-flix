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

use FactIO.SQLiteExport;
use FactIO.SQLiteRowWriter;

use AssetLib/S4/FileIO/EntityFile/Datatypes.{EntityData, Headers};
use AssetLib/S4/FileIO/EntityFile/Datatypes.EntityData.{EntityData};
use AssetLib/S4/FileIO/EntityFile/Datatypes.Headers.{Headers};
use AssetLib/S4/FileIO/EntityFile/Datatypes.DataRow.{DataRow};


namespace AssetLib/S4/FileIO/EntityFile/ExportDb {

    type alias ExportParams[row] = 
        { tableName: String
        , createTableSql: String
        , insertSql: String
        , writeRow: row -> SQLiteRowWriter[Unit]
        }


    // pub def exportDb(x: EntityData, path: System.FilePath): Result[Unit, System.Error] & Impure =
    //     use Result.{flatMap};
    //     use FactIO/CsvExport.{runCsvExport, traverseX};
    //     let ChangeFile(x1) = x;
    //     let Headers(headers) = x1.headers;
    //     let* _ = runCsvExport(traverseX(writeDataRow, x1.dataRows), path, FactIO/CsvFormat.default(), headers, Text/Charset.utf_8());
    //     Ok()


    pub def outputDb(params: ExportParams[r], x: EntityData[r], outpath: System.FilePath): Result[Unit, System.Error] & Impure =         
        use FactIO/SQLiteExport.{runSQLiteExport};
        runSQLiteExport(writeOutput(params, x), outpath)
        
    def writeOutput(params: ExportParams[r], x: EntityData[r]): SQLiteExport[Unit] =
        use FactIO/SQLiteExport.{flatMap, return, setAutoCommit, execute, prepareStatement, mapRowWriterX, close, liftAction};
        let EntityData(x1) = x;
        let* _      = setAutoCommit(false);
        let* _      = execute("DROP TABLE IF EXISTS " + params.tableName);
        let* _      = execute(params.createTableSql);
        let* _      = liftAction(_ -> { Console.printLine(params.tableName + "..."); Ok() });
        let* stmt   = prepareStatement(params.insertSql);
        let* _      = mapRowWriterX(stmt, params.writeRow, x1.dataRows);
        // let* _      = liftAction(_ -> { Console.printLine(Int32.toString(n1)); Ok() });
        let* _      = close();
        return()


}