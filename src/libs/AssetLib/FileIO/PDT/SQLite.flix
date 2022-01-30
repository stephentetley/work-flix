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


    pub def storeFieldValuesAll(table: String, srcs: List[System.FilePath]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, point, liftActionResult};
        let* relns  = liftActionResult(_ -> AssetLib/FileIO/PDT/Reader.readFieldValuesAll(srcs));
        let* n      = insertFieldValues(table, relns);
        point(n)

    pub def storeFieldValues(table: String, src: System.FilePath): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, point, liftActionResult};
        let* relns  = liftActionResult(_ -> AssetLib/FileIO/PDT/Reader.readFieldValues(src));
        let* n      = insertFieldValues(table, relns);
        point(n)

    pub def createPDTValuesTable(table: String): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit, execute, commit};
        let* _  = setAutoCommit(false);
        let* _  = execute("DROP TABLE IF EXISTS ${table};");
        let* _  = execute(createTableSql(table));
        let* _  = commit();
        point()

    pub def insertFieldValues(table: String, relns: #{FieldValue | r}): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, liftAction};
        let* rows = liftAction(_ -> query relns select (x1, x2, x3, x4, x5, x6, x7) from FieldValue(x1, x2, x3, x4, x5, x6, x7) |> Array.toList);
        let sqlstrings = { 
            prepStmt = insertFieldValueRowSql(table),
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
        
    def insertFieldValueRowSql(tableName: String): String =
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


        
    def createTableSql(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "source_file TEXT NOT NULL, "
                :: "row_num INTEGER NOT NULL, "
                :: "item_num INTEGER NOT NULL, "
                :: "asset_name TEXT NOT NULL, "
                :: "field_name TEXT NOT NULL, "
                :: "field_value TEXT, "
                :: "field_units TEXT NOT NULL, "
                :: "PRIMARY KEY(source_file, row_num, asset_name, field_name) "
                :: ");"
                :: Nil
        )

}
