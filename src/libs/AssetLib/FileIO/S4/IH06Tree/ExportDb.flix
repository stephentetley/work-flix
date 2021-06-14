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


namespace AssetLib/FileIO/S4/IH06Tree/ExportDb { 

    use Data.RoseTree.{RoseTree};
    
    use BasicDb.DbMonad;
    use BasicDb.PreparedStatement;
    use BasicDb.PreparedStatementSetter;

    use AssetLib/FileIO/S4/IH06Tree/Datatypes.{IH06Tree, IH06Node, FlocNode, EquiNode};
    use AssetLib/FileIO/S4/IH06Tree/Datatypes.IH06Node.{FlocNode, EquiNode};
    use AssetLib/FileIO/S4/IH06Tree/Builder.{buildIH06Tree};
    use AssetLib/FileIO/S4/IH06Tree/Parser.{parseFile, parseFileWithBOM};


    type alias IH06TreeTableNames = 
        { flocNodes: String
        , equiNodes: String
        }

    pub def defaultTableNames(): IH06TreeTableNames = 
        { flocNodes     = "iht_floc_nodes"
        , equiNodes     = "iht_equi_nodes"
        }

    pub def storeIH06Trees( tableNames: IH06TreeTableNames
                          , sourceFile: System.FilePath
                          , cs: Text.Charset
                          , hasBOM: Bool): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, return, setAutoCommit, liftActionResult, liftResult};
        let* ast    = liftActionResult(_ -> if (hasBOM) parseFileWithBOM(sourceFile) else parseFile(sourceFile, cs));
        let* tree   = liftResult(buildIH06Tree(ast), msg -> "storeIH06Trees: ${msg}");
        let* _      = setAutoCommit(false);
        let* _      = exportFlocNodes(tableNames.flocNodes, tree);
        let* _      = exportEquiNodes(tableNames.equiNodes, tree);
        return()


    // FlocNodes
    def exportFlocNodes(tableName: String, x: IH06Tree): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldLeftM, prepareStatement, commit};
        let* _          = execute("DROP TABLE IF EXISTS ${tableName}");
        let* _          = execute(sqlCreateFlocNode(tableName));
        let* stmt       = prepareStatement("INSERT INTO ${tableName}(floc, level, description, parent) VALUES(?,?,?,?)");
        let* nrows      = emitIH06Flocs(stmt, x);
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
    def exportEquiNodes(tableName: String, x: IH06Tree): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldLeftM, prepareStatement, commit};
        let* _          = execute("DROP TABLE IF EXISTS ${tableName}");
        let* _          = execute(sqlCreateEquiNode(tableName));
        let* stmt       = prepareStatement("INSERT INTO ${tableName}(equi_id, level, description, floc, superordinate) VALUES(?,?,?,?,?)");
        let* nrows      = emitIH06Equis(stmt, x);
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


    def sqlCreateFlocNode(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "floc            TEXT    NOT NULL PRIMARY KEY,"
                :: "level           INTEGER NOT NULL,"
                :: "description     TEXT    NOT NULL,"
                :: "parent          TEXT"
                :: ")"
                :: Nil
        )

    def sqlCreateEquiNode(tableName: String): String =
        String.unwords(
            "CREATE TABLE ${tableName} ("
                :: "equi_id         TEXT    NOT NULL PRIMARY KEY,"
                :: "level           INTEGER NOT NULL,"
                :: "description     TEXT    NOT NULL,"
                :: "floc            TEXT    NOT NULL,"
                :: "superordinate   TEXT"
                :: ")"
                :: Nil
        )
} 