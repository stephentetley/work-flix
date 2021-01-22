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

namespace NewLiftingItems/SetupDb/Facts/WorkingLoadMapping {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;

    use SheetIO.SheetReader;
    use SheetIO.NamedRowEvaluator;


    type alias WorkingLoadMappingRow = 
        { objectClass: String
        , workingLoadField: String
        , workingLoadUnitField: String
        }



    pub def storeWorkingLoadMapping(tableName: String, src: System.FilePath) : DbMonad[Unit] = 
        use BasicDb/DbMonad.{return, flatMap, liftActionResult, map};
        let* xs     = liftActionResult(_ -> SheetIO/SheetReader.runXlsx(readWorkingLoadMappingTable(), src));
        let* _      = exportWorkingLoadMappingRows(tableName, xs);
        return()


    def readWorkingLoadMappingTable() : SheetReader[List[WorkingLoadMappingRow]] =
        use SheetIO/SheetReader.{flatMap, return, getSheetAt, namedRowsFrom}; 
        let* s1     = getSheetAt(0); 
        let* xs     = namedRowsFrom(s1, 0, 1, evalWorkingLoadMappingRow());
        return(xs)



    def evalWorkingLoadMappingRow(): NamedRowEvaluator[WorkingLoadMappingRow] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, getStringNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        use String.{trim};
        ((x1, x2, x3) ->
                { objectClass           = x1
                , workingLoadField      = x2
                , workingLoadUnitField  = x3
                })
            <&> getStringNamed("Object Classification")
            <*> getStringNamed("Working Load")
            <*> getStringNamed("Working Load Units")


    /// Always drop table (fresh new data)
    def exportWorkingLoadMappingRows(tableName: String, rows: List[WorkingLoadMappingRow]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldM, prepareStatement, psExecuteUpdate, commit};
        let* _          = execute("DROP TABLE IF EXISTS ${tableName};");
        let* _          = execute(createTableSql(tableName));
        let* stmt       = prepareStatement("INSERT INTO ${tableName} (classification, working_load_field, working_load_unit_field) VALUES(?,?,?);");
        let* nrows      = foldM((ac, x) -> { let* n = psExecuteUpdate(stmt, workingLoadMappingRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)

    /// A setter for MappingTableRow
    def workingLoadMappingRowSetter(x: WorkingLoadMappingRow): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!};
        let* _ = putStringAt!(0, x.objectClass);
        let* _ = putStringAt!(1, x.workingLoadField);
        let* _ = putStringAt!(2, x.workingLoadUnitField);
        return()


    def createTableSql(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "classification              TEXT NOT NULL,"
                :: "working_load_field          TEXT NOT NULL,"
                :: "working_load_unit_field     TEXT NOT NULL"
                :: ")"
                :: Nil
        )

}