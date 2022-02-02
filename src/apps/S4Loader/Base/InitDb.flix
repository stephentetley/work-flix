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

    // # Meta PDT field unit types 


    pub def createMetaPDTTables(): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit, execute, commit};
        let* _  = setAutoCommit(false);
        let* _  = execute("DROP TABLE IF EXISTS meta_pdt_field_unit_types;");
        let* _  = execute("DROP TABLE IF EXISTS meta_pdt_asset_types;");
        let* _  = execute(metaPdtFieldUnitTypesTableDdl());
        let* _  = execute(metaPdtAssetTypesTableDdl());
        let* _  = commit();
        point()


    def metaPdtFieldUnitTypesTableDdl(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS meta_pdt_field_unit_types ("
                :: "field_unit TEXT NOT NULL,"
                :: "s4_type TEXT NOT NULL,"
	            :: "PRIMARY KEY(field_unit)"
	            :: ");"
                :: Nil
        )

    def metaPdtAssetTypesTableDdl(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS meta_pdt_asset_types ("
                :: "pdt_asset_type TEXT NOT NULL,"
                :: "s4_object TEXT NOT NULL,"
                :: "s4_class TEXT NOT NULL,"
	            :: "PRIMARY KEY(pdt_asset_type)"
	            :: ");"
                :: Nil
        )

}
