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
use FactIO.SQLiteWriteList;
use FactIO.SQLiteRowWriter;

use AssetLib/Common/Utils.{foldMapRel};
use AssetLib/S4/FileIO/ZTable/Raw/Relations.{Eqobjl, Flocdes, Floobjl, Manuf, Obj};


namespace AssetLib/S4/FileIO/ZTable/Raw/ExportDb { 



    pub def outputDb[r](src: #{Eqobjl, Flocdes, Floobjl, Manuf, Obj |r}, outpath: System.FilePath): Result[Unit, System.Error] & Impure =         
        use FactIO/SQLiteExport.{runSQLiteExport};
        runSQLiteExport(writeOutput(src), outpath)
        
    def writeOutput[r](src: #{Eqobjl, Flocdes, Floobjl, Manuf, Obj |r}): SQLiteExport[Unit] =
        use FactIO/SQLiteExport.{flatMap, return, setAutoCommit, close, liftAction};
        let* _      = setAutoCommit(false);
        let* _      = liftAction(_ -> { Console.printLine("Floobjl"); Ok() });
        let* _      = writeFloobjl(src);
        let* _      = close();
        return()



    // Floobjl

    def writeFloobjl[r](relns: #{Floobjl | r}): SQLiteExport[Unit] =
        use FactIO/SQLiteExport.{flatMap, return, execute, emptySQLiteWriteList, execWriteList, commit};
        let* _          = execute("DROP TABLE IF EXISTS flocobj");
        let* _          = execute(sqlCreateFlocobj());
        let stmt        = "INSERT INTO flocobj(structure, super_floc, sub_floc) VALUES(?,?,?)";
        let writes      = fold Floobjl emptySQLiteWriteList() writeFloobjlStep() relns;
        let* _          = execWriteList(stmt, writes);
        let* _          = commit();
        return()


    def writeFloobjlStep(): ((String, String, String), SQLiteWriteList) -> SQLiteWriteList = 
        FactIO/SQLiteExport.makeSQLiteWriteStep(writeFloobjlRow)

    /// A RowWriter for the body of a Floobjl
    def writeFloobjlRow(src: (String, String, String)): SQLiteRowWriter[Unit] = 
        use FactIO/SQLiteRowWriter.{flatMap, return, putString!};
        let (structure, superFloc, subFloc) = src;
        let* _ = putString!(0, structure);
        let* _ = putString!(1, superFloc);
        let* _ = putString!(2, subFloc);
        return()




    // SQL DDL

    def sqlCreateFlocobj(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS flocobj ("
                :: "structure       TEXT NOT NULL,"
                :: "super_floc      TEXT NOT NULL,"
                :: "sub_floc        TEXT NOT NULL"
                :: ")"
                :: Nil
        )

} 