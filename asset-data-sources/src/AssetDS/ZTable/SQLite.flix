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


namespace AssetDS/ZTable/SQLite {

    use Functor.{<$>};
    use Applicative.{<*>, *>};

    use Basis/NIO/File.Path;

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

    use AssetDS/ZTable/Datatypes.{ObjTypeManufacturer, ManufacturerModel, FlocObject, EquiObject};

    // # Objtype Manuf

    pub def readAndStoreObjTypeManufacturer(path: Path): DbMonad[r, Unit, Unit] \ {IO, Write(r)} =
        use BasicDb/DbMonad.{flatMap, point, liftActionResult};
        let* ans    = liftActionResult(_ -> AssetDS/ZTable/Builtins.loadObjTypeManufacturer(path));
        let* _      = storeObjTypeManufacturer(ans);
        point()


    pub def storeObjTypeManufacturer(rows: t[ObjTypeManufacturer]): DbMonad[r, Unit, Int32] \ {IO, Write(r)} with Foldable[t] =
        let sqlstrings = { 
            prepStmt = insertObjTypeManufacturerRowSql(),
            tableActions = "DELETE FROM ztable_obj;" :: Nil
        };
        BasicDb/Writer.store(sqlstrings, objTypeManufacturerSetter, rows)


    def objTypeManufacturerSetter(x: ObjTypeManufacturer): PreparedStatementSetter[r, Unit, Unit] \ Write(r) =
        use BasicDb/PreparedStatementSetter.{point, putStringAt!};
        putStringAt!(0, x.objectType) *> putStringAt!(1, x.manufacturer)

    def insertObjTypeManufacturerRowSql(): String =
        String.unwords(
            "INSERT OR IGNORE INTO ztable_obj "
                :: "(object_type, "
                :: "manufacturer) "
                :: "VALUES(?,?);"
                :: Nil
        )


