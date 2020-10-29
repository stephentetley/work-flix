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
        use BasicDb/DbMonad.{flatMap, return, setAutoCommit, liftActionResult};
        use AssetLib/S4/FileIO/ZTable/Builtins.{loadEqobjl, loadFlocdes, loadFloobjl, loadManuf, loadObj};
        let* _      = setAutoCommit(false);
        let* rs1    = liftActionResult(_ -> loadEqobjl(srcPaths.eqobjlPath));
        let* _      = writeTable("Eqobjl", exportEqobjl(rs1));
        let* rs2    = liftActionResult(_ -> loadFlocdes(srcPaths.flocdesPath));
        let* _      = writeTable("Flocdes", exportFlocdes(rs2));
        let* rs3    = liftActionResult(_ -> loadFloobjl(srcPaths.floobjlPath));
        let* _      = writeTable("Foobjl", exportFloobjl(rs3));
        let* rs4    = liftActionResult(_ -> loadManuf(srcPaths.manufPath));
        let* _      = writeTable("Manuf", exportManuf(rs4));
        let* rs5    = liftActionResult(_ -> loadObj(srcPaths.objPath));
        let* _      = exportObj(tableNames.objectManuf, rs5);
        return()

    /// Remove....
    def writeTable(name: String, operation: DbMonad[Int32]): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, setAutoCommit, liftAction};
        let* _      = setAutoCommit(false);
        let* _      = liftAction(_ -> Console.printLine(name));
        let* nrows  = operation;
        let* _      = liftAction(_ -> Console.printLine("Row count: " + Int32.toString(nrows)));
        return()

    // Eqobjl
    def exportEqobjl(rows: List[Eqobjl]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldM, prepareStatement, psExecuteUpdate, commit};
        let* _          = execute("DROP TABLE IF EXISTS eqobjl");
        let* _          = execute(sqlCreateEqobjl());
        let* stmt       = prepareStatement("INSERT INTO eqobjl(super_object, sub_object, category) VALUES(?,?,?)");
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

    def exportFlocdes(rows: List[Flocdes]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldM, prepareStatement, psExecuteUpdate, commit};
        let* _          = execute("DROP TABLE IF EXISTS flocdes");
        let* _          = execute(sqlCreateFlocdes());
        let* stmt       = prepareStatement("INSERT INTO flocdes(object_type, description) VALUES(?,?)");
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

    def exportFloobjl(rows: List[Floobjl]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldM, prepareStatement, psExecuteUpdate, commit};
        let* _          = execute("DROP TABLE IF EXISTS floobj");
        let* _          = execute(sqlCreateFloobjl());
        let* stmt       = prepareStatement("INSERT INTO floobj(structure, super_object, sub_object) VALUES(?,?,?)");
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

    def exportManuf(rows: List[Manuf]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldM, prepareStatement, psExecuteUpdate, commit};
        let* _          = execute("DROP TABLE IF EXISTS manuf");
        let* _          = execute(sqlCreateManuf());
        let* stmt       = prepareStatement("INSERT INTO manuf(manufacturer, model) VALUES(?,?)");
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
        let* stmt       = prepareStatement("INSERT INTO ${tableName} (object_type, manufacturer) VALUES(?,?)");
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
    
    def sqlCreateEqobjl(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS eqobjl ("
                :: "super_object    TEXT NOT NULL,"
                :: "sub_object      TEXT NOT NULL,"
                :: "category        TEXT NOT NULL"
                :: ")"
                :: Nil
        )

    def sqlCreateFlocdes(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS flocdes ("
                :: "object_type     TEXT NOT NULL,"
                :: "description     TEXT NOT NULL"
                :: ")"
                :: Nil
        )

    def sqlCreateFloobjl(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS floobj ("
                :: "structure       TEXT NOT NULL,"
                :: "super_object    TEXT NOT NULL,"
                :: "sub_object      TEXT NOT NULL"
                :: ")"
                :: Nil
        )

    def sqlCreateManuf(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS manuf ("
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