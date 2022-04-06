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



namespace AssetLib/FileIO/S4/TransferFile/SQLite {

    use Applicative.{*>};

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;

    use AssetLib/FileIO/S4/TransferFile/Datatypes.{ClassFlocRow, ValuaFlocRow, ClassEquiRow, ValuaEquiRow};

    pub def createValuaEquiTable(): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit, execute, commit};
        let* _  = setAutoCommit(false);
        let* _  = execute("DROP TABLE IF EXISTS valua_equi;");
        let* _  = execute(valuaEquiDdl());
        let* _  = commit();
        point()

    
    pub def insertValuaEquiRows(rows: List[ValuaEquiRow]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, liftAction};
        let sqlstrings = { 
            prepStmt = insertValuaEquiSql(),
            tableActions = Nil
        };
        BasicDb/Writer.store(sqlstrings, valuaEquiRowSetter, rows)


    def valuaEquiRowSetter(x: ValuaEquiRow): PreparedStatementSetter[Unit] =
        use BasicDb/PreparedStatementSetter.{putInt32At!, putStringAt!, putOptionInt32At!};
        putStringAt!(0, x.equi)
            *> putStringAt!(1, x.charId) 
            *> putInt32At!(2, x.intCounterValue) 
            *> putStringAt!(3, x.charValue) 
            *> putStringAt!(4, x.classType) 
            *> putOptionInt32At!(5, x.code) 
            *> putStringAt!(6, x.valueDescription)
            *> putInt32At!(7, x.instanceCounter)
            *> putStringAt!(8, x.position)
            *> putStringAt!(9, x.valueFrom)
            *> putStringAt!(10, x.valueTo)



    def insertValuaEquiSql(): String =
        String.unlines(
            "INSERT OR IGNORE INTO valua_equi "
                :: "(equi_id, "
                :: "characteristic_id,"
                :: "int_counter_value,"
                :: "characteristic_value,"
                :: "class_type,"
                :: "code,"
                :: "description,"
                :: "instance_counter,"
                :: "position,"
                :: "value_from,"
                :: "value_to)"
                :: "VALUES(?,?,?, ?,?,?, ?,?,?, ?,?);"
                :: Nil
            )

    def valuaEquiDdl(): String =
        String.unlines(
            "CREATE TABLE IF NOT EXISTS valua_equi ("
                :: "equi_id TEXT NOT NULL,"
                :: "characteristic_id TEXT NOT NULL,"
                :: "int_counter_value INTEGER,"
                :: "characteristic_value TEXT,"
                :: "class_type TEXT,"
                :: "code INTEGER,"
                :: "description TEXT,"
                :: "instance_counter INTEGER,"
                :: "position TEXT,"
                :: "value_from TEXT,"
                :: "value_to TEXT,"
                :: "PRIMARY KEY(equi_id, characteristic_id, int_counter_value)"
                :: ");"
                :: Nil
            )
}
