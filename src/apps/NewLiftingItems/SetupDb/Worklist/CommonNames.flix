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

/// Note we have to get common names from a query on AIB and not the worklist
/// The worklist might be wrong.

namespace NewLiftingItems/SetupDb/Worklist/CommonNames {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;

    use SheetIO.SheetReader;
    use SheetIO.DataFormatter;
    use SheetIO.NamedRowEvaluator;

    /// Read fropm the Attributes file...
    type alias AibCommonNameRow = 
        { reference: String
        , commonName: String
        }



    pub def storeCommonNames(tableName: String, src: System.FilePath) : DbMonad[Unit] = 
        use BasicDb/DbMonad.{return, flatMap, liftActionResult, map};
        let* xs     = liftActionResult(_ -> SheetIO/SheetReader.runXlsx(readAibCommonNameTable(), src));
        let* _      = exportAibCommonNameRows(tableName, xs);
        return()

   def readAibCommonNameTable() : SheetReader[List[AibCommonNameRow]] =
        use SheetIO/SheetReader.{flatMap, return, getSheetAt, liftAction, namedRowsFrom}; 
        let* s1 = getSheetAt(0); 
        namedRowsFrom(s1, 0, 1, evalAibCommonNameRow())

    def evalAibCommonNameRow(): NamedRowEvaluator[AibCommonNameRow] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, map, getStringNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        use String.{trim};
        ((x1, x2) ->
                { reference         = x1
                , commonName        = x2.trim()
                })
            <&> getStringNamed("Reference")
            <*> getStringNamed("Common Name")

    def exportAibCommonNameRows(tableName: String, rows: List[AibCommonNameRow]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldM, prepareStatement, psExecuteUpdate, setAutoCommit, commit};
        let* _          = setAutoCommit(false);
        let* _          = execute("DROP TABLE IF EXISTS ${tableName};");
        let* _          = execute(createTableSql(tableName));
        let* stmt       = prepareStatement(insertRowSql(tableName));
        let* nrows      = foldM((ac, x) -> { let* n = psExecuteUpdate(stmt, aibCommonNameRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)

    /// A setter for AibCommonNameRow
    def aibCommonNameRowSetter(x: AibCommonNameRow): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!};
        let* _  = putStringAt!(0, x.reference);
        let* _  = putStringAt!(1, x.commonName);
        return()
    
    def insertRowSql(tableName: String): String =
        String.unwords(
            "INSERT INTO ${tableName} "
                :: "(reference, common_name)"
                :: "VALUES(?,?);"
                :: Nil
        )

    def createTableSql(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "reference           TEXT NOT NULL,"
                :: "common_name         TEXT"
                :: ")"
                :: Nil
        )



}