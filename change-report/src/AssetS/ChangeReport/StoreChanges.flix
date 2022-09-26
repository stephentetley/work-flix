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


namespace AssetS/ChangeReport/StoreChanges {

    use Basis/System.Path;

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;
    use BasicDb/Writer.RowSetter;


    pub def storeChanges(cs: List[(String, String, String, String)], dst: Path): Result[Int32, String] \ IO = region r {
        BasicDb/DbMonad.runSQLite(r, storeChanges1(cs), dst)
    }

    def storeChanges1(rows: List[(String, String, String, String)]): DbMonad[r, ka, Int32] \ {IO, Write(r) } =
        let sqlstrings = {prepStmt = insertChangeRowSql(), tableActions = "DELETE FROM changes;" :: Nil };
        BasicDb/Writer.store(sqlstrings, changeSetter, rows)


    def changeSetter(x: (String, String, String, String)): PreparedStatementSetter[r, ka, Unit] \ Write(r) =
        use BasicDb/PreparedStatementSetter.{flatMap, point, putStringAt!};
        let (ckey, change, oldValue, newValue) = x;
        let* _  = putStringAt!(0, ckey);
        let* _  = putStringAt!(1, change);
        let* _  = putStringAt!(2, oldValue);
        let* _  = putStringAt!(3, newValue);
        point()


    def insertChangeRowSql(): String =
        String.unwords(
            "INSERT OR IGNORE INTO changes "
                :: "(cmpkey, "
                :: "change, "
                :: "old_value, "
                :: "new_value) "
                :: "VALUES(?,?,?, ?);"
                :: Nil
        )

  

}
