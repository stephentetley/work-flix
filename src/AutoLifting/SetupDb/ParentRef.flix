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

namespace AutoLifting/SetupDb/ParentRef {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;

    use AssetLib/Aib/FileIO/AideChangeSummary/Datatypes.AibExportRow;

    type alias ParentRefRow = 
        { assetName: String
        , reference: String
        }


    pub def storeParentRefs(tableName: String, path: System.FilePath): DbMonad[Unit] =
        use BasicDb/DbMonad.{return, flatMap, liftActionResult}; 
        let* xs         = liftActionResult(_ -> AssetLib/Aib/FileIO/AideChangeSummary/XlsxReader.readFile(path));
        let  parents    = List.filter(x -> !(String.startsWith(x.reference, "PLI")), xs);
        let* _          = exportParentRefRows(tableName, parents);
        return()



    /// Always drop table (fresh new data)
    def exportParentRefRows(tableName: String, rows: List[AibExportRow]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldM, prepareStatement, psExecuteUpdate, commit};
        let* _          = execute("DROP TABLE IF EXISTS ${tableName};");
        let* _          = execute(createTableSql(tableName));
        let* stmt       = prepareStatement("INSERT INTO ${tableName} (asset_name, reference) VALUES(?,?);");
        let* nrows      = foldM((ac, x) -> { let* n = psExecuteUpdate(stmt, parentRefRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)

    /// A setter for AibExportRow - just two fields
    def parentRefRowSetter(x: AibExportRow): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!};
        let* _ = putStringAt!(0, x.assetName);
        let* _ = putStringAt!(1, x.reference);
        return()


    def createTableSql(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "asset_name          TEXT NOT NULL,"
                :: "reference           TEXT"
                :: ")"
                :: Nil
        )

}
