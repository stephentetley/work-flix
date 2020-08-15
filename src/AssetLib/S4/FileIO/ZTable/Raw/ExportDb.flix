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

use FactIO.SQLiteExport;
use FactIO.SQLiteRowWriter;
use FactIO/SQLiteExport.{PreparedStatement};

use AssetLib/Common/Utils.{foldMapRel};
use AssetLib/S4/FileIO/ZTable/Raw/Datatypes.{Eqobjl, Flocdes, Floobjl, Manuf, Obj};
use AssetLib/S4/FileIO/ZTable/Raw/BuiltinParsers.{DbPaths};

namespace AssetLib/S4/FileIO/ZTable/Raw/ExportDb { 



    pub def outputDb(srcPaths: DbPaths, outPath: System.FilePath): Result[Unit, System.Error] & Impure =         
        use FactIO/SQLiteExport.{runSQLiteExport};
        runSQLiteExport(writeOutput(srcPaths), outPath)
        
    def writeOutput(srcPaths: DbPaths): SQLiteExport[Unit] =
        use FactIO/SQLiteExport.{flatMap, return, setAutoCommit, close, liftAction};
        use AssetLib/S4/FileIO/ZTable/Raw/BuiltinParsers.{loadEqobjl, loadFlocdes, loadFloobjl, loadManuf, loadObj};
        let* _      = setAutoCommit(false);
        let* rs1    = liftAction(_ -> loadEqobjl(srcPaths.pathOfEqobjl));
        let* _      = writeTable("Eqobjl", setupEqobjl(rs1));
        let* rs2    = liftAction(_ -> loadFlocdes(srcPaths.pathOfFlocdes));
        let* _      = writeTable("Flocdes", setupFlocdes(rs2));
        let* rs3    = liftAction(_ -> loadFloobjl(srcPaths.pathOfFloobjl));
        let* _      = writeTable("Foobjl", setupFloobjl(rs3));
        let* rs4    = liftAction(_ -> loadManuf(srcPaths.pathOfManuf));
        let* _      = writeTable("Manuf", setupManuf(rs4));
        let* rs5    = liftAction(_ -> loadObj(srcPaths.pathOfObj));
        let* _      = writeTable("Obj", setupObj(rs5));
        let* _      = close();
        return()

    def writeTable(name: String, operation: SQLiteExport[Int32]): SQLiteExport[Unit] = 
        use FactIO/SQLiteExport.{flatMap, return, setAutoCommit, close, liftAction};
        let* _      = setAutoCommit(false);
        let* _      = liftAction(_ -> { Console.printLine(name); Ok() });
        let* nrows  = operation;
        let* _      = liftAction(_ -> { Console.printLine("Row count: " + Int32.toString(nrows)); Ok()});
        return()

    // Eqobjl
    def setupEqobjl(rows: List[Eqobjl]): SQLiteExport[Int32] =
        use FactIO/SQLiteExport.{flatMap, return, execute, foldM, prepareStatement, writeRow, commit};
        let* _          = execute("DROP TABLE IF EXISTS eqobjl");
        let* _          = execute(sqlCreateEqobjl());
        let* stmt       = prepareStatement("INSERT INTO eqobjl(super_object, sub_object, category) VALUES(?,?,?)");
        let* nrows      = foldM((ac, x) -> { let* n = writeRow(stmt, eqobjlRowWriter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)



    /// A RowWriter for Eqobjl
    def eqobjlRowWriter(src: Eqobjl): SQLiteRowWriter[Unit] = 
        use FactIO/SQLiteRowWriter.{flatMap, return, putString!};
        let* _ = putString!(0, src.superObject);
        let* _ = putString!(1, src.subObject);
        let* _ = putString!(2, src.category);
        return()



    // Flocdes

    def setupFlocdes(rows: List[Flocdes]): SQLiteExport[Int32] =
        use FactIO/SQLiteExport.{flatMap, return, execute, foldM, prepareStatement, writeRow, commit};
        let* _          = execute("DROP TABLE IF EXISTS flocdes");
        let* _          = execute(sqlCreateFlocdes());
        let* stmt       = prepareStatement("INSERT INTO flocdes(object_type, description) VALUES(?,?)");
        let* nrows      = foldM((ac, x) -> { let* n = writeRow(stmt, flocdesRowWriter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)



    /// A RowWriter for Flocdes
    def flocdesRowWriter(src: Flocdes): SQLiteRowWriter[Unit] = 
        use FactIO/SQLiteRowWriter.{flatMap, return, putString!};
        let* _ = putString!(0, src.objectType);
        let* _ = putString!(1, src.description);
        return()


    // Floobjl

    def setupFloobjl(rows: List[Floobjl]): SQLiteExport[Int32] =
        use FactIO/SQLiteExport.{flatMap, return, execute, foldM, prepareStatement, writeRow, commit};
        let* _          = execute("DROP TABLE IF EXISTS floobj");
        let* _          = execute(sqlCreateFloobjl());
        let* stmt       = prepareStatement("INSERT INTO floobj(structure, super_object, sub_object) VALUES(?,?,?)");
        let* nrows      = foldM((ac, x) -> { let* n = writeRow(stmt, floobjlRowWriter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)



    /// A RowWriter for Floobjl
    def floobjlRowWriter(src: Floobjl): SQLiteRowWriter[Unit] = 
        use FactIO/SQLiteRowWriter.{flatMap, return, putString!};
        let* _ = putString!(0, src.structure);
        let* _ = putString!(1, src.superObject);
        let* _ = putString!(2, src.subObject);
        return()

    // Manuf

    def setupManuf(rows: List[Manuf]): SQLiteExport[Int32] =
        use FactIO/SQLiteExport.{flatMap, return, execute, foldM, prepareStatement, writeRow, commit};
        let* _          = execute("DROP TABLE IF EXISTS manuf");
        let* _          = execute(sqlCreateManuf());
        let* stmt       = prepareStatement("INSERT INTO manuf(manufacturer, model) VALUES(?,?)");
        let* nrows      = foldM((ac, x) -> { let* n = writeRow(stmt, manufRowWriter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)



    /// A RowWriter for Manuf
    def manufRowWriter(src: Manuf): SQLiteRowWriter[Unit] = 
        use FactIO/SQLiteRowWriter.{flatMap, return, putString!};
        let* _ = putString!(0, src.manufacturer);
        let* _ = putString!(1, src.model);
        return()

    // Obj

    def setupObj(rows: List[Obj]): SQLiteExport[Int32] =
        use FactIO/SQLiteExport.{flatMap, return, execute, foldM, prepareStatement, writeRow, commit};
        let* _          = execute("DROP TABLE IF EXISTS obj");
        let* _          = execute(sqlCreateObj());
        let* stmt       = prepareStatement("INSERT INTO obj(object_type, manufacturer) VALUES(?,?)");
        let* nrows      = foldM((ac, x) -> { let* n = writeRow(stmt, objRowWriter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)



    /// A RowWriter for Obj
    def objRowWriter(src: Obj): SQLiteRowWriter[Unit] = 
        use FactIO/SQLiteRowWriter.{flatMap, return, putString!};
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