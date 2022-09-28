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
        BasicDb/Writer.storeList(sqlstrings, changeSetter, rows)


    def changeSetter(x: (String, String, String, String)): PreparedStatementSetter[r, ka, Unit] \ {Write(r)} =
        use BasicDb/PreparedStatementSetter.{flatMap, point, putStringAt!};
        let (ckey, change, oldValue, newValue) = x;
        let* _  = putStringAt!(0, ckey);
        let* _  = putStringAt!(1, change);
        let* _  = putStringAt!(2, oldValue);
        let* _  = putStringAt!(3, newValue);
        point()


    def insertChangeRowSql(): String =
        String.unwords(
            "INSERT OR IGNORE INTO changes ("
                :: "cmpkey, "
                :: "change, "
                :: "old_value, "
                :: "new_value) "
                :: "VALUES(?,?,?, ?);"
                :: Nil
        )



    pub def storeSourceRows(ss: List[(Int32, String, String, 
                                    String, String, String, 
                                    String, String, String, 
                                    String, String, String, String)], dst: Path): Result[Int32, String] \ IO = region r {
        BasicDb/DbMonad.runSQLite(r, storeSourceRows1(ss), dst)
    }

    def storeSourceRows1(rows: List[(Int32, String, String, 
                                    String, String, String, 
                                    String, String, String, 
                                    String, String, String, String)]): DbMonad[r, ka, Int32] \ {IO, Write(r) } =
        let sqlstrings = {prepStmt = insertSourceRowSql(), tableActions = "DELETE FROM source_rows;" :: Nil };
        BasicDb/Writer.storeList(sqlstrings, sourceRowSetter, rows)

    def sourceRowSetter(x: (Int32, String, String, 
                        String, String, String, 
                        String, String, String, 
                        String, String, String, String)): PreparedStatementSetter[r, ka, Unit] \ {Write(r)} =
        use BasicDb/PreparedStatementSetter.{flatMap, point, putInt32At!, putStringAt!};
        let (rowIx, entityType, itemId, charId, className, language, intCounter, addressNumber, 
                change, attrib, oldValue, newValue, table) = x;
        let* _  = putInt32At!(0, rowIx);
        let* _  = putStringAt!(1, entityType);
        let* _  = putStringAt!(2, itemId);
        let* _  = putStringAt!(3, charId);
        let* _  = putStringAt!(4, className);
        let* _  = putStringAt!(5, language);
        let* _  = putStringAt!(6, intCounter);
        let* _  = putStringAt!(7, addressNumber);
        let* _  = putStringAt!(8, change);
        let* _  = putStringAt!(9, attrib);
        let* _  = putStringAt!(10, oldValue);
        let* _  = putStringAt!(11, newValue);
        let* _  = putStringAt!(12, table);
        point()

      def insertSourceRowSql(): String =
        String.unwords(
            "INSERT OR IGNORE INTO source_rows ("
                :: "row_index,"
                :: "entity_type,"
	            :: "item_id,"
                :: "char_name,"
                :: "class_name,"
                :: "language,"
                :: "int_counter,"
                :: "address_number,"
                :: "change,"
                :: "attrib,"
                :: "old_value,"
                :: "new_value,"
                :: "table_source) "
	            :: "VALUES (?,?,?, ?,?,?, ?,?,?, ?,?,?, ?);"
                :: Nil
        )

}
