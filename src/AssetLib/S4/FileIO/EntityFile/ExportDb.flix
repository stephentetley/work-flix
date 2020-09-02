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

use FactIO.JdbcExport;
use FactIO.JdbcRowWriter;

use AssetLib/S4/FileIO/EntityFile/Datatypes.{EntityData, Headers};
use AssetLib/S4/FileIO/EntityFile/Datatypes.EntityData.{EntityData};
use AssetLib/S4/FileIO/EntityFile/Datatypes.Headers.{Headers};
use AssetLib/S4/FileIO/EntityFile/Datatypes.DataRow.{DataRow};


namespace AssetLib/S4/FileIO/EntityFile/ExportDb {

    type alias ExportParams[row] = 
        { tableName: String
        , createTableSql: String
        , insertSql: String
        , writeRow: row -> JdbcRowWriter[Unit]
        }




    pub def exportDb(params: ExportParams[r], x: EntityData[r], outpath: System.FilePath): Result[Unit, System.Error] & Impure =         
        use FactIO/JdbcExport.{runSQLiteExport};
        runSQLiteExport(writeOutput(params, x), outpath)
        
    def writeOutput(params: ExportParams[r], x: EntityData[r]): JdbcExport[Unit] =
        use FactIO/JdbcExport.{flatMap, return, setAutoCommit, execute, prepareStatement, mapRowWriterX, commit, close, liftAction};
        let* _      = setAutoCommit(false);
        let* _      = liftAction(_ -> Console.printLine(params.tableName + "..."));
        let* _      = addEntityData(params, x);
        let* _      = close();
        return()

    pub def addEntityData(params: ExportParams[r], x: EntityData[r]): JdbcExport[Unit] =
        use FactIO/JdbcExport.{flatMap, return, setAutoCommit, execute, prepareStatement, mapRowWriterX, commit, close, liftAction};
        let EntityData(x1) = x;
        let* _      = execute("DROP TABLE IF EXISTS " + params.tableName);
        let* _      = execute(params.createTableSql);
        let* stmt   = prepareStatement(params.insertSql);
        let* _      = mapRowWriterX(stmt, params.writeRow, x1.dataRows);
        let* _      = commit();
        return()


}