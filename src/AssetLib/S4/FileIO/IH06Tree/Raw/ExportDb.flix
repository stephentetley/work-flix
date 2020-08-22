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
use FactIO/SQLiteExport.{PreparedStatement};

use Data.RoseTree.{RoseTree};

use AssetLib/S4/FileIO/IH06Tree/Raw/Datatypes.{IH06Tree, IH06Node, FlocNode, EquiNode};
use AssetLib/S4/FileIO/IH06Tree/Raw/Datatypes.IH06Node.{FlocNode, EquiNode};
use AssetLib/S4/FileIO/IH06Tree/Raw/Builder.{buildIH06Trees};
use AssetLib/S4/FileIO/IH06Tree/Raw/Parser.{parseFile};

namespace AssetLib/S4/FileIO/IH06Tree/Raw/ExportDb { 

    pub def exportDb(sourceFile: System.FilePath, outpath: System.FilePath): Result[Unit, System.Error] & Impure = 
        use Result.flatMap;
        let* ast    = parseFile(sourceFile);
        let ans     = buildIH06Trees(ast);
        let* _      = outputDb(ans, outpath);        
        Ok()


    pub def outputDb(xs: List[IH06Tree], outpath: System.FilePath): Result[Unit, System.Error] & Impure =         
        use FactIO/SQLiteExport.{runSQLiteExport};
        runSQLiteExport(writeOutput(xs), outpath)
        
    def writeOutput(xs: List[IH06Tree]): SQLiteExport[Unit] =
        use FactIO/SQLiteExport.{flatMap, return, setAutoCommit, close, liftAction};
        let* _      = setAutoCommit(false);
        let* _      = liftAction(_ -> { Console.printLine("Flocs..."); Ok() });
        let* n1     = exportFlocNodes(xs);
        let* _      = liftAction(_ -> { Console.printLine(Int32.toString(n1)); Ok() });
        let* _      = liftAction(_ -> { Console.printLine("Equi..."); Ok() });
        let* n2     = exportEquiNodes(xs);
        let* _      = liftAction(_ -> { Console.printLine(Int32.toString(n2)); Ok() });
        let* _      = close();
        return()


    // FlocNodes
    def exportFlocNodes(xs: List[IH06Tree]): SQLiteExport[Int32] =
        use FactIO/SQLiteExport.{flatMap, return, execute, foldM, prepareStatement, commit};
        let* _          = execute("DROP TABLE IF EXISTS floc_node");
        let* _          = execute(sqlCreateFlocNode());
        let* stmt       = prepareStatement("INSERT INTO floc_node(floc, level, description, parent) VALUES(?,?,?,?)");
        let* nrows      = foldM((ac, x) -> { let* n = emitIH06Flocs(stmt, x); return(ac+n)}, 0, xs);
        let* _          = commit();
        return(nrows)

    def emitIH06Flocs(stmt: PreparedStatement, src: IH06Tree): SQLiteExport[Int32] = 
        use FactIO/SQLiteExport.{flatMap, return, mapAccumX};
        let RoseTree(label, kids) = src;
        let* n = emitFlocNode(stmt, label);
        mapAccumX((ac,x) -> {let* i = emitIH06Flocs(stmt, x); return(ac+i)}, n, kids)

    def emitFlocNode(stmt: PreparedStatement, src: IH06Node): SQLiteExport[Int32] = 
        use FactIO/SQLiteExport.{return, writeRow};
        match src { 
            case FlocNode(r) => writeRow(stmt, flocNodeRowWriter(r))
            case _           => return(0)
        }

     /// A RowWriter for FlocNode
    def flocNodeRowWriter(x: FlocNode): SQLiteRowWriter[Unit] = 
        use FactIO/SQLiteRowWriter.{flatMap, return, putString!, putInt32!};
        let* _ = putString!(0,  x.floc);
        let* _ = putInt32!(1,   x.level);
        let* _ = putString!(2,  x.description);
        let* _ = putString!(3,  x.parent);
        return()

    // EquiNodes
    def exportEquiNodes(xs: List[IH06Tree]): SQLiteExport[Int32] =
        use FactIO/SQLiteExport.{flatMap, return, execute, foldM, prepareStatement, commit};
        let* _          = execute("DROP TABLE IF EXISTS equi_node");
        let* _          = execute(sqlCreateEquiNode());
        let* stmt       = prepareStatement("INSERT INTO equi_node(equi_id, level, description, floc, superordinate) VALUES(?,?,?,?,?)");
        let* nrows      = foldM((ac, x) -> { let* n = emitIH06Equis(stmt, x); return(ac+n)}, 0, xs);
        let* _          = commit();
        return(nrows)


    def emitIH06Equis(stmt: PreparedStatement, src: IH06Tree): SQLiteExport[Int32] = 
        use FactIO/SQLiteExport.{flatMap, return, mapAccumX};
        let RoseTree(label, kids) = src;
        let* n = emitEquiNode(stmt, label);
        mapAccumX((ac,x) -> {let* i = emitIH06Equis(stmt, x); return(ac+i)}, n, kids)

    def emitEquiNode(stmt: PreparedStatement,src: IH06Node): SQLiteExport[Int32] = 
        use FactIO/SQLiteExport.{return, writeRow};
        match src { 
            case EquiNode(r) => writeRow(stmt, equiNodeRowWriter(r))
            case _           => return(0)
        }

    /// A RowWriter for EquiNode
    def equiNodeRowWriter(x: EquiNode): SQLiteRowWriter[Unit] = 
        use FactIO/SQLiteRowWriter.{flatMap, return, putString!, putInt32!};
        let* _ = putString!(0,  x.equiId);
        let* _ = putInt32!(1,   x.level);
        let* _ = putString!(2,  x.description);
        let* _ = putString!(3,  x.floc);
        let* _ = putString!(4,  x.superordinate);
        return()



    // SQL DDL


    def sqlCreateFlocNode(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS floc_node ("
                :: "floc            TEXT    NOT NULL PRIMARY KEY,"
                :: "level           INTEGER NOT NULL,"
                :: "description     TEXT    NOT NULL,"
                :: "parent          TEXT"
                :: ")"
                :: Nil
        )

    def sqlCreateEquiNode(): String =
        String.unwords(
            "CREATE TABLE equi_node ("
                :: "equi_id         TEXT    NOT NULL PRIMARY KEY,"
                :: "level           INTEGER NOT NULL,"
                :: "description     TEXT    NOT NULL,"
                :: "floc            TEXT    NOT NULL,"
                :: "superordinate   TEXT"
                :: ")"
                :: Nil
        )
} 