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

    use AssetLib/FileIO/PDT/Base.{FieldValue};

    pub type alias PDTTableNames = 
        { valuesTable :: String
        , fileIndicesTable :: String
        , valuesWithShortNameView :: String
        }


    pub def storeFieldValuesAll(names: PDTTableNames, srcs: List[System.FilePath]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, point, liftActionResult};
        let* relns  = liftActionResult(_ -> AssetLib/FileIO/PDT/Reader.readFieldValuesAll(srcs));
        let* n      = insertFieldValues(names.valuesTable, relns);
        let* _      = deriveFileIndices(names);
        point(n)

    pub def storeFieldValues(names: PDTTableNames, src: System.FilePath): DbMonad[Int32] =
        storeFieldValuesAll(names, src :: Nil)

    pub def createPDTTables(names: PDTTableNames): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit, execute, commit};
        let* _  = setAutoCommit(false);
        let* _  = execute("DROP TABLE IF EXISTS ${names.valuesTable};");
        let* _  = execute("DROP TABLE IF EXISTS ${names.fileIndicesTable};");
        let* _  = execute("DROP VIEW IF EXISTS ${names.valuesWithShortNameView};");
        let* _  = execute(fieldValueTableDdl(names.valuesTable));
        let* _  = execute(fileIndicesTableDdl(names.fileIndicesTable));
        let* _  = execute(valuesWithShortNameViewDdl(names));
        let* _  = commit();
        point()

    pub def insertFieldValues(table: String, relns: #{FieldValue | r}): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, liftAction};
        let* rows = liftAction(_ -> query relns select (x1, x2, x3, x4, x5, x6, x7) from FieldValue(x1, x2, x3, x4, x5, x6, x7) |> Array.toList);
        let sqlstrings = { 
            prepStmt = insertFieldValueSql(table),
            tableActions = "DELETE FROM ${table};" :: Nil
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
        
    def insertFieldValueSql(tableName: String): String =
        String.unwords(
            "INSERT OR IGNORE INTO ${tableName} "
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


        
    def fieldValueTableDdl(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
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

    def fileIndicesTableDdl(tableName: String): String = 
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "file_index INTEGER PRIMARY KEY ASC, "
                :: "file_name TEXT NOT NULL "
                :: ");"
                :: Nil
        )

    def deriveFileIndices(names: PDTTableNames): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit, execute, commit};
        let* _  = setAutoCommit(false);
        let* _  = execute("DELETE FROM ${names.fileIndicesTable};");
        let* _  = execute(insertFileIndicesSql(names));
        let* _  = commit();
        point()

    /// Note this expects SQLite ORDER BY ... ASC to be same order as the order from the file system
    def insertFileIndicesSql(names: PDTTableNames): String =
        String.unwords(
            "INSERT INTO ${names.fileIndicesTable} (file_name) "
                :: "SELECT DISTINCT(v.source_file) AS file_name "
                :: "FROM ${names.valuesTable} v "
                :: "ORDER BY file_name ASC;"
                :: Nil
        )

    def valuesWithShortNameViewDdl(names: PDTTableNames): String =
        String.unlines(
            "CREATE VIEW IF NOT EXISTS ${names.valuesWithShortNameView}(item_name, row_num, field_name, field_value, field_units) AS "
            :: "SELECT "
            :: "    printf('F%02d_C%02d_%s', pfi.file_index, prv.item_num, prv.asset_name) AS item_name, "
	        :: "    prv.row_num     AS row_num, "
	        :: "    prv.field_name  AS field_name, "
	        :: "    prv.field_value AS field_value, "
	        :: "    prv.field_units AS field_units "
            :: "FROM ${names.valuesTable} prv "
            :: "INNER JOIN ${names.fileIndicesTable} pfi ON prv.source_file = pfi.file_name; "
            :: Nil
        )


}
