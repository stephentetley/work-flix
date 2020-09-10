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


use FactIO.JdbcExport;
use FactIO.JdbcRowSetter;

use AssetLib/S4/FileIO/EntityFile/ExportDb.{ExportParams};

namespace ShapeShifter/Setup {

    /// Preferable to have each step as a JdbcExport action then we can share a db handle.

    type alias SetupParams = 
        { ih06File: FilePath 
        , hasBOM: Bool
        , flocDownloadFile: FilePath
        , equiDownloadFile: FilePath
        }

    pub def outputDb(params: SetupParams, outpath: System.FilePath): Result[Unit, System.Error] & Impure =         
        use FactIO/JdbcExport.{runSQLiteExport};
        runSQLiteExport(writeOutput(params), outpath)
        
    def writeOutput(params: SetupParams): JdbcExport[Unit] =
        use FactIO/JdbcExport.{flatMap, return, setAutoCommit, close, liftAction};
        let* _      = setAutoCommit(false);
        let* _      = liftAction(_ -> Console.printLine("IH06..."));
        let* _      = addIH06Data(params.ih06File, params.hasBOM);
        let* _      = liftAction(_ -> Console.printLine("Floc download..."));
        let* _      = addFlocDownloadData(params.flocDownloadFile);
        let* _      = liftAction(_ -> Console.printLine("Equi download..."));
        let* _      = addEquiDownloadData(params.equiDownloadFile);
        let* _      = close();
        return()

    def addIH06Data(src: FilePath, hasBOM: Bool): JdbcExport[Unit] = 
        use FactIO/JdbcExport.{flatMap, return, liftActionResult}; 
        use AssetLib/S4/FileIO/IH06Tree/Raw/Builder.{buildIH06Trees};
        use AssetLib/S4/FileIO/IH06Tree/Raw/Parser.{parseFileWithBOM, parseFile};
        use AssetLib/S4/FileIO/IH06Tree/Raw/ExportDb.{addFlocNodes, addEquiNodes};
        let* ast    = liftActionResult(_ -> if (hasBOM) parseFileWithBOM(src, Text/Charset.utf_8()) else parseFile(src, Text/Charset.utf_8()));
        let ans     = buildIH06Trees(ast);
        let* _      = addFlocNodes(ans);
        let* _      = addEquiNodes(ans);
        return()

    /// Floc data from a "file download"
    type alias FlocRow = 
        { funcloc: String
        , structureIndicator: String
        , objectType: String
        , objectStatus: String
        }

    def addFlocDownloadData(src: FilePath): JdbcExport[Unit] = 
        use FactIO/JdbcExport.{flatMap, return, liftActionResult}; 
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
        let* os         = getString("USTW_FLOC");
        return({funcloc = floc, structureIndicator = si, objectType = ot, objectStatus = os})


    def flocHeaders(): Array[String] & Impure = 
        [ "funcloc", "structure_indicator", "object_type", "object_status" ]

    /// A RowSetter for FlocRow
    def flocRowSetter(x: FlocRow): JdbcRowSetter[Unit] = 
        use FactIO/JdbcRowSetter.{flatMap, return, putString!};
        let* _ = putString!(0,  x.funcloc);
        let* _ = putString!(1,  x.structureIndicator);
        let* _ = putString!(2,  x.objectType);
        let* _ = putString!(3,  x.objectStatus);
        return()

    def flocExportParams(): ExportParams[FlocRow] = 
        { tableName = "floc_entity"
        , createTableSql = sqlCreateTableFlocEntity()
        , insertSql = "INSERT INTO floc_entity(funcloc, structure_indicator, object_type, object_status) VALUES(?,?,?,?)"
        , writeRow = flocRowSetter
        }


