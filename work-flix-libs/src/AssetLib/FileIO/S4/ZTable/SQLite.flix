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


namespace AssetLib/FileIO/S4/ZTable/SQLite {

    use Functor.{<$>};
    use Applicative.{<*>, *>};

    use Basis/System.FilePath;

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

    use AssetLib/FileIO/S4/ZTable/Datatypes.{ObjTypeManufacturer, ManufacturerModel, FlocObject, EquiObject};

    // # Objtype Manuf

    pub def readAndStoreObjTypeManufacturer(table: String, path: FilePath): DbMonad[List[ObjTypeManufacturer]]=
        use BasicDb/DbMonad.{flatMap, point, liftActionResult};
        let* ans    = liftActionResult(_ -> AssetLib/FileIO/S4/ZTable/Builtins.loadObjTypeManufacturer(path));
        let* _      = storeObjTypeManufacturer(table, ans);
        point(ans)


    pub def storeObjTypeManufacturer(table: String, rows: t[ObjTypeManufacturer]): DbMonad[Int32] with Foldable[t] =
        let sqlstrings = { 
            prepStmt = insertObjTypeManufacturerRowSql(table),
            tableActions = "DELETE FROM ${table};" :: Nil
        };
        BasicDb/Writer.store(sqlstrings, objTypeManufacturerSetter, rows)


    def objTypeManufacturerSetter(x: ObjTypeManufacturer): PreparedStatementSetter[Unit] =
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

    pub def readObjTypeManufacturer(tableName: String): DbMonad[List[ObjTypeManufacturer]] =         
        let sql = "SELECT object_type, manufacturer FROM ${tableName} ORDER BY object_type;";
        BasicDb/Reader.allRows(evalObjTypeManufacturer(), sql)

    
    def evalObjTypeManufacturer(): RowEvaluator[ObjTypeManufacturer] = 
        use BasicDb/RowEvaluator.{getStringAt};
        ((x1, x2) -> {objectType = x1, manufacturer = x2})
            <$> getStringAt(0)
            <*> getStringAt(1)

    pub def createObjTypeManufacturerTable(tableName: String): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit, execute, commit};
        let* _  = setAutoCommit(false);
        let* _  = execute("DROP TABLE IF EXISTS ${tableName};");
        let* _  = execute(objTypeManufacturerTableDdl(tableName));
        let* _  = commit();
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


    pub def readAndStoreManufacturerModel(table: String, path: FilePath): DbMonad[List[ManufacturerModel]]=
        use BasicDb/DbMonad.{flatMap, point, liftActionResult};
        let* ans    = liftActionResult(_ -> AssetLib/FileIO/S4/ZTable/Builtins.loadManufacturerModel(path));
        let* _      = storeManufacturerModel(table, ans);
        point(ans)

    pub def storeManufacturerModel(table: String, rows: t[ManufacturerModel]): DbMonad[Int32] with Foldable[t] =
        let sqlstrings = { 
            prepStmt = insertManufacturerModelRowSql(table),
            tableActions = "DELETE FROM ${table};" :: Nil
        };
        BasicDb/Writer.store(sqlstrings, manufacturerModelSetter, rows)

    def manufacturerModelSetter(x: ManufacturerModel): PreparedStatementSetter[Unit] =
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


    pub def readManufacturerModel(tableName: String): DbMonad[List[ManufacturerModel]] =         
        let sql = "SELECT manufacturer, model FROM ${tableName} ORDER BY manufacturer;";
        BasicDb/Reader.allRows(evalManufacturerModel(), sql)

    def evalManufacturerModel(): RowEvaluator[ManufacturerModel] = 
        use BasicDb/RowEvaluator.{getStringAt};
        ((x1, x2) -> {manufacturer = x1, model = x2})
            <$> getStringAt(0)
            <*> getStringAt(1)

    pub def createManufacturerModelTable(tableName: String): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit, execute, commit};
        let* _  = setAutoCommit(false);
        let* _  = execute("DROP TABLE IF EXISTS ${tableName};");
        let* _  = execute(manufacturerModelTableDdl(tableName));
        let* _  = commit();
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


    pub def storeFlocObject(table: String, rows: t[FlocObject]): DbMonad[Int32] with Foldable[t] =
        let sqlstrings = { 
            prepStmt = insertFlocObjectRowSql(table),
            tableActions = "DELETE FROM ${table};" :: Nil
        };
        BasicDb/Writer.store(sqlstrings, flocObjectSetter, rows)

    def flocObjectSetter(x: FlocObject): PreparedStatementSetter[Unit] =
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

    pub def readFlocObject(tableName: String): DbMonad[List[FlocObject]] =         
        let sql = "SELECT structure_name, parent, child FROM ${tableName} ORDER BY structure_name;";
        BasicDb/Reader.allRows(evalFlocObject(), sql)

    
    def evalFlocObject(): RowEvaluator[FlocObject] = 
        use BasicDb/RowEvaluator.{getStringAt};
        ((x1, x2, x3) -> {structure = x1, parent = x2, child = x3})
            <$> getStringAt(0)
            <*> getStringAt(1)
            <*> getStringAt(2)


    // # Equi object Type Hierarchy


    pub def storeEquiObject(table: String, rows: t[EquiObject]): DbMonad[Int32] with Foldable[t] =
        let sqlstrings = { 
            prepStmt = insertEquiObjectRowSql(table),
            tableActions = "DELETE FROM ${table};" :: Nil
        };
        BasicDb/Writer.store(sqlstrings, equiObjectSetter, rows)

    def equiObjectSetter(x: EquiObject): PreparedStatementSetter[Unit] =
        use BasicDb/PreparedStatementSetter.{putStringAt!};
        putStringAt!(0, x.category) *> putStringAt!(1, x.parent) *> putStringAt!(2, x.child)
        
    def insertEquiObjectRowSql(tableName: String): String =
        String.unwords(
            "INSERT OR IGNORE INTO ${tableName} "
                :: "(category, "
                :: "parent, "
                :: "child) "
                :: "VALUES(?,?,?);"
                :: Nil
        )

    pub def readEquiObject(tableName: String): DbMonad[List[EquiObject]] =         
        let sql = "SELECT category, parent, child FROM ${tableName} ORDER BY category;";
        BasicDb/Reader.allRows(evalEquiObject(), sql)

    
    def evalEquiObject(): RowEvaluator[EquiObject] = 
        use BasicDb/RowEvaluator.{getStringAt};
        ((x1, x2, x3) -> {category = x1, parent = x2, child = x3})
            <$> getStringAt(0)
            <*> getStringAt(1)
            <*> getStringAt(2)



}
