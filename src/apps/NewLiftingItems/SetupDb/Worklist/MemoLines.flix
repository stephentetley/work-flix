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

namespace NewLiftingItems/SetupDb/Worklist/MemoLines {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;

    use SheetIO.SheetReader;
    use SheetIO.NamedRowEvaluator;


    type alias MemoLineRow = 
        { reference: String
        , longText: Option[String]
        }



    pub def storeMemoLines(tableName: String, src: System.FilePath) : DbMonad[Unit] = 
        use BasicDb/DbMonad.{return, flatMap, liftActionResult, map};
        let* xs     = liftActionResult(_ -> SheetIO/SheetReader.runXlsx(readMemoLinesTable(), src));
        let* _      = exportMemoLineRows(tableName, xs);
        return()


    def readMemoLinesTable() : SheetReader[List[MemoLineRow]] =
        use SheetIO/SheetReader.{flatMap, return, getSheetAt, namedRowsFrom}; 
        let* s1     = getSheetAt(0); 
        let* xs     = namedRowsFrom(s1, 0, 1, evalMemoLineRow());
        return(xs)



    def evalMemoLineRow(): NamedRowEvaluator[MemoLineRow] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, getContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6) -> 
                { reference = String.trim(x1)
                , longText  = makeLongText(List.map(String.trim, x2 :: x3 :: x4 :: x5 :: x6 :: Nil))
                })
            <&> getContentNamed("Reference")
            <*> getContentNamed("Memo Line 1")
            <*> getContentNamed("Memo Line 2")
            <*> getContentNamed("Memo Line 3")
            <*> getContentNamed("Memo Line 4")
            <*> getContentNamed("Memo Line 5")


    def makeLongText(xs: List[String]): Option[String] = 
        let text = List.filter(s -> not String.isEmpty(s), xs) |> String.intercalate(String.lineSeparator());
        if (String.isEmpty(text)) None else Some(String.trim(text))


    def exportMemoLineRows(tableName: String, rows: List[MemoLineRow]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldLeftM, prepareStatement, psExecuteUpdate, setAutoCommit, commit};
        let* _          = setAutoCommit(false);
        let* _          = execute("DROP TABLE IF EXISTS ${tableName};");
        let* _          = execute(createTableSql(tableName));
        let* stmt       = prepareStatement("INSERT INTO ${tableName} (reference, long_text) VALUES(?,?);");
        let* nrows      = foldLeftM((ac, x) -> { let* n = psExecuteUpdate(stmt, memoLineRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)

    /// A setter for MemoLineRow
    def memoLineRowSetter(x: MemoLineRow): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!, putOptionStringAt!};
        let* _ = putStringAt!(0, x.reference);
        let* _ = putOptionStringAt!(1, x.longText);
        return()


    def createTableSql(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "reference       TEXT NOT NULL,"
                :: "long_text       TEXT"
                :: ")"
                :: Nil
        )

}