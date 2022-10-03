/*
 * Copyright 2022 Stephen Tetley
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

namespace AssetS/ChangeReport/InitDb {

    use Basis/NIO/File.Path;
    use BasicDb.DbMonad;


    pub def createCRDatabase(dst: Path): Result[Unit, String] \ IO = region r {
        BasicDb/DbMonad.runSQLite(r, createChangesTables(), dst)
    }

    // # Properties Tables

    def createChangesTables(): DbMonad[r, ka, Unit] \ {IO, Write(r)} =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit!, executeSql!, commit!};
        let* _      = setAutoCommit!(false);
        let* _      = executeSql!("DROP TABLE IF EXISTS source_rows;");
        let* _      = executeSql!("DROP TABLE IF EXISTS changes;");
        let* _      = executeSql!(sourceRowsDdl());
        let* _      = executeSql!(changesDdl());
        let* _      = commit!();
        point()



    def sourceRowsDdl(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS source_rows ("
                :: "row_index INT NOT NULL,"
                :: "entity_type TEXT NOT NULL,"
	            :: "item_id TEXT NOT NULL,"
                :: "char_name TEXT,"
                :: "class_name TEXT,"
                :: "lang_id TEXT,"
                :: "int_counter TEXT,"
                :: "address_number TEXT,"
                :: "change TEXT,"
                :: "attrib TEXT,"
                :: "old_value TEXT,"
                :: "new_value TEXT,"
                :: "table_source TEXT,"
	            :: "PRIMARY KEY(row_index)"
	            :: ");"
                :: Nil
        )

    def changesDdl(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS changes ("
                :: "row_index INT NOT NULL,"
                :: "cmpkey TEXT NOT NULL,"
                :: "change_desc TEXT NOT NULL,"
	            :: "old_value TEXT,"
	            :: "new_value TEXT,"
	            :: "PRIMARY KEY(row_index)"
	            :: ");"
                :: Nil
        )
}
