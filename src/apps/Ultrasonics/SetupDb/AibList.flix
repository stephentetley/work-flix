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

namespace Ultrasonics/SetupDb/AibList {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;

    use SheetIO.SheetReader;
    use SheetIO.DataFormatter;
    use SheetIO.NamedRowEvaluator;

    type alias AibRow = 
        { reference: String
        , commonName: String
        , site: String
        , installedFrom: Time.LocalDate
        , piTag: String
        , manufacturer: String
        , model: String
        , specificModelFrame: String
        , serialNumber: String
        , assetStatus: String
        , memoLines: String
        }


    pub def storeAibList(tableName: String, src: System.FilePath): DbMonad[Unit] =
        use BasicDb/DbMonad.{return, flatMap, liftActionResult, map};
        let* xs     = liftActionResult(_ -> SheetIO/SheetReader.runXlsx(readAibTable(), src));
        let* _      = exportAibRowRows(tableName, xs);
        return()

    def readAibTable() : SheetReader[List[AibRow]] =
        use SheetIO/SheetReader.{flatMap, return, getSheetAt, namedRowsFrom}; 
        let* s1     = getSheetAt(0); 
        let* xs     = namedRowsFrom(s1, 0, 1, evalAibRow());
        return(xs)



    def evalAibRow(): NamedRowEvaluator[AibRow] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, getContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10) -> 
                { reference             = String.trim(x1)
                , commonName            = String.trim(x2)
                , site                  = getSite(x2)
                , installedFrom         = x3
                , piTag                 = String.trim(x4)
                , manufacturer          = String.trim(x5)
                , model                 = String.trim(x6)
                , specificModelFrame    = String.trim(x7)
                , serialNumber          = String.trim(x8)
                , assetStatus           = String.trim(x9)
                , memoLines             = x10
                })
            <&> getContentNamed("Reference")
            <*> getContentNamed("Common Name")
            <*> getLocalDateNamed("Installed From")
            <*> getContentNamed("P AND I Tag No")
            <*> getContentNamed("Manufacturer")
            <*> getContentNamed("Model")
            <*> getContentNamed("Specific Model/Frame")
            <*> getContentNamed("Serial No")
            <*> getContentNamed("AssetStatus")
            <*> getMemoLines("Memo Line 1" ::  "Memo Line 2":: "Memo Line 3" :: "Memo Line 4" :: Nil)
            

    def getMemoLines(labels: List[String]): NamedRowEvaluator[String] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, mapM, getContentNamed};
        let* xs = mapM(getContentNamed, labels);
        return(makeLongText(xs))


    def makeLongText(xs: List[String]): String = 
        List.map(String.trim, xs) 
            |> List.filter(s -> not String.isEmpty(s)) 
            |> String.intercalate(String.lineSeparator())
        
        
    def getLocalDateNamed(label: String): NamedRowEvaluator[Time.LocalDate] = 
        use SheetIO/NamedRowEvaluator.{map, getLocalDateTimeNamed};
        map(Time/LocalDateTime.toLocalDate,  getLocalDateTimeNamed(label))



    def getSite(s: String): String = match String.splitOn(s, "/") { 
        case s1 :: s2 :: _ => "${s1}/${s2}"
        case _ => ""
    }

    /// Always drop table (fresh new data)
    def exportAibRowRows(tableName: String, rows: List[AibRow]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldLeftM, setAutoCommit, prepareStatement, psExecuteUpdate, commit};
        let* _          = setAutoCommit(false);
        let* _          = execute("DROP TABLE IF EXISTS ${tableName};");
        let* _          = execute(createTableSql(tableName));
        let* stmt       = prepareStatement(insertRowSql(tableName));
        let* nrows      = foldLeftM((ac, x) -> { let* n = psExecuteUpdate(stmt, aibRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)


    def aibRowSetter(x: AibRow): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putInt32At!, putStringAt!};        
        let* _ = putStringAt!(0, x.reference);
        let* _ = putStringAt!(1, x.commonName);
        let* _ = putStringAt!(2, x.site);
        let* _ = putS4DateAt!(3, x.installedFrom);
        let* _ = putStringAt!(4, x.piTag);
        let* _ = putStringAt!(5, x.manufacturer);
        let* _ = putStringAt!(6, x.model);
        let* _ = putStringAt!(7, x.specificModelFrame);
        let* _ = putStringAt!(8, x.serialNumber);
        let* _ = putStringAt!(9, x.assetStatus);
        let* _ = putStringAt!(10, x.memoLines);
        return()

    def putS4DateAt!(ix: Int32, dt: Time.LocalDate): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, liftOption, putStringAt!};
        let* fmt    = liftOption(Time/Format/DateFormatter.fromPattern("dd.MM.yyyy"), "putS4DateAt!(${ix})");
        let ans     = Time/LocalDate.format(dt, fmt);
        let* _      = putStringAt!(ix, ans);
        return()


    def insertRowSql(tableName: String): String =
        String.unwords(
            "INSERT INTO ${tableName} "
                :: "(reference,"
                :: "common_name,"
                :: "site," 
                :: "installed_from,"
                :: "pi_tag,"
                :: "manufacturer,"
                :: "model,"
                :: "specific_model_frame,"
                :: "serial_number,"
                :: "asset_status,"
                :: "memo_lines)"
                :: "VALUES(?,?,?, ?,?,?, ?,?,?, ?,?);"
                :: Nil
        )

    def createTableSql(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "reference               TEXT NOT NULL PRIMARY KEY,"
                :: "common_name             TEXT NOT NULL,"
                :: "site                    TEXT,"
                :: "installed_from          TEXT NOT NULL,"
                :: "pi_tag                  TEXT,"
                :: "manufacturer            TEXT,"
                :: "model                   TEXT,"
                :: "specific_model_frame    TEXT,"
                :: "serial_number           TEXT,"
                :: "asset_status            TEXT,"
                :: "memo_lines              TEXT"
                :: ")"
                :: Nil
        )

}
