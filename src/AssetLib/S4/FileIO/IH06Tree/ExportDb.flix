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


namespace AssetLib/S4/FileIO/IH06Tree/Raw/ExportDb { 

    use Data.RoseTree.{RoseTree};
    
    use BasicDb.DbMonad;
    use BasicDb.PreparedStatement;
    use BasicDb.PreparedStatementSetter;

    use AssetLib/S4/FileIO/IH06Tree/Datatypes.{IH06Tree, IH06Node, FlocNode, EquiNode};
    use AssetLib/S4/FileIO/IH06Tree/Datatypes.IH06Node.{FlocNode, EquiNode};
    use AssetLib/S4/FileIO/IH06Tree/Builder.{buildIH06Trees};
    use AssetLib/S4/FileIO/IH06Tree/Parser.{parseFile};

    pub def exportDb(sourceFile: System.FilePath, cs: Text.Charset, outputUrl: String): Result[Unit, System.Error] & Impure = 
        use Result.flatMap;
        let* ast    = parseFile(sourceFile, cs);
        let ans     = buildIH06Trees(ast);
        let* _      = outputDb(ans, outputUrl);
        Ok()


    pub def outputDb(xs: List[IH06Tree], url: String): Result[Unit, System.Error] & Impure =         
        BasicDb/DbMonad.runDbMonad(storeIH06Trees(xs), url)
        
    pub def storeIH06Trees(xs: List[IH06Tree]): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, return, setAutoCommit, liftAction};
        let* _      = setAutoCommit(false);
        let* _      = liftAction(_ -> Console.printLine("Flocs..."));
        let* n1     = addFlocNodes(xs);
        let* _      = liftAction(_ -> Console.printLine(Int32.toString(n1)));
        let* _      = liftAction(_ -> Console.printLine("Equi..."));
        let* n2     = addEquiNodes(xs);
        let* _      = liftAction(_ -> Console.printLine(Int32.toString(n2)));
        return()


    // FlocNodes
    pub def addFlocNodes(xs: List[IH06Tree]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldM, prepareStatement, commit};
        let* _          = execute("DROP TABLE IF EXISTS floc_node");
        let* _          = execute(sqlCreateFlocNode());
        let* stmt       = prepareStatement("INSERT INTO floc_node(floc, level, description, parent) VALUES(?,?,?,?)");
        let* nrows      = foldM((ac, x) -> { let* n = emitIH06Flocs(stmt, x); return(ac+n)}, 0, xs);
        let* _          = commit();
        return(nrows)

    def emitIH06Flocs(stmt: PreparedStatement, src: IH06Tree): DbMonad[Int32] = 
        use BasicDb/DbMonad.{flatMap, return, mapAccumX};
        let RoseTree(label, kids) = src;
        let* n = emitFlocNode(stmt, label);
        mapAccumX((ac,x) -> {let* i = emitIH06Flocs(stmt, x); return(ac+i)}, n, kids)

    def emitFlocNode(stmt: PreparedStatement, src: IH06Node): DbMonad[Int32] = 
        use BasicDb/DbMonad.{return, psExecuteUpdate};
        match src { 
            case FlocNode(r) => psExecuteUpdate(stmt, flocNodeRowWriter(r))
            case _           => return(0)
        }

     /// A RowWriter for FlocNode
    def flocNodeRowWriter(x: FlocNode): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!, putInt32At!};
        let* _ = putStringAt!(0,  x.floc);
        let* _ = putInt32At!(1,   x.level);
        let* _ = putStringAt!(2,  x.description);
        let* _ = putStringAt!(3,  x.parent);
        return()

    // EquiNodes
    pub def addEquiNodes(xs: List[IH06Tree]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldM, prepareStatement, commit};
        let* _          = execute("DROP TABLE IF EXISTS equi_node");
        let* _          = execute(sqlCreateEquiNode());
        let* stmt       = prepareStatement("INSERT INTO equi_node(equi_id, level, description, floc, superordinate) VALUES(?,?,?,?,?)");
        let* nrows      = foldM((ac, x) -> { let* n = emitIH06Equis(stmt, x); return(ac+n)}, 0, xs);
        let* _          = commit();
        return(nrows)


    def emitIH06Equis(stmt: PreparedStatement, src: IH06Tree): DbMonad[Int32] = 
        use BasicDb/DbMonad.{flatMap, return, mapAccumX};
        let RoseTree(label, kids) = src;
        let* n = emitEquiNode(stmt, label);
        mapAccumX((ac,x) -> {let* i = emitIH06Equis(stmt, x); return(ac+i)}, n, kids)

    def emitEquiNode(stmt: PreparedStatement,src: IH06Node): DbMonad[Int32] = 
        use BasicDb/DbMonad.{return, psExecuteUpdate};
        match src { 
            case EquiNode(r) => psExecuteUpdate(stmt, equiNodeRowWriter(r))
            case _           => return(0)
        }

    /// A RowWriter for EquiNode
    def equiNodeRowWriter(x: EquiNode): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!, putInt32At!};
        let* _ = putStringAt!(0,  x.equiId);
        let* _ = putInt32At!(1,   x.level);
        let* _ = putStringAt!(2,  x.description);
        let* _ = putStringAt!(3,  x.floc);
        let* _ = putStringAt!(4,  x.superordinate);
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