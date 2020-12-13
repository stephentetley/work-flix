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

namespace AutoLifting/SetupDb/AibAttributes {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;

    use SheetIO.SheetReader;
    use SheetIO.DataFormatter;
    use SheetIO.NamedRowEvaluator;


    type alias AibAttributeRow = 
        { reference: String
        , assetStatus: String
        , installedFrom: Time.LocalDate
        , manufacturer: String
        , model: String
        , partNumber: String
        , serialNumber: String
        , osgb36: String
        , locationOnSite: String
        , workLoad: Option[Float64]
        , workLoadUnits: String
        , statutoryRef: String
        , testCertNum: String
        }



    pub def storeAibAttributes(tableName: String, src: System.FilePath) : DbMonad[Unit] = 
        use BasicDb/DbMonad.{return, flatMap, liftActionResult, map};
        let* xs     = liftActionResult(_ -> SheetIO/SheetReader.runXlsx(readAibAttributeTable(), src));
        let* _      = exportAibAttributeRows(tableName, xs);
        return()

   def readAibAttributeTable() : SheetReader[List[AibAttributeRow]] =
        use SheetIO/SheetReader.{flatMap, return, getSheetAt, liftAction, namedRowsFrom}; 
        let* s1 = getSheetAt(0); 
        namedRowsFrom(s1, 0, 1, evalAibAttributeRow())

    /// TODO - this needs to handle "SAI" rows too, ideally by Option...
    def evalAibAttributeRow(): NamedRowEvaluator[AibAttributeRow] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, map, alt, getStringNamed, 
                getFloat64Named, getStringNamedWithDefault, optional, getStringNamedWithDataFormatter};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        use String.{trim};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13) ->
                { reference         = x1
                , assetStatus       = x2
                , installedFrom     = x3
                , manufacturer      = x4.trim()
                , model             = x5.trim()
                , partNumber        = x6.trim()
                , serialNumber      = x7.trim()
                , osgb36            = x8
                , locationOnSite    = x9.trim()
                , workLoad          = x10
                , workLoadUnits     = x11
                , statutoryRef      = x12.trim()
                , testCertNum       = x13.trim()
                })
            <&> getStringNamed("Reference")
            <*> getStringNamed("AssetStatus")
            <*> getLocalDateNamed("Installed From")
            <*> getStringNamedWithDefault("Manufacturer", "")
            <*> getCouldBeNumericalNamed("Model")
            <*> getCouldBeNumericalNamed("Specific Model/Frame")
            <*> getCouldBeNumericalNamed("Serial No")
            <*> getStringNamedWithDefault("Loc.Ref.", "")
            <*> getStringNamedWithDefault("Location On Site", "")
            <*> optional(getFloat64Named("Work Load"))
            <*> getStringNamedWithDefault("Work Load Units", "")
            <*> getCouldBeNumericalNamed("YWRef")
            <*> getCouldBeNumericalNamed("Test Cert No")

    def getLocalDateNamed(label: String): NamedRowEvaluator[Time.LocalDate] = 
        use SheetIO/NamedRowEvaluator.{map, getLocalDateTimeNamed};
        map(Time/LocalDateTime.toLocalDate,  getLocalDateTimeNamed(label))
        

    def getCouldBeNumericalNamed(label: String): NamedRowEvaluator[String] = 
        use SheetIO/NamedRowEvaluator.{map, alt, getStringNamedWithDefault, getInt64Named};
        alt(getStringNamedWithDefault(label, ""), map(Int64.toString, getInt64Named(label)))
        



    def exportAibAttributeRows(tableName: String, rows: List[AibAttributeRow]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldM, prepareStatement, psExecuteUpdate, commit};
        let* _          = execute("DROP TABLE IF EXISTS ${tableName};");
        let* _          = execute(createTableSql(tableName));
        let* stmt       = prepareStatement(insertRowSql(tableName));
        let* nrows      = foldM((ac, x) -> { let* n = psExecuteUpdate(stmt, aibAttributeRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)

    /// A setter for AibAttributeRow
    def aibAttributeRowSetter(x: AibAttributeRow): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!, putOptionFloat64At!};
        let* _  = putStringAt!(0, x.reference);
        let* _  = putStringAt!(1, x.assetStatus);
        let* _  = putS4DateAt!(2, x.installedFrom);
        let* _  = putStringAt!(3, x.manufacturer);
        let* _  = putStringAt!(4, x.model);
        let* _  = putStringAt!(5, x.partNumber);
        let* _  = putStringAt!(6, x.serialNumber);
        let* _  = putStringAt!(7, x.osgb36);
        let* _  = putStringAt!(8, x.locationOnSite);
        let* _  = putOptionFloat64At!(9, x.workLoad);
        let* _  = putStringAt!(10, x.workLoadUnits);
        let* _  = putStringAt!(11, x.statutoryRef);
        let* _  = putStringAt!(12, x.testCertNum);
        return()


    def putS4DateAt!(ix: Int32, dt: Time.LocalDate): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, liftActionResult, putStringAt!};
        let* fmt    = liftActionResult(_ -> Time/Format/DateFormatter.fromPattern("dd.MM.yyyy") as & Impure);
        let ans     = Time/LocalDate.format(dt, fmt);
        let* _      = putStringAt!(ix, ans);
        return()

    
    def insertRowSql(tableName: String): String =
        String.unwords(
            "INSERT INTO ${tableName} "
                :: "(reference, asset_status, installed_from, "
                :: "manufacturer, model, part_number, "
                :: "serial_number, osgb36, location_on_site, "
                :: "work_load, work_load_units, statutory_ref, "
                :: "test_cert_num)"
                :: "VALUES(?,?,?, ?,?,?, ?,?,?, ?,?,?, ?);"
                :: Nil
        )

    def createTableSql(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "reference           TEXT NOT NULL,"
                :: "asset_status        TEXT,"
                :: "installed_from      TEXT,"
                :: "manufacturer        TEXT,"
                :: "model               TEXT,"
                :: "part_number         TEXT,"
                :: "serial_number       TEXT,"
                :: "osgb36              TEXT NOT NULL,"
                :: "location_on_site    TEXT,"
                :: "work_load           REAL,"
                :: "work_load_units     TEXT,"
                :: "statutory_ref       TEXT,"
                :: "test_cert_num       TEXT"
                :: ")"
                :: Nil
        )



}