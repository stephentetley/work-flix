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

use Data/RowReader.RowWithHeadersEvaluator;
use System.FilePath;


use FactIO.SQLiteExport;
use FactIO.SQLiteRowWriter;

use AssetLib/S4/FileIO/EntityFile/ExportDb.{ExportParams};

namespace ShapeShifter/Setup {

    /// Preferable to have each step as a SQLiteExport action then we can share a db handle.

    type alias SetupParams = 
        { ih06File: FilePath 
        , flocDownloadFile: FilePath
        }

    pub def outputDb(params: SetupParams, outpath: System.FilePath): Result[Unit, System.Error] & Impure =         
        use FactIO/SQLiteExport.{runSQLiteExport};
        runSQLiteExport(writeOutput(params), outpath)
        
    def writeOutput(params: SetupParams): SQLiteExport[Unit] =
        use FactIO/SQLiteExport.{flatMap, return, setAutoCommit, close, liftAction};
        let* _      = setAutoCommit(false);
        let* _      = liftAction(_ -> Console.printLine("IH06..."));
        let* _      = addIH06Data(params.ih06File);
        let* _      = liftAction(_ -> Console.printLine("Floc download..."));
        let* _      = addFlocDownloadData(params.flocDownloadFile);
        let* _      = close();
        return()

    def addIH06Data(src: FilePath): SQLiteExport[Unit] = 
        use FactIO/SQLiteExport.{flatMap, return, liftActionResult}; 
        use AssetLib/S4/FileIO/IH06Tree/Raw/Builder.{buildIH06Trees};
        use AssetLib/S4/FileIO/IH06Tree/Raw/Parser.{parseFile};
        use AssetLib/S4/FileIO/IH06Tree/Raw/ExportDb.{addFlocNodes, addEquiNodes};
        let* ast    = liftActionResult(_ -> parseFile(src));
        let ans     = buildIH06Trees(ast);
        let* _      = addFlocNodes(ans);
        let* _      = addEquiNodes(ans);
        return()

    /// Floc data from a "file download"
    type alias FlocRow  = {funcloc: String, structureIndicator: String, objectType: String}

    def addFlocDownloadData(src: FilePath): SQLiteExport[Unit] = 
        use FactIO/SQLiteExport.{flatMap, return, liftActionResult}; 
        use AssetLib/S4/FileIO/EntityFile/Parser.{parseFile};
        use AssetLib/S4/FileIO/EntityFile/Evaluate.{toEntityData};
        use AssetLib/S4/FileIO/EntityFile/ExportDb.{addEntityData};
        let* ast    = liftActionResult(_ -> parseFile(src));
        let* ans    = liftActionResult(_ ->toEntityData(flocHeaders(), evalFlocRow(), ast));
        let* _      = addEntityData(flocExportParams(), ans);
        return()


    def evalFlocRow(): RowWithHeadersEvaluator[FlocRow] = 
        use Data/RowReader/RowWithHeadersEvaluator.{flatMap, return, getString};
        let* floc       = getString("FUNCLOC");
        let* si         = getString("TPLKZ_FLC");    
        let* ot         = getString("EQART");
        return({funcloc = floc, structureIndicator = si, objectType = ot})


    def flocHeaders(): Array[String] & Impure = 
        [ "funcloc", "structure_indicator", "object_type" ]

    /// A RowWriter for FlocRow
    def flocRowWriter(x: FlocRow): SQLiteRowWriter[Unit] = 
        use FactIO/SQLiteRowWriter.{flatMap, return, putString!};
        let* _ = putString!(0,  x.funcloc);
        let* _ = putString!(1,  x.structureIndicator);
        let* _ = putString!(2,  x.objectType);
        return()

    def flocExportParams(): ExportParams[FlocRow] = 
            { tableName = "floc_entity"
            , createTableSql = sqlCreateTableFlocEntity()
            , insertSql = "INSERT INTO floc_entity(funcloc, structure_indicator, object_type) VALUES(?,?,?)"
            , writeRow = flocRowWriter
            }


    def sqlCreateTableFlocEntity(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS floc_entity ("
                :: "funcloc                 TEXT    NOT NULL PRIMARY KEY,"
                :: "structure_indicator     TEXT    NOT NULL,"
                :: "object_type             TEXT    NOT NULL"
                :: ")"
                :: Nil
        )



}