    pub def createObjTypeManufacturerTable(): DbMonad[r, Unit, Unit] \ {IO, Write(r)} =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit!, executeSql!, commit!};
        let* _  = setAutoCommit!(false);
        let* _  = executeSql!("DROP TABLE IF EXISTS ztable_obj;");
        let* _  = executeSql!(objTypeManufacturerTableDdl());
        let* _  = commit!();
        point()

    def objTypeManufacturerTableDdl(): String =
        String.unlines(
            "CREATE TABLE IF NOT EXISTS ztable_obj ("
                :: "object_type TEXT NOT NULL, "
                :: "manufacturer TEXT NOT NULL, "
                :: "PRIMARY KEY(object_type, manufacturer) "
                :: ");"
                :: Nil
            )

    // # Manufacturer Model


    pub def readAndStoreManufacturerModel(path: Path): DbMonad[r, Unit, Unit] \ {IO, Write(r)} =
        use BasicDb/DbMonad.{flatMap, point, liftActionResult};
        let* ans    = liftActionResult(_ -> AssetDS/ZTable/Builtins.loadManufacturerModel(path));
        let* _      = storeManufacturerModel(ans);
        point()

    pub def storeManufacturerModel(rows: t[ManufacturerModel]): DbMonad[r, Unit, Int32] \ {IO, Write(r)} with Foldable[t] =
        let sqlstrings = { 
            prepStmt = insertManufacturerModelRowSql(),
            tableActions = "DELETE FROM ztable_manuf;" :: Nil
        };
        BasicDb/Writer.store(sqlstrings, manufacturerModelSetter, rows)

    def manufacturerModelSetter(x: ManufacturerModel): PreparedStatementSetter[r, Unit, Unit] \ Write(r) =
        use BasicDb/PreparedStatementSetter.{putStringAt!};
        putStringAt!(0, x.manufacturer) *> putStringAt!(1, x.model)
        
    def insertManufacturerModelRowSql(): String =
        String.unwords(
            "INSERT OR IGNORE INTO ztable_manuf "
                :: "(manufacturer, "
                :: "model) "
                :: "VALUES(?,?);"
                :: Nil
        )



    pub def createManufacturerModelTable(): DbMonad[r, Unit, Unit] \ {IO, Write(r)} =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit!, executeSql!, commit!};
        let* _  = setAutoCommit!(false);
        let* _  = executeSql!("DROP TABLE IF EXISTS ztable_manuf;");
        let* _  = executeSql!(manufacturerModelTableDdl());
        let* _  = commit!();
        point()

    def manufacturerModelTableDdl(): String =
        String.unlines(
            "CREATE TABLE IF NOT EXISTS ztable_manuf ("
                :: "manufacturer TEXT NOT NULL, "
                :: "model TEXT NOT NULL, "
                :: "PRIMARY KEY(manufacturer, model) "
                :: ");"
                :: Nil
            )

    // # Floc Object Type Hierarchy


    pub def readAndStoreFlocObject(path: Path): DbMonad[r, Unit, Unit] \ {IO, Write(r)} =
        use BasicDb/DbMonad.{flatMap, point, liftActionResult};
        let* ans    = liftActionResult(_ -> AssetDS/ZTable/Builtins.loadFlocObject(path));
        let* _      = storeFlocObject(ans);
        point()


    pub def storeFlocObject(rows: t[FlocObject]): DbMonad[r, Unit, Int32] \ {IO, Write(r)}with Foldable[t] =
        let sqlstrings = { 
            prepStmt = insertFlocObjectRowSql(),
            tableActions = "DELETE FROM ztable_floobjl;" :: Nil
        };
        BasicDb/Writer.store(sqlstrings, flocObjectSetter, rows)

    def flocObjectSetter(x: FlocObject): PreparedStatementSetter[r, Unit, Unit] \ Write(r) =
        use BasicDb/PreparedStatementSetter.{putStringAt!};
        putStringAt!(0, x.structure) *> putStringAt!(1, x.parent) *> putStringAt!(2, x.child)
        
    def insertFlocObjectRowSql(): String =
        String.unwords(
            "INSERT OR IGNORE INTO ztable_floobjl "
                :: "(structure_name, "
                :: "parent, "
                :: "child) "
                :: "VALUES(?,?,?);"
                :: Nil
        )

    pub def createFlocObjectTable(): DbMonad[r, Unit, Unit] \ {IO, Write(r)} =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit!, executeSql!, commit!};
        let* _  = setAutoCommit!(false);
        let* _  = executeSql!("DROP TABLE IF EXISTS ztable_floobjl;");
        let* _  = executeSql!(flocObjectDdl());
        let* _  = commit!();
        point()

    def flocObjectDdl(): String =
        String.unlines(
            "CREATE TABLE IF NOT EXISTS ztable_floobjl ("
                :: "structure_name TEXT NOT NULL, "
                :: "parent TEXT NOT NULL, "
                :: "child TEXT NOT NULL, "
                :: "PRIMARY KEY(structure_name, parent, child) "
                :: ");"
                :: Nil
            )

    // # Equi object Type Hierarchy


    pub def readAndStoreEquiObject(path: Path): DbMonad[r, Unit, Unit] \ {IO, Write(r)} =
        use BasicDb/DbMonad.{flatMap, point, liftActionResult};
        let* ans    = liftActionResult(_ -> AssetDS/ZTable/Builtins.loadEquiObject(path));
        let* _      = storeEquiObject(ans);
        point()

    pub def storeEquiObject(rows: t[EquiObject]): DbMonad[r, Unit, Int32] \ {IO, Write(r)} with Foldable[t] =
        let sqlstrings = { 
            prepStmt = insertEquiObjectRowSql(),
            tableActions = "DELETE FROM ztable_eqobjl;" :: Nil
        };
        BasicDb/Writer.store(sqlstrings, equiObjectSetter, rows)

    def equiObjectSetter(x: EquiObject): PreparedStatementSetter[r, Unit, Unit] \ Write(r) =
        use BasicDb/PreparedStatementSetter.{putStringAt!};
        putStringAt!(0, x.category) 
            *> putStringAt!(1, x.parent) 
            *> putStringAt!(2, x.child)
        
    def insertEquiObjectRowSql(): String =
        String.unwords(
            "INSERT OR IGNORE INTO ztable_eqobjl "
                :: "(category, "
                :: "parent, "
                :: "child) "
                :: "VALUES(?,?,?);"
                :: Nil
        )


    pub def createEquiObjectTable(): DbMonad[r, Unit, Unit] \ {IO, Write(r)} =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit!, executeSql!, commit!};
        let* _  = setAutoCommit!(false);
        let* _  = executeSql!("DROP TABLE IF EXISTS ztable_eqobjl;");
        let* _  = executeSql!(equiObjectDdl());
        let* _  = commit!();
        point()

    def equiObjectDdl(): String =
        String.unlines(
            "CREATE TABLE IF NOT EXISTS ztable_eqobjl ("
                :: "category TEXT NOT NULL, "
                :: "parent TEXT NOT NULL, "
                :: "child TEXT NOT NULL, "
                :: "PRIMARY KEY(category, parent, child) "
                :: ");"
                :: Nil
            )

}
