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

namespace S4Loader/Aib/InitDb {

    use BasicDb.DbMonad;


    pub def createPropertiesTables(): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit, execute, commit};
        let* _  = setAutoCommit(false);
        let* _  = execute("DROP TABLE IF EXISTS string_properties;");
        let* _  = execute("DROP TABLE IF EXISTS int_properties;");
        let* _  = execute("DROP TABLE IF EXISTS float_properties;");
        let* _  = execute("DROP TABLE IF EXISTS date_properties;");
        let* _  = execute(stringPropertiesTableDdl());
        let* _  = execute(intPropertiesTableDdl());
        let* _  = execute(floatPropertiesTableDdl());
        let* _  = execute(datePropertiesTableDdl());
        let* _  = commit();
        point()


    def stringPropertiesTableDdl(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS string_properties ("
                :: "equipment_id TEXT NOT NULL,"
                :: "prop_name TEXT NOT NULL,"
	            :: "prop_value TEXT NOT NULL,"
	            :: "PRIMARY KEY(equipment_id, prop_name)"
	            :: ");"
                :: Nil
        )

    def intPropertiesTableDdl(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS int_properties ("
                :: "equipment_id TEXT NOT NULL,"
                :: "prop_name TEXT NOT NULL,"
	            :: "prop_value INTEGER NOT NULL,"
	            :: "PRIMARY KEY(equipment_id, prop_name)"
	            :: ");"
                :: Nil
        )

    def floatPropertiesTableDdl(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS float_properties ("
                :: "equipment_id TEXT NOT NULL,"
                :: "prop_name TEXT NOT NULL,"
	            :: "prop_value NUMERIC NOT NULL,"
	            :: "PRIMARY KEY(equipment_id, prop_name)"
	            :: ");"
                :: Nil
        )
    
    def datePropertiesTableDdl(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS date_properties ("
                :: "equipment_id TEXT NOT NULL,"
                :: "prop_name TEXT NOT NULL,"
	            :: "prop_value TEXT NOT NULL,"
	            :: "PRIMARY KEY(equipment_id, prop_name)"
	            :: ");"
                :: Nil
        )
}
