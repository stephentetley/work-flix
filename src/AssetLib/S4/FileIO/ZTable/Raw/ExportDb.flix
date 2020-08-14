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

use AssetLib/Common/Utils.{foldMapRel};
use AssetLib/S4/FileIO/ZTable/Raw/Datatypes.{Eqobjl, Flocdes, Floobjl, Manuf, Obj};
use AssetLib/S4/FileIO/ZTable/Raw/BuiltinParsers.{DbPaths};
use AssetLib/S4/FileIO/ZTable/Raw/BuiltinParsers.{loadFloobjl};

namespace AssetLib/S4/FileIO/ZTable/Raw/ExportDb { 

    /// temp
    type alias PreparedStatement = FactIO/Internal/SQLite.PreparedStatement

    pub def outputDb(srcPaths: DbPaths, outPath: System.FilePath): Result[Unit, System.Error] & Impure =         
        use FactIO/SQLiteExport.{runSQLiteExport};
        runSQLiteExport(writeOutput(srcPaths), outPath)
        
    def writeOutput(srcPaths: DbPaths): SQLiteExport[Unit] =
        use FactIO/SQLiteExport.{flatMap, return, setAutoCommit, close, liftAction};
        let* _      = setAutoCommit(false);
        let* _      = liftAction(_ -> { Console.printLine("Floobjl"); Ok() });
        let* rs1    = liftAction(_ -> loadFloobjl(srcPaths.pathOfFloobjl));        
        let* nrows  = writeFloobjls(rs1);
        let* _      = liftAction(_ -> { Console.printLine("Row count: " + Int32.toString(nrows)); Ok()});
        let* _      = close();
        return()



    // Floobjl

    def writeFloobjls(rows: List[Floobjl]): SQLiteExport[Int32] =
        use FactIO/SQLiteExport.{flatMap, return, execute, foldM, prepareStatement, writeRow, commit};
        let* _          = execute("DROP TABLE IF EXISTS floobj");
        let* _          = execute(sqlCreateFlocobj());
        let* stmt       = prepareStatement("INSERT INTO floobj(structure, super_object, sub_object) VALUES(?,?,?)");
        let* nrows      = foldM((ac,x) -> { let* n = writeRow(stmt, floobjlRowWriter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)



    /// A RowWriter for Floobjl
    def floobjlRowWriter(src: Floobjl): SQLiteRowWriter[Unit] = 
        use FactIO/SQLiteRowWriter.{flatMap, return, putString!};
        let* _ = putString!(0, src.structure);
        let* _ = putString!(1, src.superObject);
        let* _ = putString!(2, src.subObject);
        return()




    // SQL DDL

    def sqlCreateFlocobj(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS floobj ("
                :: "structure       TEXT NOT NULL,"
                :: "super_object    TEXT NOT NULL,"
                :: "sub_object      TEXT NOT NULL"
                :: ")"
                :: Nil
        )

} 