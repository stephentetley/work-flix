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

namespace AssetLib/FileIO/S4/IH08Table/ExportDb { 

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;


    use AssetLib/FileIO/S4/IH08Table/Datatypes.{IH08Row};
    use AssetLib/FileIO/S4/IH08Table/XlsxReader.{readIH08File};


    pub def storeIH08Table(tableName: String, dropTable: Bool, src: System.FilePath) : DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult};
        let* xs     = liftActionResult(_ -> readIH08File(src));
        let* _      = exportAibAttributeRows(tableName, dropTable, xs);
        return()



    def exportAibAttributeRows(tableName: String, dropTable: Bool,rows: List[IH08Row]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, whenTrue, foldLeftM, setAutoCommit, prepareStatement, psExecuteUpdate, commit};
        let* _          = setAutoCommit(false);
        let* _          = whenTrue(dropTable, execute("DROP TABLE IF EXISTS ${tableName};"));
        let* _          = whenTrue(dropTable, execute(createTableSql(tableName)));
        let* stmt       = prepareStatement(insertRowSql(tableName));
        let* nrows      = foldLeftM((ac, x) -> { let* n = psExecuteUpdate(stmt, aibAttributeRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)

    /// A setter for AibAttributeRow
    def aibAttributeRowSetter(x: IH08Row): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!, putInt32At!, putOptionInt32At!, putOptionInt64At!};
        let* _  = putStringAt!(0, x.equiId);
        let* _  = putStringAt!(1, x.description);
        let* _  = putInt32At!(2, x.planningPlant);
        let* _  = putStringAt!(3, x.functionalLoc);
        let* _  = putStringAt!(4, x.techIdentNo);
        let* _  = putStringAt!(5, x.superordEquip);
        let* _  = putOptionInt32At!(6, x.position);
        let* _  = putStringAt!(7, x.manufPartNo);
        let* _  = putStringAt!(8, x.manufacturer);
        let* _  = putStringAt!(9, x.manufSerialNo);
        let* _  = putStringAt!(10, x.modelNumber);
        let* _  = putStringAt!(11, x.userStatus);        
        let* _  = putStringAt!(12, x.objectType);
        let* _  = putStringAt!(13, x.street);
        let* _  = putOptionInt64At!(14, x.inventoryNo);
        return()

    
    def insertRowSql(tableName: String): String =
        String.unwords(
            "INSERT INTO ${tableName} "
                :: "(equi_id, "
                :: "description, "
                :: "planning_plant, "
                :: "functional_loc, "
                :: "tech_ident_no, "
                :: "superord_equip, "
                :: "position, "
                :: "manuf_part_no, "
                :: "manufacturer, "
                :: "manuf_serial_no, "
                :: "model_number, "
                :: "user_status, "
                :: "object_type, "
                :: "street, "
                :: "inventory_no)"
                :: "VALUES(?,?,?, ?,?,?, ?,?,?, ?,?,?, ?,?,?);"
                :: Nil
        )

    def createTableSql(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "equi_id             TEXT NOT NULL,"
                :: "description         TEXT,"
                :: "planning_plant      INTEGER,"
                :: "functional_loc      TEXT,"
                :: "tech_ident_no       TEXT,"
                :: "superord_equip      TEXT,"
                :: "position            INTEGER,"
                :: "manuf_part_no       TEXT,"
                :: "manufacturer        REAL,"
                :: "manuf_serial_no     TEXT,"
                :: "model_number        TEXT,"
                :: "user_status         TEXT,"
                :: "object_type         TEXT,"
                :: "street              TEXT,"
                :: "inventory_no        TEXT"
                :: ")"
                :: Nil
        )


} 