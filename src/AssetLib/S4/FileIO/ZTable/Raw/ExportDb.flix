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

use FactIO.JdbcExport;
use FactIO.JdbcRowWriter;
use FactIO/JdbcExport.{PreparedStatement};

use AssetLib/Common/Utils.{foldMapRel};
use AssetLib/S4/FileIO/ZTable/Raw/Datatypes.{Eqobjl, Flocdes, Floobjl, Manuf, Obj};
use AssetLib/S4/FileIO/ZTable/Raw/BuiltinParsers.{DbPaths};

namespace AssetLib/S4/FileIO/ZTable/Raw/ExportDb { 



    pub def outputDb(srcPaths: DbPaths, outPath: System.FilePath): Result[Unit, System.Error] & Impure =         
        use FactIO/JdbcExport.{runSQLiteExport};
        runSQLiteExport(writeOutput(srcPaths), outPath)
        
    def writeOutput(srcPaths: DbPaths): JdbcExport[Unit] =
        use FactIO/JdbcExport.{flatMap, return, setAutoCommit, close, liftActionResult};
        use AssetLib/S4/FileIO/ZTable/Raw/BuiltinParsers.{loadEqobjl, loadFlocdes, loadFloobjl, loadManuf, loadObj};
        let* _      = setAutoCommit(false);
        let* rs1    = liftActionResult(_ -> loadEqobjl(srcPaths.pathOfEqobjl));
        let* _      = writeTable("Eqobjl", exportEqobjl(rs1));
        let* rs2    = liftActionResult(_ -> loadFlocdes(srcPaths.pathOfFlocdes));
        let* _      = writeTable("Flocdes", exportFlocdes(rs2));
        let* rs3    = liftActionResult(_ -> loadFloobjl(srcPaths.pathOfFloobjl));
        let* _      = writeTable("Foobjl", exportFloobjl(rs3));
        let* rs4    = liftActionResult(_ -> loadManuf(srcPaths.pathOfManuf));
        let* _      = writeTable("Manuf", exportManuf(rs4));
        let* rs5    = liftActionResult(_ -> loadObj(srcPaths.pathOfObj));
        let* _      = writeTable("Obj", exportObj(rs5));
        let* _      = close();
        return()

    def writeTable(name: String, operation: JdbcExport[Int32]): JdbcExport[Unit] = 
        use FactIO/JdbcExport.{flatMap, return, setAutoCommit, close, liftAction};
        let* _      = setAutoCommit(false);
        let* _      = liftAction(_ -> Console.printLine(name));
        let* nrows  = operation;
        let* _      = liftAction(_ -> Console.printLine("Row count: " + Int32.toString(nrows)));
        return()

    // Eqobjl
    def exportEqobjl(rows: List[Eqobjl]): JdbcExport[Int32] =
        use FactIO/JdbcExport.{flatMap, return, execute, foldM, prepareStatement, writeRow, commit};
        let* _          = execute("DROP TABLE IF EXISTS eqobjl");
        let* _          = execute(sqlCreateEqobjl());
        let* stmt       = prepareStatement("INSERT INTO eqobjl(super_object, sub_object, category) VALUES(?,?,?)");
        let* nrows      = foldM((ac, x) -> { let* n = writeRow(stmt, eqobjlRowWriter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)



    /// A RowWriter for Eqobjl
    def eqobjlRowWriter(src: Eqobjl): JdbcRowWriter[Unit] = 
        use FactIO/JdbcRowWriter.{flatMap, return, putString!};
        let* _ = putString!(0, src.superObject);
        let* _ = putString!(1, src.subObject);
        let* _ = putString!(2, src.category);
        return()



    // Flocdes

    def exportFlocdes(rows: List[Flocdes]): JdbcExport[Int32] =
        use FactIO/JdbcExport.{flatMap, return, execute, foldM, prepareStatement, writeRow, commit};
        let* _          = execute("DROP TABLE IF EXISTS flocdes");
        let* _          = execute(sqlCreateFlocdes());
        let* stmt       = prepareStatement("INSERT INTO flocdes(object_type, description) VALUES(?,?)");
        let* nrows      = foldM((ac, x) -> { let* n = writeRow(stmt, flocdesRowWriter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)



    /// A RowWriter for Flocdes
    def flocdesRowWriter(src: Flocdes): JdbcRowWriter[Unit] = 
        use FactIO/JdbcRowWriter.{flatMap, return, putString!};
        let* _ = putString!(0, src.objectType);
        let* _ = putString!(1, src.description);
        return()


    // Floobjl

    def exportFloobjl(rows: List[Floobjl]): JdbcExport[Int32] =
        use FactIO/JdbcExport.{flatMap, return, execute, foldM, prepareStatement, writeRow, commit};
        let* _          = execute("DROP TABLE IF EXISTS floobj");
        let* _          = execute(sqlCreateFloobjl());
        let* stmt       = prepareStatement("INSERT INTO floobj(structure, super_object, sub_object) VALUES(?,?,?)");
        let* nrows      = foldM((ac, x) -> { let* n = writeRow(stmt, floobjlRowWriter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)



    /// A RowWriter for Floobjl
    def floobjlRowWriter(src: Floobjl): JdbcRowWriter[Unit] = 
        use FactIO/JdbcRowWriter.{flatMap, return, putString!};
        let* _ = putString!(0, src.structure);
        let* _ = putString!(1, src.superObject);
        let* _ = putString!(2, src.subObject);
        return()

    // Manuf

    def exportManuf(rows: List[Manuf]): JdbcExport[Int32] =
        use FactIO/JdbcExport.{flatMap, return, execute, foldM, prepareStatement, writeRow, commit};
        let* _          = execute("DROP TABLE IF EXISTS manuf");
        let* _          = execute(sqlCreateManuf());
        let* stmt       = prepareStatement("INSERT INTO manuf(manufacturer, model) VALUES(?,?)");
        let* nrows      = foldM((ac, x) -> { let* n = writeRow(stmt, manufRowWriter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)



    /// A RowWriter for Manuf
    def manufRowWriter(src: Manuf): JdbcRowWriter[Unit] = 
        use FactIO/JdbcRowWriter.{flatMap, return, putString!};
        let* _ = putString!(0, src.manufacturer);
        let* _ = putString!(1, src.model);
        return()

    // Obj

    def exportObj(rows: List[Obj]): JdbcExport[Int32] =
        use FactIO/JdbcExport.{flatMap, return, execute, foldM, prepareStatement, writeRow, commit};
        let* _          = execute("DROP TABLE IF EXISTS obj");
        let* _          = execute(sqlCreateObj());
        let* stmt       = prepareStatement("INSERT INTO obj(object_type, manufacturer) VALUES(?,?)");
        let* nrows      = foldM((ac, x) -> { let* n = writeRow(stmt, objRowWriter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)



    /// A RowWriter for Obj
    def objRowWriter(src: Obj): JdbcRowWriter[Unit] = 
        use FactIO/JdbcRowWriter.{flatMap, return, putString!};
        let* _ = putString!(0, src.objectType);
        let* _ = putString!(1, src.manufacturer);
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

    def sqlCreateObj(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS obj ("
                :: "object_type     TEXT NOT NULL,"
                :: "manufacturer    TEXT NOT NULL"                
                :: ")"
                :: Nil
        )
} 