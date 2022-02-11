/*
 * Copyright 2021 Stephen Tetley
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

namespace AssetLib/FileIO/PDT/SQLite {

    use Applicative.{*>};

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

    use AssetLib/FileIO/PDT/Datatypes.{FieldValue};

/*
    let tableNames = 
        { valuesTable = "pdt_raw_values"
        , fileIndicesTable = "pdt_file_indices"
        , valuesWithShortNameView = "pdt_values_with_item_name"
        };
*/

    pub def storeFieldValuesAll(srcs: List[System.FilePath]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, point, liftActionResult};
        let* relns  = liftActionResult(_ -> AssetLib/FileIO/PDT/Reader.readFieldValuesAll(srcs));
        let* n      = insertFieldValues(relns);
        let* _      = deriveFileIndices();
        point(n)

    pub def storeFieldValues(src: System.FilePath): DbMonad[Int32] =
        storeFieldValuesAll(src :: Nil)

    pub def createPDTTables(): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit, execute, commit};
        let* _  = setAutoCommit(false);
        let* _  = execute("DROP TABLE IF EXISTS pdt_raw_values;");
        let* _  = execute("DROP TABLE IF EXISTS pdt_file_indices;");
        let* _  = execute("DROP VIEW IF EXISTS pdt_values_with_item_name;");
        let* _  = execute(fieldValueTableDdl());
        let* _  = execute(fileIndicesTableDdl());
        let* _  = execute(valuesWithShortNameViewDdl());
        let* _  = commit();
        point()

    /// TODO - don't do the join in Datalog...
    pub def insertFieldValues(relns: #{FieldValue | r}): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, liftAction};
        let* rows = liftAction(_ -> query relns select (x1, x2, x3, x4, x5, x6, x7) from FieldValue(x1, x2, x3, x4, x5, x6, x7) |> Array.toList);
        let sqlstrings = { 
            prepStmt = insertFieldValueSql(),
            tableActions = "DELETE FROM pdt_raw_values;" :: Nil
        };
        BasicDb/Writer.store(sqlstrings, fieldValueSetter, rows)

    def fieldValueSetter(x: (String, Int32, Int32, String, String, String, String)): PreparedStatementSetter[Unit] =
        use BasicDb/PreparedStatementSetter.{putInt32At!, putStringAt!};
        let (x1, x2, x3, x4, x5, x6, x7) = x;
        putStringAt!(0, x1)
            *> putInt32At!(1, x2) 
            *> putInt32At!(2, x3) 
            *> putStringAt!(3, x4) 
            *> putStringAt!(4, x5) 
            *> putStringAt!(5, x6) 
            *> putStringAt!(6, x7)
        
    def insertFieldValueSql(): String =
        String.unwords(
            "INSERT OR IGNORE INTO pdt_raw_values "
                :: "(source_file, "
                :: "row_num, "
                :: "item_num, "
                :: "asset_name, "
                :: "field_name, "
                :: "field_value, "
                :: "field_units) "
                :: "VALUES(?,?,?, ?,?,?, ?);"
                :: Nil
        )


        
    def fieldValueTableDdl(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS pdt_raw_values ("
                :: "source_file TEXT NOT NULL, "
                :: "row_num INTEGER NOT NULL, "
                :: "item_num INTEGER NOT NULL, "
                :: "asset_name TEXT NOT NULL, "
                :: "field_name TEXT NOT NULL, "
                :: "field_value TEXT, "
                :: "field_units TEXT NOT NULL, "
                :: "PRIMARY KEY(source_file, item_num, asset_name, field_name) "
                :: ");"
                :: Nil
        )

    /*
    DROP TABLE IF EXISTS pdt_adt_header_metadata;

    CREATE TABLE IF NOT EXISTS pdt_adt_header_metadata (
        source_file         TEXT NOT NULL,	
        row_num             INTEGER NOT NULL,
        adt_heading_name    TEXT NOT NULL, 	
        adt_heading_value   TEXT, 
        PRIMARY KEY(source_file, adt_heading_name) 
    );

    DROP TABLE IF EXISTS pdt_adt_param_specification;

    CREATE TABLE IF NOT EXISTS pdt_adt_param_specification (
        source_file TEXT NOT NULL,
        row_num INTEGER NOT NULL,
        param_name TEXT NOT NULL,
        category TEXT NOT NULL,
        index_aka_value INTEGER NOT NULL,
        param_units TEXT,
        PRIMARY KEY(source_file, row_num) 
    );    
*/

    def fileIndicesTableDdl(): String = 
        String.unwords(
            "CREATE TABLE IF NOT EXISTS pdt_file_indices ("
                :: "file_index INTEGER PRIMARY KEY ASC, "
                :: "file_name TEXT NOT NULL "
                :: ");"
                :: Nil
        )

    def deriveFileIndices(): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit, execute, commit};
        let* _  = setAutoCommit(false);
        let* _  = execute("DELETE FROM pdt_file_indices;");
        let* _  = execute(insertFileIndicesSql());
        let* _  = commit();
        point()

    /// Note this expects SQLite ORDER BY ... ASC to be same order as the order from the file system
    def insertFileIndicesSql(): String =
        String.unwords(
            "INSERT INTO pdt_file_indices (file_name) "
                :: "SELECT DISTINCT(prv.source_file) AS file_name "
                :: "FROM pdt_raw_values prv "
                :: "ORDER BY file_name ASC;"
                :: Nil
        )

    def valuesWithShortNameViewDdl(): String =
        String.unlines(
            "CREATE VIEW IF NOT EXISTS pdt_values_with_item_name(item_name, row_num, field_name, field_value, field_units) AS "
            :: "SELECT "
            :: "    printf('F%02d_C%02d_%s', pfi.file_index, prv.item_num, prv.asset_name) AS item_name, "
	        :: "    prv.row_num     AS row_num, "
	        :: "    prv.field_name  AS field_name, "
	        :: "    prv.field_value AS field_value, "
	        :: "    prv.field_units AS field_units "
            :: "FROM pdt_raw_values prv "
            :: "INNER JOIN pdt_file_indices pfi ON prv.source_file = pfi.file_name; "
            :: Nil
        )


}
