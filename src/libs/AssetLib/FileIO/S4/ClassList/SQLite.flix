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


namespace AssetLib/FileIO/S4/ClassList/SQLite {

    use Applicative.{*>};

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

    use AssetLib/FileIO/S4/ClassList/Builder2.{Characteristic};

    pub def storeCharacteristics(table: String, rows: List[Characteristic]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, liftAction};
        store({tableName = table, tableDdl = createCharacteristicTableSql(table), 
                prepStatement = insertCharacteristicRowSql(table), setter = characteristicSetter}, rows)


    def characteristicSetter(x: Characteristic): PreparedStatementSetter[Unit] =
        use BasicDb/PreparedStatementSetter.{putStringAt!, putInt32At!, putOptionInt32At!};
        putStringAt!(0, x.className)
            *> putStringAt!(1, x.charName) 
            *> putStringAt!(2, x.description) 
            *> putStringAt!(3, x.s4Datatype) 
            *> putInt32At!(4, x.textLength) 
            *> putOptionInt32At!(5, x.decimalPlaces)

        
    def createCharacteristicTableSql(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ( "
                :: "class_name TEXT NOT NULL, "
                :: "char_name TEXT NOT NULL, "
                :: "description TEXT NOT NULL, "
                :: "char_data_type TEXT NOT NULL, "
                :: "data_length INTEGER NOT NULL, "
                :: "decimal_places INTEGER, "
                :: "PRIMARY KEY(class_name, char_name) "
                :: ");"
                :: Nil
        )

    def insertCharacteristicRowSql(tableName: String): String =
        String.unwords(
            "INSERT OR IGNORE INTO ${tableName} "
                :: "(class_name, "
                :: "char_name, "
                :: "description, "
                :: "char_data_type, "
                :: "data_length, "
                :: "decimal_places) "
                :: "VALUES(?,?,?, ?,?,?);"
                :: Nil
        )



    // Helpers

    type alias Setter[a] = a -> PreparedStatementSetter[Unit]

    def store(config: {tableName :: String, tableDdl :: String, prepStatement :: String, setter :: Setter[a]}, rows: t[a]): DbMonad[Int32] with Foldable[t] =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit, execute, prepareStatement, psExecuteUpdate, commit};
        let* _          = setAutoCommit(false);
        let* _          = execute("DROP TABLE IF EXISTS ${config.tableName};");
        let* _          = execute(config.tableDdl);
        let* stmt       = prepareStatement(config.prepStatement);
        let psSetter    = config.setter;
        let* nrows      = Foldable.foldLeftM((ac, x) -> 
                                {let* n = psExecuteUpdate(stmt, psSetter(x)); point(ac+n)}, 0, rows);
        let* _          = commit();
        point(nrows)


}
