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


/// Store a view of an Equi FileDownload.
/// Only the fields needed for the `Simple` AST are stored

namespace AssetLib/S4/Simple/EquiDownload {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatement;
    use BasicDb.PreparedStatementSetter;

    use AssetLib/S4/FileIO/DownloadFile.RowEvaluator;



    type alias EquiRow = 
        { equiId: String
        , category: String
        , description: String
        , objectType: String
        , startupDate: Time.LocalDate
        , manufacturer: String
        , model: String
        , partNumber: String
        , serialNumber: String
        , constructionYear: Int32
        , constructionMonth: Int32
        , maintPlant: Int32
        , companyCode: Int32
        , controllingArea: Int32
        , planningPlant: Int32
        , functionalLocation: String
        , superOridinateEqui: String
        , status: String
        }


    pub def storeEquiFile(tableName: String, dropTable: Bool, src: System.FilePath) : DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult};
        use AssetLib/S4/FileIO/DownloadFile/Evaluate.{allRows};
        let* xs = liftActionResult(_ -> allRows(evalEquiRow(), src));
        let* _  = dbWriteEquiRows(tableName, dropTable, xs);
        return()



    def evalEquiRow(): RowEvaluator[EquiRow] = 
        use AssetLib/S4/FileIO/DownloadFile/RowEvaluator.{getStringNamed, getS4DateNamed, getInt32Named};
        use AssetLib/S4/FileIO/DownloadFile/RowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18) ->
                { equiId                = x1
                , category              = x2
                , description           = x3
                , objectType            = x4
                , startupDate           = x5
                , manufacturer          = x6
                , model                 = x7
                , partNumber            = x8
                , serialNumber          = x9
                , constructionYear      = x10
                , constructionMonth     = x11
                , maintPlant            = x12
                , companyCode           = x13
                , controllingArea       = x14
                , planningPlant         = x15
                , functionalLocation    = x16
                , superOridinateEqui    = x17
                , status                = x18
                })
            <&> getStringNamed("EQUI")                  /// Equipment ID
            <*> getStringNamed("EQTYP")                 /// Equipment Category
            <*> getStringNamed("TXTMI")                 /// Description (medium text)        
            <*> getStringNamed("EQART_EQU")             /// Object Type          
            <*> getS4DateNamed("INBDT")                 /// Startup Date
            <*> getStringNamed("HERST")                 /// Manufacturer
            <*> getStringNamed("TYPBZ")                 /// Model 
            <*> getStringNamed("MAPA_EEQZ")             /// Manufact Part No
            <*> getStringNamed("SERGE")                 /// Manufact Serial Number
            <*> getInt32Named("BAUJJ")                  /// Construction year
            <*> getInt32Named("BAUMM_EQI")              /// Construction month
            <*> getInt32Named("SWER_EILO")              /// Maintenance Plant
            <*> getInt32Named("BUKR_EILO")              /// Company Code
            <*> getInt32Named("KOKR_EILO")              /// Controlling Area
            <*> getInt32Named("PPLA_EEQZ")              /// Planning Plant
            <*> getStringNamed("TPLN_EILO")             /// Functional Location
            <*> getStringNamed("HEQU_EEQZ")             /// Superord Equipment
            <*> getStringNamed("USTW_EQUI")             /// Status of an object



    /// Write SQL
    pub def initEquiTable(tableName: String): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, execute, setAutoCommit, commit};
        let* _      = setAutoCommit(false);
        let* _      = execute("DROP TABLE IF EXISTS ${tableName};");
        let* _      = execute(createTableSql(tableName));
        let* _      = commit();
        return()

    def dbWriteEquiRows(tableName: String, dropTable: Bool, xs: List[EquiRow]): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, whenTrue, execute, prepareStatement, setAutoCommit, psExecuteUpdate, mapM, commit};
        let* _      = whenTrue(dropTable, initEquiTable(tableName));
        let* pstmt  = prepareStatement(insertRowSql(tableName));
        let* _      = setAutoCommit(false);
        let* _      = mapM(x -> psExecuteUpdate(pstmt, setEquiRowPStmt!(x)), xs);
        let* _      = commit();
        return()
    
    def setEquiRowPStmt!(x: EquiRow): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!, putInt32At!};
        use AssetLib/S4/Base/BasicDbUtils.{putS4DateAt!};
        let* _ = putStringAt!(0,  x.equiId);
        let* _ = putStringAt!(1,  x.category);
        let* _ = putStringAt!(2,  x.description);
        let* _ = putStringAt!(3,  x.objectType);
        let* _ = putS4DateAt!(4, x.startupDate);
        let* _ = putStringAt!(5,  x.manufacturer);
        let* _ = putStringAt!(6,  x.model);
        let* _ = putStringAt!(7,  x.partNumber);
        let* _ = putStringAt!(8,  x.serialNumber);
        let* _ = putInt32At!(9, x.constructionYear);
        let* _ = putInt32At!(10, x.constructionMonth);
        let* _ = putInt32At!(11, x.maintPlant);
        let* _ = putInt32At!(12, x.companyCode);
        let* _ = putInt32At!(13, x.controllingArea);
        let* _ = putInt32At!(14, x.planningPlant);
        let* _ = putStringAt!(15,  x.functionalLocation);
        let* _ = putStringAt!(16,  x.superOridinateEqui);
        let* _ = putStringAt!(17,  x.status);
        return()

    def insertRowSql(tableName: String): String =
        String.unwords(
            "INSERT INTO ${tableName} "
                :: "(equi_id, category, description, "
                :: "object_type, startup_date, manufacturer, "
                :: "model, part_number, serial_number, "
                :: "construction_year, construction_month, maintenance_plant, "
                :: "company_code, controlling_area, planning_plant, "
                :: "functional_location, superordinate_equi_id, status) "
                :: "VALUES(?,?,?, ?,?,?, ?,?,?, ?,?,?, ?,?,?, ?,?,?);"
                :: Nil
        )

    def createTableSql(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "equi_id                 TEXT NOT NULL PRIMARY KEY,"
                :: "category                TEXT NOT NULL,"
                :: "description             TEXT NOT NULL,"
                :: "object_type             TEXT NOT NULL,"
                :: "startup_date            TEXT,"
                :: "manufacturer            TEXT,"
                :: "model                   TEXT,"
                :: "part_number             TEXT,"
                :: "serial_number           TEXT,"
                :: "construction_year       INTEGER NOT NULL,"
                :: "construction_month      INTEGER NOT NULL,"
                :: "maintenance_plant       INTEGER,"
                :: "company_code            INTEGER,"
                :: "controlling_area        INTEGER,"
                :: "planning_plant          INTEGER,"
                :: "functional_location     TEXT,"
                :: "superordinate_equi_id   TEXT,"
                :: "status                  TEXT"
                :: ");"
                :: Nil
        )



}