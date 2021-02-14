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

namespace Ultrasonics/SetupDb/IH08List {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;

    use SheetIO.SheetReader;
    use SheetIO.DataFormatter;
    use SheetIO.NamedRowEvaluator;


    type alias IH08Row = 
        { equipment: String
        , description: String
        , funcloc: String
        , site: String
        , piTag: String
        , manufacturer: String
        , model: String
        , partNumber: String
        , serialNumber: String
        , userStatus: String
        }


    pub def storeIH08List(tableName: String, src: System.FilePath): DbMonad[Unit] =
        use BasicDb/DbMonad.{return, flatMap, liftActionResult, map};
        let* xs     = liftActionResult(_ -> SheetIO/SheetReader.runXlsx(readIH08Table(), src));
        let* _      = exportIH08RowRows(tableName, xs);
        return()





    def readIH08Table() : SheetReader[List[IH08Row]] =
        use SheetIO/SheetReader.{flatMap, return, getSheetAt, namedRowsFrom}; 
        let* s1     = getSheetAt(0); 
        let* xs     = namedRowsFrom(s1, 0, 1, evalIH08Row());
        return(xs)



    def evalIH08Row(): NamedRowEvaluator[IH08Row] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, getContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9) -> 
                { equipment = String.trim(x1)
                , description  = String.trim(x2)
                , funcloc = String.trim(x3)
                , site = getSite(x3)
                , piTag = String.trim(x4)
                , manufacturer = String.trim(x5)
                , model = String.trim(x6)
                , partNumber = String.trim(x7)
                , serialNumber = String.trim(x8)
                , userStatus = String.trim(x9)
                })
            <&> getContentNamed("Equipment")
            <*> getContentNamed("Description")
            <*> getContentNamed("Functional Loc.")
            <*> getContentNamed("TechIdentNo.")
            <*> getContentNamed("Manufacturer")
            <*> getContentNamed("Model number")
            <*> getContentNamed("ManufPartNo.")
            <*> getContentNamed("ManufSerialNo.")
            <*> getContentNamed("User status")


    def getSite(s: String): String = match String.splitOn(s, "-") { 
        case s1 :: _ => s1
        case Nil => ""
    }


    /// Always drop table (fresh new data)
    def exportIH08RowRows(tableName: String, rows: List[IH08Row]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldLeftM, setAutoCommit, prepareStatement, psExecuteUpdate, commit};
        let* _          = setAutoCommit(false);
        let* _          = execute("DROP TABLE IF EXISTS ${tableName};");
        let* _          = execute(createTableSql(tableName));
        let* stmt       = prepareStatement(insertRowSql(tableName));
        let* nrows      = foldLeftM((ac, x) -> { let* n = psExecuteUpdate(stmt, ih08RowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)


    def ih08RowSetter(x: IH08Row): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putInt32At!, putStringAt!};        
        let* _ = putStringAt!(0, x.equipment);
        let* _ = putStringAt!(1, x.description);
        let* _ = putStringAt!(2, x.funcloc);
        let* _ = putStringAt!(3, x.site);
        let* _ = putStringAt!(4, x.piTag);
        let* _ = putStringAt!(5, x.manufacturer);
        let* _ = putStringAt!(6, x.model);
        let* _ = putStringAt!(7, x.partNumber);
        let* _ = putStringAt!(8, x.serialNumber);
        let* _ = putStringAt!(9, x.userStatus);
        return()


    def insertRowSql(tableName: String): String =
        String.unwords(
            "INSERT INTO ${tableName} "
                :: "(equipment,"
                :: "description," 
                :: "funcloc,"
                :: "site,"
                :: "pi_tag,"
                :: "manufacturer," 
                :: "model,"
                :: "part_number,"
                :: "serial_number,"
                :: "user_status)"
                :: "VALUES(?,?,?, ?,?,?, ?,?,?, ?);"
                :: Nil
        )

    def createTableSql(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "equipment       TEXT NOT NULL PRIMARY KEY,"
                :: "description     TEXT NOT NULL,"
                :: "funcloc         TEXT NOT NULL,"
                :: "site            TEXT,"
                :: "pi_tag          TEXT,"
                :: "manufacturer    TEXT,"
                :: "model           TEXT,"
                :: "part_number     TEXT,"
                :: "serial_number   TEXT,"                
                :: "user_status   TEXT"
                :: ")"
                :: Nil
        )

}
