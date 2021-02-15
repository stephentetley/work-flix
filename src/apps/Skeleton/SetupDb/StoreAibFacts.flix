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


namespace Skeleton/SetupDb/StoreAibFacts {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;

    use Skeleton/Datatypes.{AibInputRow};

    pub def storeAibInputRows(src: System.FilePath) : DbMonad[Unit] = 
        use BasicDb/DbMonad.{return, flatMap, liftActionResult, map};
        let* xs     = liftActionResult(_ -> Skeleton/XlsxReader.readAnnotatedAibExport(src));
        let* _      = exportAibInputRows(xs);
        return()

    /// Always drop table (fresh new data)
    def exportAibInputRows(rows: List[AibInputRow]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldLeftM, prepareStatement, psExecuteUpdate, setAutoCommit, commit};
        let* _          = setAutoCommit(false);
        let* _          = execute("DROP TABLE IF EXISTS aib_facts;");
        let* _          = execute(createTableSql());
        let* stmt       = prepareStatement(insertSql());
        let* nrows      = foldLeftM((ac, x) -> { let* n = psExecuteUpdate(stmt, setAibInputRow!(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)

    /// A setter for MappingTableRow
    def setAibInputRow!(x: AibInputRow): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!};
        let* _ = putStringAt!(0, x.reference);
        let* _ = putStringAt!(1, x.commonName);
        let* _ = putStringAt!(2, ToString.toString(x.installedFrom));
        let* _ = putStringAt!(3, x.manufacturer);
        let* _ = putStringAt!(4, x.model);        
        let* _ = putStringAt!(5, x.assetStatus);
        let* _ = putStringAt!(6, x.locRef);
        let* _ = putStringAt!(7, x.specificModelFrame);
        let* _ = putStringAt!(8, x.serialNumber);
        return()

    def insertSql(): String = 
        String.unwords(
            "INSERT INTO aib_facts ("
                :: "reference,"
                :: "common_name,"
                :: "installed_from,"     /// ISO8601
                :: "manufacturer,"
                :: "model,"
                :: "asset_status,"
                :: "loc_ref,"
                :: "specific_model_frame,"
                :: "serial_number"
                :: ") VALUES(?,?,?, ?,?,?, ?,?,?);"
                :: Nil
        )

    def createTableSql(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS aib_facts ("
                :: "reference                   TEXT NOT NULL PRIMARY KEY,"
                :: "common_name                 TEXT NOT NULL,"
                :: "installed_from              TEXT NOT NULL,"     /// ISO8601
                :: "manufacturer                TEXT NOT NULL,"
                :: "model                       TEXT NOT NULL,"
                :: "asset_status                TEXT NOT NULL,"
                :: "loc_ref                     TEXT NOT NULL,"
                :: "specific_model_frame        TEXT NOT NULL,"
                :: "serial_number               TEXT NOT NULL"
                :: ")"
                :: Nil
        )
}
