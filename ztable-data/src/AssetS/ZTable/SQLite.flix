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


namespace AssetLib/ZTable/SQLite {

    use Functor.{<$>};
    use Applicative.{<*>, *>};

    use Basis/NIO/File.Path;

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

    use AssetLib/ZTable/Datatypes.{ObjTypeManufacturer, ManufacturerModel, FlocObject, EquiObject};

    // # Objtype Manuf

    pub def readAndStoreObjTypeManufacturer(table: String, path: Path): DbMonad[r, Unit, List[ObjTypeManufacturer]] \ {IO, Write(r)} =
        use BasicDb/DbMonad.{flatMap, point, liftActionResult};
        let* ans    = liftActionResult(_ -> AssetLib/ZTable/Builtins.loadObjTypeManufacturer(path));
        let* _      = storeObjTypeManufacturer(table, ans);
        point(ans)


    pub def storeObjTypeManufacturer(table: String, rows: t[ObjTypeManufacturer]): DbMonad[r, Unit, Int32] \ {IO, Write(r)} with Foldable[t] =
        let sqlstrings = { 
            prepStmt = insertObjTypeManufacturerRowSql(table),
            tableActions = "DELETE FROM ${table};" :: Nil
        };
        BasicDb/Writer.store(sqlstrings, objTypeManufacturerSetter, rows)


    def objTypeManufacturerSetter(x: ObjTypeManufacturer): PreparedStatementSetter[r, Unit, Unit] \ Write(r) =
        use BasicDb/PreparedStatementSetter.{point, putStringAt!};
        putStringAt!(0, x.objectType) *> putStringAt!(1, x.manufacturer)

    def insertObjTypeManufacturerRowSql(tableName: String): String =
        String.unwords(
            "INSERT OR IGNORE INTO ${tableName} "
                :: "(object_type, "
                :: "manufacturer) "
                :: "VALUES(?,?);"
                :: Nil
        )


    pub def createObjTypeManufacturerTable(tableName: String): DbMonad[r, Unit, Unit] \ {IO, Write(r)} =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit!, executeSql!, commit!};
        let* _  = setAutoCommit!(false);
        let* _  = executeSql!("DROP TABLE IF EXISTS ${tableName};");
        let* _  = executeSql!(objTypeManufacturerTableDdl(tableName));
        let* _  = commit!();
        point()

    def objTypeManufacturerTableDdl(tableName: String): String =
        String.unlines(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "object_type TEXT NOT NULL, "
                :: "manufacturer TEXT NOT NULL, "
                :: "PRIMARY KEY(object_type, manufacturer) "
                :: ");"
                :: Nil
            )

    // # Manufacturer Model


    pub def readAndStoreManufacturerModel(table: String, path: Path): DbMonad[r, Unit, List[ManufacturerModel]] \ {IO, Write(r)} =
        use BasicDb/DbMonad.{flatMap, point, liftActionResult};
        let* ans    = liftActionResult(_ -> AssetLib/ZTable/Builtins.loadManufacturerModel(path));
        let* _      = storeManufacturerModel(table, ans);
        point(ans)

    pub def storeManufacturerModel(table: String, rows: t[ManufacturerModel]): DbMonad[r, Unit, Int32] \ {IO, Write(r)} with Foldable[t] =
        let sqlstrings = { 
            prepStmt = insertManufacturerModelRowSql(table),
            tableActions = "DELETE FROM ${table};" :: Nil
        };
        BasicDb/Writer.store(sqlstrings, manufacturerModelSetter, rows)

    def manufacturerModelSetter(x: ManufacturerModel): PreparedStatementSetter[r, Unit, Unit] \ Write(r) =
        use BasicDb/PreparedStatementSetter.{putStringAt!};
        putStringAt!(0, x.manufacturer) *> putStringAt!(1, x.model)
        
    def insertManufacturerModelRowSql(tableName: String): String =
        String.unwords(
            "INSERT OR IGNORE INTO ${tableName} "
                :: "(manufacturer, "
                :: "model) "
                :: "VALUES(?,?);"
                :: Nil
        )



    pub def createManufacturerModelTable(tableName: String): DbMonad[r, Unit, Unit] \ {IO, Write(r)} =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit!, executeSql!, commit!};
        let* _  = setAutoCommit!(false);
        let* _  = executeSql!("DROP TABLE IF EXISTS ${tableName};");
        let* _  = executeSql!(manufacturerModelTableDdl(tableName));
        let* _  = commit!();
        point()

    def manufacturerModelTableDdl(tableName: String): String =
        String.unlines(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "manufacturer TEXT NOT NULL, "
                :: "model TEXT NOT NULL, "
                :: "PRIMARY KEY(manufacturer, model) "
                :: ");"
                :: Nil
            )

    // # Floc Object Type Hierarchy


    pub def storeFlocObject(table: String, rows: t[FlocObject]): DbMonad[r, Unit, Int32] \ {IO, Write(r)}with Foldable[t] =
        let sqlstrings = { 
            prepStmt = insertFlocObjectRowSql(table),
            tableActions = "DELETE FROM ${table};" :: Nil
        };
        BasicDb/Writer.store(sqlstrings, flocObjectSetter, rows)

    def flocObjectSetter(x: FlocObject): PreparedStatementSetter[r, Unit, Unit] \ Write(r) =
        use BasicDb/PreparedStatementSetter.{putStringAt!};
        putStringAt!(0, x.structure) *> putStringAt!(1, x.parent) *> putStringAt!(2, x.child)
        
    def insertFlocObjectRowSql(tableName: String): String =
        String.unwords(
            "INSERT OR IGNORE INTO ${tableName} "
                :: "(structure_name, "
                :: "parent, "
                :: "child) "
                :: "VALUES(?,?,?);"
                :: Nil
        )


    // # Equi object Type Hierarchy


    pub def storeEquiObject(table: String, rows: t[EquiObject]): DbMonad[r, Unit, Int32] \ {IO, Write(r)} with Foldable[t] =
        let sqlstrings = { 
            prepStmt = insertEquiObjectRowSql(table),
            tableActions = "DELETE FROM ${table};" :: Nil
        };
        BasicDb/Writer.store(sqlstrings, equiObjectSetter, rows)

    def equiObjectSetter(x: EquiObject): PreparedStatementSetter[r, Unit, Unit] \ Write(r) =
        use BasicDb/PreparedStatementSetter.{putStringAt!};
        putStringAt!(0, x.category) 
            *> putStringAt!(1, x.parent) 
            *> putStringAt!(2, x.child)
        
    def insertEquiObjectRowSql(tableName: String): String =
        String.unwords(
            "INSERT OR IGNORE INTO ${tableName} "
                :: "(category, "
                :: "parent, "
                :: "child) "
                :: "VALUES(?,?,?);"
                :: Nil
        )



}