    def sqlCreateTableFlocEntity(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS floc_entity ("
                :: "funcloc                 TEXT    NOT NULL PRIMARY KEY,"
                :: "structure_indicator     TEXT    NOT NULL,"
                :: "object_type             TEXT    NOT NULL,"
                :: "object_status           TEXT    NOT NULL"
                :: ")"
                :: Nil
        )


    /// Equi data from a "file download"
    type alias EquiRow = 
        { equiId: String
        , objectType: String
        , manufacturer: String
        , serialNumber: String
        , technicalId: String
        , objectStatus: String
        , modelNumber: String
        , partNumber: String
        , equiCategory: String
        }

    def addEquiDownloadData(src: FilePath): JdbcExport[Unit] = 
        use FactIO/JdbcExport.{flatMap, return, liftActionResult, liftAction}; 
        use AssetLib/S4/FileIO/EntityFile/Parser.{parseFile};
        use AssetLib/S4/FileIO/EntityFile/Evaluate.{toEntityData};
        use AssetLib/S4/FileIO/EntityFile/ExportDb.{addEntityData};
        let* _      = liftAction(_ -> Console.printLine("addEquiDownloadData1..."));
        let* ast    = liftActionResult(_ -> parseFile(src));
        let* _      = liftAction(_ -> Console.printLine("addEquiDownloadData2..."));
        let* ans    = liftActionResult(_ -> toEntityData(equiHeaders(), evalEquiRow(), ast));
        let* _      = liftAction(_ -> Console.printLine("addEquiDownloadData3..."));
        let* _      = addEntityData(equiExportParams(), ans);
        return()


    def evalEquiRow(): RowWithHeadersEvaluator[EquiRow] = 
        use Data/RowReader/RowWithHeadersEvaluator.{flatMap, return, getString};
        let* equi       = getString("EQUI");
        let* objType    = getString("EQART_EQU");
        let* manu       = getString("HERST");
        let* serialNum  = getString("SERGE");
        let* techId     = getString("TIDN_EEQZ");
        let* objStatus  = getString("USTW_EQUI");
        let* modelNum   = getString("TYPBZ");
        let* partNum    = getString("MAPA_EEQZ");
        let* equiCat    = getString("EQTYP");
        return({equiId = equi, objectType = objType, manufacturer = manu, 
                serialNumber = serialNum, technicalId = techId, objectStatus = objStatus, 
                modelNumber = modelNum, partNumber = partNum, equiCategory = equiCat})


    def equiHeaders(): Array[String] & Impure = 
        [ "equi_id", "object_type", "manufacturer", "serial_number", "technical_id", "object_status", "model_number", "part_number", "equi_category" ]

    /// A RowSetter for EquiRow
    def equiRowSetter(x: EquiRow): JdbcRowSetter[Unit] = 
        use FactIO/JdbcRowSetter.{flatMap, return, putString!};
        let* _ = putString!(0,  x.equiId);
        let* _ = putString!(1,  x.objectType);
        let* _ = putString!(2,  x.manufacturer);
        let* _ = putString!(3,  x.serialNumber);
        let* _ = putString!(4,  x.technicalId);
        let* _ = putString!(5,  x.objectStatus);
        let* _ = putString!(6,  x.modelNumber);
        let* _ = putString!(7,  x.partNumber);
        let* _ = putString!(8,  x.equiCategory);
        return()

    def equiExportParams(): ExportParams[EquiRow] = 
        { tableName = "equi_entity"
        , createTableSql = sqlCreateTableEquiEntity()
        , insertSql = { "INSERT INTO equi_entity(equi_id, object_type, manufacturer, serial_number, technical_id, object_status, model_number, part_number, equi_category)"
                        + " VALUES(?,?,?,?,?,?,?,?,?)" }
        , writeRow = equiRowSetter
        }


    def sqlCreateTableEquiEntity(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS equi_entity ("
                :: "equi_id                 TEXT    NOT NULL PRIMARY KEY,"
                :: "object_type             TEXT    NOT NULL,"
                :: "manufacturer            TEXT,"
                :: "serial_number           TEXT,"
                :: "technical_id            TEXT,"
                :: "object_status           TEXT,"
                :: "model_number            TEXT,"
                :: "part_number             TEXT,"
                :: "equi_category           TEXT"
                :: ")"
                :: Nil
        )

}