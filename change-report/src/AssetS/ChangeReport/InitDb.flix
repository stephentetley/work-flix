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
        let* _      = executeSql!("DROP VIEW IF EXISTS floc_general_data;");
        let* _      = executeSql!("DROP VIEW IF EXISTS floc_class_floc;");
        let* _      = executeSql!("DROP VIEW IF EXISTS floc_valua_floc");
        let* _      = executeSql!("DROP VIEW IF EXISTS floc_long_text;");
        let* _      = executeSql!("DROP VIEW IF EXISTS floc_addr_floc;");
        let* _      = executeSql!("DROP VIEW IF EXISTS equi_general_data;");
        let* _      = executeSql!("DROP VIEW IF EXISTS equi_class_equi;");
        let* _      = executeSql!("DROP VIEW IF EXISTS equi_valua_equi;");
        let* _      = executeSql!("DROP VIEW IF EXISTS equi_long_text;");
        let* _      = executeSql!("DROP VIEW IF EXISTS equi_addr_equi;");
        let* _      = executeSql!("DROP TABLE IF EXISTS source_rows;");
        let* _      = executeSql!("DROP TABLE IF EXISTS changes;");
        /// create tables and views
        let* _      = executeSql!(sourceRowsDdl());
        let* _      = executeSql!(changesDdl());
        let* _      = executeSql!(flocGeneralDataView());
        let* _      = executeSql!(flocClassFlocView());
        let* _      = executeSql!(flocValuaFlocView());
        let* _      = executeSql!(flocLongTextView());
        let* _      = executeSql!(flocAddrFlocView());
        let* _      = executeSql!(equiGeneralDataView());
        let* _      = executeSql!(equiClassEquiView());
        let* _      = executeSql!(equiValuaEquiView());
        let* _      = executeSql!(equiLongTextView());
        let* _      = executeSql!(equiAddrEquiView());
        let* _      = commit!();
        point()



    def sourceRowsDdl(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS source_rows ("
                :: "row_index INT NOT NULL,"
                :: "entity_type TEXT NOT NULL,"
	            :: "item_id TEXT NOT NULL,"
                :: "class_name TEXT,"
                :: "char_name TEXT,"
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

    def flocGeneralDataView(): String = 
        String.unwords(
            "CREATE VIEW IF NOT EXISTS floc_general_data ("
                :: "row_index,"
                :: "cmpkey,"
                :: "item_id,"
                :: "attrib,"
                :: "change_desc,"
                :: "old_value,"
                :: "new_value)"
                :: "AS"
                :: "SELECT"
                :: "c.row_index,"
                :: "c.cmpkey,"
                :: "sr.item_id,"
                :: "sr.attrib,"
                :: "c.change_desc,"
                :: "c.old_value,"
                :: "c.new_value"
                :: "FROM"
                :: "changes c"
                :: "JOIN"
                :: "source_rows sr ON c.row_index == sr.row_index"
                :: "WHERE"
                :: "sr.entity_type = 'Functional Location'"
                :: "AND"
                :: "c.change_desc <> 'Transient'"
                :: "AND"
                :: "c.cmpkey LIKE 'F:GD:%';"
                :: Nil
        )

    def flocClassFlocView(): String = 
        String.unwords(
                "CREATE VIEW IF NOT EXISTS floc_class_floc ("
                :: "    row_index,"
                :: "    cmpkey,"
                :: "    item_id,"
                :: "    class_name,"
                :: "    change_desc,"
                :: "    old_value,"
                :: "    new_value)"
                :: "AS"
                :: "SELECT"
                :: "    c.row_index,"
                :: "    c.cmpkey,"
                :: "    sr.item_id,"
                :: "    sr.class_name,"
                :: "    c.change_desc,"
                :: "    c.old_value,"
                :: "    c.new_value"
                :: "FROM"
                :: "    changes c"
                :: "JOIN"
                :: "    source_rows sr ON c.row_index == sr.row_index"
                :: "WHERE"
                :: "    sr.entity_type = 'Functional Location'"
                :: "AND"
                :: "    c.change_desc <> 'Transient'"
                :: "AND"
                :: "    c.cmpkey LIKE 'F:CF:%';"
                :: Nil
        )

    def flocValuaFlocView(): String = 
        String.unwords(
            "CREATE VIEW IF NOT EXISTS floc_valua_floc ("
                :: "    row_index,"
                :: "    cmpkey,"
                :: "    item_id,"
                :: "    char_name,"
                :: "    int_counter,"
                :: "    char_type,"
                :: "    change_desc,"
                :: "    old_value,"
                :: "    new_value)"
                :: "AS"
                :: "SELECT"
                :: "    c.row_index,"
                :: "    c.cmpkey,"
                :: "    sr.item_id,"
                :: "    sr.char_name,"
                :: "    sr.int_counter,"
                :: "    CASE sr.attrib"
                :: "        WHEN 'Value from' THEN 'Number'"
                :: "        ELSE 'String'"
                :: "    END char_type,"
                :: "    c.change_desc,"
                :: "    c.old_value,"
                :: "    c.new_value"
                :: "FROM"
                :: "    changes c"
                :: "JOIN"
                :: "    source_rows sr ON c.row_index == sr.row_index"
                :: "WHERE"
                :: "    sr.entity_type = 'Functional Location'"
                :: "AND"
                :: "    c.change_desc <> 'Transient'"
                :: "AND "
                :: "    c.cmpkey LIKE 'F:V_:%';"
                :: Nil
    )

    def flocLongTextView(): String = 
        String.unwords(
            "CREATE VIEW IF NOT EXISTS floc_long_text ("
                :: "    row_index,"
                :: "    cmpkey,"
                :: "    item_id,"
                :: "    lang_id,"
                :: "    attrib,"
                :: "    change_desc," 
                :: "    old_value,"
                :: "    new_value)"
                :: "AS"
                :: "SELECT"
                :: "    c.row_index,"
                :: "    c.cmpkey,"
                :: "    sr.item_id,"
                :: "    sr.lang_id,"
                :: "    sr.attrib,"
                :: "    c.change_desc,"
                :: "    c.old_value,"
                :: "    c.new_value"
                :: "FROM"
                :: "    changes c"
                :: "JOIN"
                :: "    source_rows sr ON c.row_index == sr.row_index"
                :: "WHERE"
                :: "    sr.entity_type = 'Functional Location'"
                :: "AND"
                :: "    c.change_desc <> 'Transient'"
                :: "AND"
                :: "    c.cmpkey LIKE 'F:LT:%';"
                :: Nil
            )

    def flocAddrFlocView(): String = 
        String.unwords(
            "CREATE VIEW IF NOT EXISTS floc_addr_floc ("
                :: "    row_index,"
                :: "    cmpkey,"
                :: "    item_id,"
                :: "    address_number,"
                :: "    attrib,"
                :: "    change_desc,"
                :: "    old_value,"
                :: "    new_value)"
                :: "AS"
                :: "SELECT"
                :: "    c.row_index,"
                :: "    c.cmpkey,"
                :: "    sr.item_id,"
                :: "    sr.address_number,"
                :: "    sr.attrib,"
                :: "    c.change_desc,"
                :: "    c.old_value,"
                :: "    c.new_value"
                :: "FROM"
                :: "    changes c"
                :: "JOIN"
                :: "    source_rows sr ON c.row_index == sr.row_index"
                :: "WHERE"
                :: "    sr.entity_type = 'Functional Location'"
                :: "AND"
                :: "    c.change_desc <> 'Transient'"
                :: "AND"
                :: "    c.cmpkey LIKE 'F:AD:%';"
                :: Nil
            )


    def equiGeneralDataView(): String = 
        String.unwords(
            "CREATE VIEW IF NOT EXISTS equi_general_data ("
                :: "    row_index,"
                :: "    cmpkey,"
                :: "    item_id,"
                :: "    attrib,"
                :: "    change_desc,"
                :: "    old_value,"
                :: "    new_value)"
                :: "AS"
                :: "SELECT"
                :: "    c.row_index,"
                :: "    c.cmpkey,"
                :: "    sr.item_id,"
                :: "    sr.attrib,"
                :: "    c.change_desc,"
                :: "    c.old_value,"
                :: "    c.new_value"
                :: "FROM"
                :: "    changes c"
                :: "JOIN"
                :: "    source_rows sr ON c.row_index == sr.row_index"
                :: "WHERE"
                :: "    sr.entity_type = 'Equipment'"
                :: "AND"
                :: "    c.change_desc <> 'Transient'"
                :: "AND"
                :: "    c.cmpkey LIKE 'E:GD:%';"
                :: Nil
            )

    // equi_class_equi

    def equiClassEquiView(): String = 
        String.unwords(
            "CREATE VIEW IF NOT EXISTS equi_class_equi ("
                :: "    row_index,"
                :: "    cmpkey,"
                :: "    item_id,"
                :: "    class_name,"
                :: "    change_desc,"
                :: "    old_value,"
                :: "    new_value)"
                :: "AS"
                :: "SELECT"
                :: "    c.row_index,"
                :: "    c.cmpkey,"
                :: "    sr.item_id,"
                :: "    sr.class_name,"
                :: "    c.change_desc,"
                :: "    c.old_value,"
                :: "    c.new_value"
                :: "FROM"
                :: "    changes c"
                :: "JOIN"
                :: "    source_rows sr ON c.row_index == sr.row_index"
                :: "WHERE"
                :: "    sr.entity_type = 'Equipment'"
                :: "AND"
                :: "    c.change_desc <> 'Transient'"
                :: "AND"
                :: "    c.cmpkey LIKE 'E:CE:%';"
                :: Nil
            )

    def equiValuaEquiView(): String = 
        String.unwords(
            "CREATE VIEW IF NOT EXISTS equi_valua_equi ("
                :: "    row_index,"
                :: "    cmpkey,"
                :: "    item_id,"
                :: "    char_name,"
                :: "    int_counter,"
                :: "    char_type,"
                :: "    change_desc,"
                :: "    old_value,"
                :: "    new_value)"
                :: "AS"
                :: "SELECT"
                :: "    c.row_index,"
                :: "    c.cmpkey,"
                :: "    sr.item_id,"
                :: "    sr.char_name,"
                :: "    sr.int_counter,"
                :: "    CASE sr.attrib"
                :: "        WHEN 'Value from' THEN 'Number'"
                :: "        ELSE 'String'"
                :: "    END char_type,"
                :: "    c.change_desc,"
                :: "    c.old_value,"
                :: "    c.new_value"
                :: "FROM"
                :: "    changes c"
                :: "JOIN"
                :: "    source_rows sr ON c.row_index == sr.row_index"
                :: "WHERE"
                :: "    sr.entity_type = 'Equipment'"
                :: "AND"
                :: "    c.change_desc <> 'Transient'"
                :: "AND"
                :: "    c.cmpkey LIKE 'E:V_:%';"
                :: Nil
            )

    def equiLongTextView(): String = 
        String.unwords(
            "CREATE VIEW IF NOT EXISTS equi_long_text ("
                :: "    row_index,"
                :: "    cmpkey,"
                :: "    item_id,"
                :: "    lang_id,"
                :: "    attrib,"
                :: "    change_desc,"
                :: "    old_value,"
                :: "    new_value)"
                :: "AS"
                :: "SELECT"
                :: "    c.row_index,"
                :: "    c.cmpkey,"
                :: "    sr.item_id,"
                :: "    sr.lang_id,"
                :: "    sr.attrib,"
                :: "    c.change_desc,"
                :: "    c.old_value,"
                :: "    c.new_value"
                :: "FROM"
                :: "    changes c"
                :: "JOIN"
                :: "    source_rows sr ON c.row_index == sr.row_index"
                :: "WHERE"
                :: "    sr.entity_type = 'Equipment'"
                :: "AND"
                :: "    c.change_desc <> 'Transient'"
                :: "AND"
                :: "    c.cmpkey LIKE 'E:LT:%';"
                :: Nil
            )

    def equiAddrEquiView(): String = 
        String.unwords(
            "CREATE VIEW IF NOT EXISTS equi_addr_equi ("
                :: "    row_index,"
                :: "    cmpkey,"
                :: "    item_id,"
                :: "    address_number,"
                :: "    attrib,"
                :: "    change_desc,"
                :: "    old_value,"
                :: "    new_value)"
                :: "AS"
                :: "SELECT"
                :: "    c.row_index,"
                :: "    c.cmpkey,"
                :: "    sr.item_id,"
                :: "    sr.address_number,"
                :: "    sr.attrib,"
                :: "    c.change_desc,"
                :: "    c.old_value,"
                :: "    c.new_value"
                :: "FROM"
                :: "    changes c"
                :: "JOIN"
                :: "    source_rows sr ON c.row_index == sr.row_index"
                :: "WHERE"
                :: "    sr.entity_type = 'Equipment'"
                :: "AND"
                :: "    c.change_desc <> 'Transient'"
                :: "AND"
                :: "    c.cmpkey LIKE 'E:AD:%';"
                :: Nil
        )

}
