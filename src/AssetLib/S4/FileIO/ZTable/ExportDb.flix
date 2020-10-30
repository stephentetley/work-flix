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


namespace AssetLib/S4/FileIO/ZTable/ExportDb { 

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;

    use AssetLib/S4/FileIO/ZTable/Datatypes.{Eqobjl, Flocdes, Floobjl, Manuf, Obj};

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

        
    pub def storeZTableFiles(tableNames: ZTableNames, srcPaths: ZTableSourcePaths): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, return, setAutoCommit, commit, liftActionResult};
        use BasicDb/DbMonad.{>>=};
        use AssetLib/S4/FileIO/ZTable/Builtins.{loadEqobjl, loadFlocdes, loadFloobjl, loadManuf, loadObj};
        let* _      = setAutoCommit(false);
        let* rs1    = liftActionResult(_ -> loadEqobjl(srcPaths.eqobjlPath));
        let* _      = exportEqobjl(tableNames.equipmentObject, rs1) >>= logResults(tableNames.equipmentObject);
        let* rs2    = liftActionResult(_ -> loadFlocdes(srcPaths.flocdesPath));
        let* _      = exportFlocdes(tableNames.flocDescription, rs2) >>= logResults(tableNames.flocDescription);
        let* rs3    = liftActionResult(_ -> loadFloobjl(srcPaths.floobjlPath));
        let* _      = exportFloobjl(tableNames.flocObject, rs3) >>= logResults(tableNames.flocObject);
        let* rs4    = liftActionResult(_ -> loadManuf(srcPaths.manufPath));
        let* _      = exportManuf(tableNames.manufModel, rs4) >>= logResults(tableNames.manufModel);
        let* rs5    = liftActionResult(_ -> loadObj(srcPaths.objPath));
        let* _      = exportObj(tableNames.objectManuf, rs5) >>= logResults(tableNames.objectManuf);
        let* _      = commit();
        return()

    def logResults(tableName: String, rowCount: Int32): DbMonad[Unit] = 
        use BasicDb/DbMonad.{liftAction};
        liftAction(_ -> Console.printLine("${tableName} wrote ${Int32.toString(rowCount)} rows"))

    // Eqobjl
    def exportEqobjl(tableName: String, rows: List[Eqobjl]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldM, prepareStatement, psExecuteUpdate, commit};
        let* _          = execute("DROP TABLE IF EXISTS ${tableName};");
        let* _          = execute(sqlCreateEqobjl(tableName));
        let* stmt       = prepareStatement("INSERT INTO ${tableName} (super_object, sub_object, category) VALUES(?,?,?);");
        let* nrows      = foldM((ac, x) -> { let* n = psExecuteUpdate(stmt, eqobjlRowSetter(x)); return(ac+n)}, 0, rows);
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

    def exportFlocdes(tableName: String, rows: List[Flocdes]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldM, prepareStatement, psExecuteUpdate, commit};
        let* _          = execute("DROP TABLE IF EXISTS ${tableName};");
        let* _          = execute(sqlCreateFlocdes(tableName));
        let* stmt       = prepareStatement("INSERT INTO ${tableName} (object_type, description) VALUES(?,?);");
        let* nrows      = foldM((ac, x) -> { let* n = psExecuteUpdate(stmt, flocdesRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)



    /// A RowSetter for Flocdes
    def flocdesRowSetter(src: Flocdes): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!};
        let* _ = putStringAt!(0, src.objectType);
        let* _ = putStringAt!(1, src.description);
        return()


    // Floobjl

    def exportFloobjl(tableName: String, rows: List[Floobjl]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldM, prepareStatement, psExecuteUpdate, commit};
        let* _          = execute("DROP TABLE IF EXISTS ${tableName};");
        let* _          = execute(sqlCreateFloobjl(tableName));
        let* stmt       = prepareStatement("INSERT INTO ${tableName} (structure, super_object, sub_object) VALUES(?,?,?);");
        let* nrows      = foldM((ac, x) -> { let* n = psExecuteUpdate(stmt, floobjlRowSetter(x)); return(ac+n)}, 0, rows);
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

    def exportManuf(tableName: String, rows: List[Manuf]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldM, prepareStatement, psExecuteUpdate, commit};
        let* _          = execute("DROP TABLE IF EXISTS ${tableName};");
        let* _          = execute(sqlCreateManuf(tableName));
        let* stmt       = prepareStatement("INSERT INTO ${tableName} (manufacturer, model) VALUES(?,?);");
        let* nrows      = foldM((ac, x) -> { let* n = psExecuteUpdate(stmt, manufRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)



    /// A RowSetter for Manuf
    def manufRowSetter(src: Manuf): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!};
        let* _ = putStringAt!(0, src.manufacturer);
        let* _ = putStringAt!(1, src.model);
        return()

    // Obj
    
    /// Always drop table (fresh new data)
    def exportObj(tableName: String, rows: List[Obj]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldM, prepareStatement, psExecuteUpdate, commit};
        let* _          = execute("DROP TABLE IF EXISTS ${tableName};");
        let* _          = execute(createTableObjSql(tableName));
        let* stmt       = prepareStatement("INSERT INTO ${tableName} (object_type, manufacturer) VALUES(?,?);");
        let* nrows      = foldM((ac, x) -> { let* n = psExecuteUpdate(stmt, objRowSetter(x)); return(ac+n)}, 0, rows);
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