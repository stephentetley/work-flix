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


namespace AssetLib/FileIO/S4/ZTable/ExportDb { 

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;

    use AssetLib/FileIO/S4/ZTable/Datatypes.{Eqobjl, Flocdes, Floobjl, Manuf, Obj};

    type alias ZTableNames = 
        { equipmentObject: String
        , flocDescription: String
        , flocObject: String
        , manufModel: String
        , objectManuf: String
        }

    pub def defaultTableNames(): ZTableNames = 
        { equipmentObject   = "zt_eqobjl"
        , flocDescription   = "zt_flocdes"
        , flocObject        = "zt_floobjl"
        , manufModel        = "zt_manuf"
        , objectManuf       = "zt_obj"
        }


    type alias ZTableSourcePaths = 
        { eqobjlPath: System.FilePath
        , flocdesPath: System.FilePath
        , floobjlPath: System.FilePath
        , manufPath: System.FilePath
        , objPath: System.FilePath
        }

        
    pub def storeZTableFiles(tableNames: ZTableNames, paths: ZTableSourcePaths): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, return};
        use BasicDb/DbMonad.{>>=};
        let* _  = storeEqobjl(tableNames.equipmentObject, paths.eqobjlPath) >>= logResults(tableNames.equipmentObject);
        let* _  = storeFlocdes(tableNames.flocDescription, paths.flocdesPath) >>= logResults(tableNames.flocDescription);
        let* _  = storeFloobjl(tableNames.flocObject, paths.floobjlPath) >>= logResults(tableNames.flocObject);
        let* _  = storeManuf(tableNames.manufModel, paths.manufPath) >>= logResults(tableNames.manufModel);
        let* _  = storeObj(tableNames.objectManuf, paths.objPath) >>= logResults(tableNames.objectManuf);
        return()

    def logResults(tableName: String, rowCount: Int32): DbMonad[Unit] = 
        use BasicDb/DbMonad.{liftAction};
        liftAction(_ -> Console.printLine("${tableName} wrote ${Int32.toString(rowCount)} rows"))


    // Eqobjl
    pub def storeEqobjl(tableName: String, src: System.FilePath): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, setAutoCommit, commit, liftActionResult};
        let* _      = setAutoCommit(false);
        let* rs1    = liftActionResult(_ -> AssetLib/FileIO/S4/ZTable/Builtins.loadEqobjl(src));
        let* n1     = exportEqobjl(tableName, rs1);
        let* _      = commit();
        return(n1)


    def exportEqobjl(tableName: String, rows: List[Eqobjl]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldLeftM, prepareStatement, psExecuteUpdate, commit};
        let* _          = execute("DROP TABLE IF EXISTS ${tableName};");
        let* _          = execute(sqlCreateEqobjl(tableName));
        let* stmt       = prepareStatement("INSERT INTO ${tableName} (super_object, sub_object, category) VALUES(?,?,?);");
        let* nrows      = foldLeftM((ac, x) -> { let* n = psExecuteUpdate(stmt, eqobjlRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)



    /// A RowSetter for Eqobjl
    def eqobjlRowSetter(src: Eqobjl): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!};
        let* _ = putStringAt!(0, src.superObject);
        let* _ = putStringAt!(1, src.subObject);
        let* _ = putStringAt!(2, src.category);
        return()



    // Flocdes
    pub def storeFlocdes(tableName: String, src: System.FilePath): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, setAutoCommit, commit, liftActionResult};
        let* _      = setAutoCommit(false);
        let* rs1    = liftActionResult(_ -> AssetLib/FileIO/S4/ZTable/Builtins.loadFlocdes(src));
        let* n1     = exportFlocdes(tableName, rs1);
        let* _      = commit();
        return(n1)

    def exportFlocdes(tableName: String, rows: List[Flocdes]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldLeftM, prepareStatement, psExecuteUpdate, commit};
        let* _          = execute("DROP TABLE IF EXISTS ${tableName};");
        let* _          = execute(sqlCreateFlocdes(tableName));
        let* stmt       = prepareStatement("INSERT INTO ${tableName} (object_type, description) VALUES(?,?);");
        let* nrows      = foldLeftM((ac, x) -> { let* n = psExecuteUpdate(stmt, flocdesRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)



    /// A RowSetter for Flocdes
    def flocdesRowSetter(src: Flocdes): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!};
        let* _ = putStringAt!(0, src.objectType);
        let* _ = putStringAt!(1, src.description);
        return()


    // Floobjl
    pub def storeFloobjl(tableName: String, src: System.FilePath): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, setAutoCommit, commit, liftActionResult};
        let* _      = setAutoCommit(false);
        let* rs1    = liftActionResult(_ -> AssetLib/FileIO/S4/ZTable/Builtins.loadFloobjl(src));
        let* n1     = exportFloobjl(tableName, rs1);
        let* _      = commit();
        return(n1)

    def exportFloobjl(tableName: String, rows: List[Floobjl]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldLeftM, prepareStatement, psExecuteUpdate, commit};
        let* _          = execute("DROP TABLE IF EXISTS ${tableName};");
        let* _          = execute(sqlCreateFloobjl(tableName));
        let* stmt       = prepareStatement("INSERT INTO ${tableName} (structure, super_object, sub_object) VALUES(?,?,?);");
        let* nrows      = foldLeftM((ac, x) -> { let* n = psExecuteUpdate(stmt, floobjlRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)



    /// A RowSetter for Floobjl
    def floobjlRowSetter(src: Floobjl): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!};
        let* _ = putStringAt!(0, src.structure);
        let* _ = putStringAt!(1, src.superObject);
        let* _ = putStringAt!(2, src.subObject);
        return()

    // Manuf
    pub def storeManuf(tableName: String, src: System.FilePath): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, setAutoCommit, commit, liftActionResult};
        let* _      = setAutoCommit(false);
        let* rs1    = liftActionResult(_ -> AssetLib/FileIO/S4/ZTable/Builtins.loadManuf(src));
        let* n1     = exportManuf(tableName, rs1);
        let* _      = commit();
        return(n1)

    def exportManuf(tableName: String, rows: List[Manuf]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldLeftM, prepareStatement, psExecuteUpdate, commit};
        let* _          = execute("DROP TABLE IF EXISTS ${tableName};");
        let* _          = execute(sqlCreateManuf(tableName));
        let* stmt       = prepareStatement("INSERT INTO ${tableName} (manufacturer, model) VALUES(?,?);");
        let* nrows      = foldLeftM((ac, x) -> { let* n = psExecuteUpdate(stmt, manufRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)

    /// A RowSetter for Manuf
    def manufRowSetter(src: Manuf): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!};
        let* _ = putStringAt!(0, src.manufacturer);
        let* _ = putStringAt!(1, src.model);
        return()

    /// Obj
    pub def storeObj(tableName: String, src: System.FilePath): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, setAutoCommit, commit, liftActionResult};
        let* _      = setAutoCommit(false);
        let* rs1    = liftActionResult(_ -> AssetLib/FileIO/S4/ZTable/Builtins.loadObj(src));
        let* n1     = exportObj(tableName, rs1);
        let* _      = commit();
        return(n1)

    /// Always drop table (fresh new data)
    def exportObj(tableName: String, rows: List[Obj]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldLeftM, prepareStatement, psExecuteUpdate, commit};
        let* _          = execute("DROP TABLE IF EXISTS ${tableName};");
        let* _          = execute(createTableObjSql(tableName));
        let* stmt       = prepareStatement("INSERT INTO ${tableName} (object_type, manufacturer) VALUES(?,?);");
        let* nrows      = foldLeftM((ac, x) -> { let* n = psExecuteUpdate(stmt, objRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)



    /// A RowSetter for Obj
    def objRowSetter(src: Obj): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!};
        let* _ = putStringAt!(0, src.objectType);
        let* _ = putStringAt!(1, src.manufacturer);
        return()

    // SQL DDL
    
    def sqlCreateEqobjl(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "super_object    TEXT NOT NULL,"
                :: "sub_object      TEXT NOT NULL,"
                :: "category        TEXT NOT NULL"
                :: ")"
                :: Nil
        )

    def sqlCreateFlocdes(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "object_type     TEXT NOT NULL,"
                :: "description     TEXT NOT NULL"
                :: ")"
                :: Nil
        )

    def sqlCreateFloobjl(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "structure       TEXT NOT NULL,"
                :: "super_object    TEXT NOT NULL,"
                :: "sub_object      TEXT NOT NULL"
                :: ")"
                :: Nil
        )

    def sqlCreateManuf(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "manufacturer    TEXT NOT NULL,"
                :: "model           TEXT NOT NULL"
                :: ")"
                :: Nil
        )

    def createTableObjSql(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "object_type     TEXT NOT NULL,"
                :: "manufacturer    TEXT NOT NULL"                
                :: ")"
                :: Nil
        )

} 