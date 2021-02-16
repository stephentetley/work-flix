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

    /// Stores what is extracted from Aib without annotations

    pub def storeAibInputRows(src: System.FilePath) : DbMonad[Unit] = 
        use BasicDb/DbMonad.{return, flatMap, liftActionResult, map};
        let* xs     = liftActionResult(_ -> Skeleton/XlsxReader.readAnnotatedAibExport(src));
        let* _      = exportAibInputRows(xs);
        return()

    /// Always drop table (fresh new data)
    def exportAibInputRows(rows: List[AibInputRow]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldLeftM, prepareStatement, psExecuteUpdate, setAutoCommit, commit};
        let rows1       = List.sortWith((x,y) -> Order.compare(x.commonName, y.commonName) |> Order.toInt, rows);
        let* _          = setAutoCommit(false);
        let* _          = execute("DROP TABLE IF EXISTS aib_facts;");
        let* _          = execute(createAibFactsTableSql());
        let* stmt       = prepareStatement(insertAibFactSql());
        let* nrows      = foldLeftM((ac, x) -> { let* _ = psExecuteUpdate(stmt, setAibInputRow!(ac + 1, x)); return(ac + 1)}, 0, rows1);
        let* _          = commit();
        return(nrows)

    /// A setter for AibInputRow
    def setAibInputRow!(counter: Int32, x: AibInputRow): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!, putInt32At!};
        let* _ = putStringAt!(0, x.reference);
        let* _ = putInt32At!(1, counter);
        let* _ = putStringAt!(2, x.commonName);
        let* _ = putStringAt!(3, ToString.toString(x.installedFrom));
        let* _ = putStringAt!(4, x.manufacturer);
        let* _ = putStringAt!(5, x.model);        
        let* _ = putStringAt!(6, x.assetStatus);
        let* _ = putStringAt!(7, x.locRef);
        let* _ = putStringAt!(8, x.specificModelFrame);
        let* _ = putStringAt!(9, x.serialNumber);
        return()

    def insertAibFactSql(): String = 
        String.unwords(
            "INSERT INTO aib_facts ("
                :: "reference,"
                :: "counter,"
                :: "common_name,"
                :: "installed_from,"     /// ISO8601
                :: "manufacturer,"
                :: "model,"
                :: "asset_status,"
                :: "loc_ref,"
                :: "specific_model_frame,"
                :: "serial_number"
                :: ") VALUES(?,?,?, ?,?,?, ?,?,?, ?);"
                :: Nil
        )

    def createAibFactsTableSql(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS aib_facts ("
                :: "reference                   TEXT NOT NULL PRIMARY KEY,"
                :: "counter                     INTEGER NOT NULL,"
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

    /// 

    pub def storeFlocMappingRows(src: System.FilePath) : DbMonad[Unit] = 
        use BasicDb/DbMonad.{return, flatMap, liftActionResult, map};
        let* xs     = liftActionResult(_ -> Skeleton/XlsxReader.readAnnotatedAibExport(src));
        let* _      = exportFlocMappingRows(xs);
        return()

    /// Always drop table (fresh new data)
    def exportFlocMappingRows(rows: List[AibInputRow]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldLeftM, prepareStatement, psExecuteUpdate, setAutoCommit, commit};
        let rows1       = filterFlocMappingRows(rows);
        let* _          = setAutoCommit(false);
        let* _          = execute("DROP TABLE IF EXISTS floc_mapping;");
        let* _          = execute(createFlocMappingTableSql());
        let* stmt       = prepareStatement(insertFlocMappingSql());
        let* nrows      = foldLeftM((ac, x) -> { let* _ = psExecuteUpdate(stmt, setFlocMappingRow!(x)); return(ac + 1)}, 0, rows1);
        let* _          = commit();
        return(nrows)

    def filterFlocMappingRows(rows: List[AibInputRow]): List[AibInputRow] =
        List.sortWith((x,y) -> Order.compare(x.commonName, y.commonName) |> Order.toInt, rows)
            |> List.distinctWith((x, y) -> x.s4Floc == y.s4Floc)


    /// A setter for AibInputRow
    def setFlocMappingRow!(x: AibInputRow): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!};
        let* _ = putStringAt!(0, x.reference);
        let* _ = putStringAt!(1, ToString.toString(x.s4Floc));
        let* _ = putStringAt!(2, x.commonName);
        return()

    def insertFlocMappingSql(): String = 
        String.unwords(
            "INSERT INTO floc_mapping ("
                :: "reference,"
                :: "s4_floc,"
                :: "common_name"
                :: ") VALUES(?,?,?);"
                :: Nil
        )


    def createFlocMappingTableSql(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS floc_mapping ("
                :: "reference                   TEXT NOT NULL PRIMARY KEY,"
                :: "s4_floc                     TEXT NOT NULL,"
                :: "common_name                 TEXT NOT NULL"
                :: ")"
                :: Nil
        )


}
