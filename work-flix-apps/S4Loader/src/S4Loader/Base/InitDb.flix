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

namespace S4Loader/Base/InitDb {

    use BasicDb.DbMonad;

    // # Properties Tables

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

    /// # meta_equi_classes etc.

    /// Most work is done by the ClassList library

    pub def createEquiClassListTables(): DbMonad[Unit] =
        AssetLib/FileIO/S4/ClassList/SQLite.createClassListTables(classListTableNames())

    pub def storeEquiClassListData(src: System.FilePath): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, point, liftActionResult};
        let* ans    = liftActionResult(_ -> AssetLib/FileIO/S4/ClassList/Builder.readEquiClassRecords(src));
        let* n      = AssetLib/FileIO/S4/ClassList/SQLite.storeClassListData(classListTableNames(), ans);
        point(n)

    def classListTableNames(): AssetLib/FileIO/S4/ClassList/SQLite.ClassListTableNames = 
        { classDescriptionTable = "meta_equi_classes"
        , characteristicTable   = "meta_equi_characteristics"
        , picklistValueTable    = "meta_equi_picklist_values"
        , intRangeTable         = "meta_equi_int_ranges"
        }


    /// PDT only
    pub def createPdtViews(): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit, execute, commit};
        let* _  = setAutoCommit(false);
        let* _  = execute("DROP VIEW IF EXISTS pdt_equipment_list;");
        let* _  = execute(pdtEquipmentListViewDdl());
        let* _  = commit();
        point()


    def pdtEquipmentListViewDdl(): String =
        String.unlines(
            "CREATE VIEW IF NOT EXISTS pdt_equipment_list(uid, asset_name, asset_type, tag_ref, funcloc) AS "
            :: "SELECT "
            :: "    sp.equipment_id AS uid, "
            :: "    sp.prop_value 	AS asset_name, "
            :: "    sp1.prop_value  AS asset_type, "
            :: "    sp2.prop_value  AS tag_ref, "
            :: "    sp3.prop_value  AS funcloc "
            :: "FROM string_properties sp "
            :: "LEFT OUTER JOIN (SELECT ss1.equipment_id, ss1.prop_value "
            :: "        FROM string_properties ss1 "
            :: "        WHERE ss1.prop_name = 'Asset Type' "
            :: "        ) as sp1 "
            :: "    ON sp.equipment_id  = sp1.equipment_id "
            :: "LEFT OUTER JOIN (SELECT ss2.equipment_id, ss2.prop_value "
            :: "        FROM string_properties ss2 "
            :: "        WHERE ss2.prop_name = 'Tag reference' "
            :: "        ) as sp2 "
            :: "    ON sp.equipment_id  = sp2.equipment_id "
            :: "LEFT OUTER JOIN (SELECT ss3.equipment_id, ss3.prop_value "
            :: "        FROM string_properties ss3 "
            :: "        WHERE ss3.prop_name = 'Location in Asset Hierarchy' "
            :: "        ) as sp3 "
            :: "    ON sp.equipment_id  = sp3.equipment_id"
            :: "WHERE "
	        :: "    sp.prop_name = 'Asset Name';"
            :: Nil
        )

}
