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


namespace AssetLib/FileIO/Aib/TreeExport/ExportDb {


    use Data.RoseTree.{RoseTree};

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatement;
    use BasicDb.PreparedStatementSetter;

    use AssetLib/FileIO/Aib/TreeExport/Raw/Datatypes.{AibTree, AibNode};
    use AssetLib/FileIO/Aib/TreeExport/Raw/XlsxReader.{readAibTreeFile};
    use AssetLib/FileIO/Aib/TreeExport/Raw/Builder.{buildAibTrees};

    pub def storeTreeExport( tableName: String, sourceFile: System.FilePath): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit, liftActionResult};
        let* rows   = liftActionResult(_ -> readAibTreeFile(sourceFile));
        let xs      = buildAibTrees(rows, 1);
        let* _      = exportAibTrees(tableName, xs);
        point()



    // AibTrees
    def exportAibTrees(tableName: String, xs: List[AibTree]): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, point, execute, traverseX, prepareStatement, setAutoCommit, commit};
        let* _          = setAutoCommit(false);
        let* _          = execute("DROP TABLE IF EXISTS ${tableName}");
        let* _          = execute(sqlCreateEquiNode(tableName));
        let* stmt       = prepareStatement("INSERT INTO ${tableName}(reference, level, short_name, common_name, parent_ref, status) VALUES(?,?,?, ?,?,?)");
        let* _          = traverseX(emitAibTree(stmt), xs);
        let* _          = commit();
        point()


    def emitAibTree(stmt: PreparedStatement, src: AibTree): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, psExecuteUpdate, traverseX};
        let RoseTree(node, kids) = src;
        let* _ = psExecuteUpdate(stmt, aibNodeWriter(node));
        traverseX(emitAibTree(stmt), kids)


    /// A RowWriter for EquiNode
    def aibNodeWriter(x: AibNode): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, point, putStringAt!, putInt32At!};
        let* _ = putStringAt!(0,  x.reference);
        let* _ = putInt32At!(1,   x.level);
        let* _ = putStringAt!(2,  x.shortName);
        let* _ = putStringAt!(3,  x.commonName);
        let* _ = putStringAt!(4,  x.parent);
        let* _ = putStringAt!(5,  x.status);
        point()


    def sqlCreateEquiNode(tableName: String): String =
        String.unwords(
            "CREATE TABLE ${tableName} ("
                :: "reference       TEXT    NOT NULL PRIMARY KEY,"
                :: "level           INTEGER NOT NULL,"
                :: "short_name      TEXT    NOT NULL,"
                :: "common_name     TEXT    NOT NULL,"
                :: "parent_ref      TEXT,"
                :: "status          TEXT"
                :: ")"
                :: Nil
        )

}