/*
 * Copyright 2021 Stephen Tetley
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

namespace NewLiftingItems/SetupDb/Worklist/Worklist {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;

    use AssetLib/FileIO/Aib/AideChangeSummary/Datatypes.AibExportRow;

    type alias WorklistRow = 
        { reference: String
        , change: String
        }


    pub def storeWorklist(tableName: String, path: System.FilePath): DbMonad[Unit] =
        use BasicDb/DbMonad.{return, flatMap, liftActionResult}; 
        let* xs         = liftActionResult(_ -> AssetLib/FileIO/Aib/AideChangeSummary/XlsxReader.readFile(path));
        let  equis      = List.filter(x -> (String.startsWith(x.reference, "PLI") and x.change != "Child Equal"), xs);
        let* _          = exportWorklistRows(tableName, equis);
        return()



    /// Always drop table (fresh new data)
    def exportWorklistRows(tableName: String, rows: List[AibExportRow]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldLeftM, setAutoCommit, prepareStatement, psExecuteUpdate, commit};
        let* _          = setAutoCommit(false);
        let* _          = execute("DROP TABLE IF EXISTS ${tableName};");
        let* _          = execute(createTableSql(tableName));
        let* stmt       = prepareStatement("INSERT INTO ${tableName} (orderkey, reference, change) VALUES(?,?,?);");
        let* nrows      = foldLeftM((ac, x) -> { let* n = psExecuteUpdate(stmt, worklistRowSetter(ac, x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)

    /// A setter for AibExportRow - just two fields
    def worklistRowSetter(ix: Int32, x: AibExportRow): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putInt32At!, putStringAt!};        
        let* _ = putInt32At!(0, ix);
        let* _ = putStringAt!(1, x.reference);
        let* _ = putStringAt!(2, x.change);
        return()


    def createTableSql(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "orderkey        INTEGER NOT NULL PRIMARY KEY,"
                :: "reference       TEXT NOT NULL,"
                :: "change          TEXT NOT NULL"
                :: ")"
                :: Nil
        )

}
