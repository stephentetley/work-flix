/*
 * Copyright 2022 Stephen Tetley
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

/// Out-of-date
/// PDT has own version
/// When AIB is picked up again it needs to make its own version

namespace S4Loader/Base/StoreProperties {

    use Monad.{>>=};

    use Basis/System.FilePath;
    use Time.LocalDate;

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;
    use BasicDb/Writer.RowSetter;

    use Compatibility.{XlsxSource};


    use S4Loader/Base/Schema.{StringProperty, IntProperty, FloatProperty, DateProperty, S4Properties};


    pub def storeProperties(relns: S4Properties[r1]): DbMonad[Int32] = 
        use BasicDb/DbMonad.{flatMap, point};
        let* n1 = storeProperties1("string_properties", stringPropertySetter, query relns select (x1, x2, x3) from StringProperty(x1, x2, x3));
        let* n2 = storeProperties1("int_properties", intPropertySetter, query relns select (x1, x2, x3) from IntProperty(x1, x2, x3));
        let* n3 = storeProperties1("float_properties", floatPropertySetter, query relns select (x1, x2, x3) from FloatProperty(x1, x2, x3));
        let* n4 = storeProperties1("date_properties", datePropertySetter, query relns select (x1, x2, x3) from DateProperty(x1, x2, x3));
        point(n1 + n2 + n3 + n4)
        
    pub def deleteProperties(): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit, execute, commit};
        let* _          = setAutoCommit(false);
        let* _          = execute("DELETE FROM string_properties;");
        let* _          = execute("DELETE FROM int_properties;");
        let* _          = execute("DELETE FROM float_properties;");
        let* _          = execute("DELETE FROM date_properties;");
        let* _          = commit();
        point()

    def storeProperties1(table: String, setter: RowSetter[a], rows: Array[(a)]): DbMonad[Int32] =
        let sqlstrings = {prepStmt = insertPropertyRowSql(table), tableActions = "DELETE FROM ${table};" :: Nil };
        BasicDb/Writer.storeArray(sqlstrings, setter, rows)


    def stringPropertySetter(x: (String, String, String)): PreparedStatementSetter[Unit] =
        use BasicDb/PreparedStatementSetter.{flatMap, point, putStringAt!};
        let (pli, name, value) = x;
        let* _  = putStringAt!(0, pli);
        let* _  = putStringAt!(1, name);
        let* _  = putStringAt!(2, value);        
        point()


    def intPropertySetter(x: (String, String, Int32)): PreparedStatementSetter[Unit] =
        use BasicDb/PreparedStatementSetter.{flatMap, point, putStringAt!, putInt32At!};
        let (pli, name, value) = x;
        let* _  = putStringAt!(0, pli);
        let* _  = putStringAt!(1, name);
        let* _  = putInt32At!(2, value);
        point()


    def floatPropertySetter(x: (String, String, Float64)): PreparedStatementSetter[Unit] =
        use BasicDb/PreparedStatementSetter.{flatMap, point, putStringAt!, putFloat64At!};
        let (pli, name, value) = x;
        let* _  = putStringAt!(0, pli);
        let* _  = putStringAt!(1, name);
        let* _  = putFloat64At!(2, value);
        point()

    def datePropertySetter(x: (String, String, LocalDate)): PreparedStatementSetter[Unit] =
        use BasicDb/PreparedStatementSetter.{flatMap, point, putStringAt!, putIsoLocalDateStringAt!};
        let (pli, name, value) = x;
        let* _  = putStringAt!(0, pli);
        let* _  = putStringAt!(1, name);
        let* _  = putIsoLocalDateStringAt!(2, value);        
        point()


    def insertPropertyRowSql(tableName: String): String =
        String.unwords(
            "INSERT OR IGNORE INTO ${tableName} "
                :: "(equipment_id, "
                :: "prop_name, "
                :: "prop_value) "
                :: "VALUES(?,?,?);"
                :: Nil
        )

    // # S4 Equi class export

    // Use ClassList instead...

/*
    pub def storeS4ClassInfo(path: FilePath): DbMonad[Int32] = 
        use BasicDb/DbMonad.{liftActionResult};
        liftActionResult(_ -> readClassList(path)) >>= insertS4ClassInfo

    def readClassList(path: FilePath): Result[ClassList, String] & Impure = 
        AssetLib/FileIO/S4/ClassList/Builder.loadEquiClassList(path)

    def insertS4ClassInfo(src: ClassList): DbMonad[Int32] = 
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit, prepareStatement, psExecuteUpdate, commit};
        let chars       = List.flatMap(x -> x.characteristics, src.classes);
        let* _          = setAutoCommit(false);
        let* stmt       = prepareStatement(insertDDS4PropertyRowSql());
        let* nrows      = Foldable.foldLeftM((ac, x) -> {let* n = psExecuteUpdate(stmt, ddS4PropertySetter(x)); point(ac+n)}, 0, chars);
        let* _          = commit();        
        point(nrows)
    

    def ddS4PropertySetter(x: Characteristic): PreparedStatementSetter[Unit] =
        use BasicDb/PreparedStatementSetter.{flatMap, point, putStringAt!, putInt32At!, putOptionInt32At!};
        let* _  = putStringAt!(0, x.name);
        let* _  = putStringAt!(1, String.toUpperCase(AssetLib/FileIO/S4/ClassList/Datatypes.s4TypeName(x.chartype)));
        let* _  = putInt32At!(2, AssetLib/FileIO/S4/ClassList/Datatypes.s4StorageSize(x.chartype));
        let* _  = putOptionInt32At!(3, AssetLib/FileIO/S4/ClassList/Datatypes.s4DecimalPlaces(x.chartype));
        point()

    def insertDDS4PropertyRowSql(): String =
        String.unwords(
            "INSERT OR IGNORE INTO dd_s4_properties "
                :: "(char_name, "
                :: "char_type, "
                :: "char_size, "
                :: "decimal_places) "
                :: "VALUES(?,?,?,?);"
                :: Nil
        )
*/

    // # `property_aliases.csv`

    // TODO - make from ClassList data instead...

    pub type alias PropertyAlias = 
        { aiName :: String
        , s4Class :: String
        , s4Char :: String
        }

    pub def storePropertyAliases(src: FilePath): DbMonad[Int32] = 
        use BasicDb/DbMonad.{liftActionResult};
        liftActionResult(_ -> readPropertyAliases(src)) >>= insertPropertyAliases


    pub def readPropertyAliases(src: FilePath): Result[List[PropertyAlias], String] & Impure = 
        use Result.flatMap;
        use CsvIO/RowEvaluator.{getStringAt};
        let format = CsvIO/CsvFormat.defaultFormat(None) |> CsvIO/CsvFormat.putFirstRecordAsHeader;
        let eval = Applicative.liftA3((x, y, z) -> {aiName = x, s4Class = y, s4Char = z}, 
                                            getStringAt(0), getStringAt(1), getStringAt(2));
        CsvIO/CsvReader.readCsv(format, FlixSandbox/Text/Charset.utf_8(), eval, src)
        

    pub def insertPropertyAliases(xs: List[PropertyAlias]): DbMonad[Int32] = 
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit, prepareStatement, psExecuteUpdate, commit};
        let* _          = setAutoCommit(false);
        let* stmt       = prepareStatement(insertDDPropertyAliasRowSql());
        let* nrows      = Foldable.foldLeftM((ac, x) -> {let* n = psExecuteUpdate(stmt, ddPropertyAliasSetter(x)); point(ac+n)}, 0, xs);
        let* _          = commit();        
        point(nrows)
    



    def ddPropertyAliasSetter(x: PropertyAlias): PreparedStatementSetter[Unit] =
        use BasicDb/PreparedStatementSetter.{flatMap, point, putStringAt!, putInt32At!, putOptionInt32At!};
        let* _  = putStringAt!(0, x.aiName);
        let* _  = putStringAt!(1, x.s4Class);
        let* _  = putStringAt!(2, x.s4Char);
        point()

    def insertDDPropertyAliasRowSql(): String =
        String.unwords(
            "INSERT OR IGNORE INTO dd_property_aliases "
                :: "(ai_prop_name, "
                :: "s4_class_name, "
                :: "s4_char_name) "
                :: "VALUES(?,?,?);"
                :: Nil
        )


    // # ZTables

    pub def storeZTableManuf(src: FilePath): DbMonad[Int32] = 
        use BasicDb/DbMonad.{liftActionResult};
        liftActionResult(_ -> AssetLib/FileIO/S4/ZTable/Builtins.loadManufacturerModel(src))
            >>= AssetLib/FileIO/S4/ZTable/SQLite.storeManufacturerModel("ztable_manuf")


    pub def storeZTableObj(src: FilePath): DbMonad[Int32] = 
        use BasicDb/DbMonad.{liftActionResult};
        liftActionResult(_ -> AssetLib/FileIO/S4/ZTable/Builtins.loadObjTypeManufacturer(src))
            >>= AssetLib/FileIO/S4/ZTable/SQLite.storeObjTypeManufacturer("ztable_obj")
    
    

}
