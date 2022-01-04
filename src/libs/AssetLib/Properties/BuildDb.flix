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

namespace AssetLib/Properties/BuildDb {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;

    use SheetIO/Reader.{XlsxSource};

    use AssetLib/FileIO/S4/ClassList/Datatypes.{ClassList, Characteristic};
    use AssetLib/Properties/Relations.{StringProperty, IntProperty, FloatProperty, AibProperties};

    /// A temporary untyped property
    rel UniProperty(rowId: Int32, name: String, value: String)

    rel AibType(propName: String, aibType: String)

    pub def readClassList(path: System.FilePath): Result[ClassList, String] & Impure = 
        AssetLib/FileIO/S4/ClassList/Builder.loadEquiClassList(path)

    pub def readProperties(input: {typesCsv :: System.FilePath, exports :: List[XlsxSource]}): Result[AibProperties[r1], String] & Impure = 
        use Result.flatMap;        
        let* r1 = AssetLib/Properties/BuildDb.readAibTypes(input.typesCsv);
        let* rs = Result.traverse(AssetLib/Properties/BuildDb.readAibExport, input.exports);
        let props = AssetLib/Properties/BuildDb.genProperties(r1 <+> RelLib/Relation.combineAll(rs));
        Ok(props)

    
    pub def readAibExport(src: XlsxSource): Result[#{UniProperty | r}, String] & Impure = 
        use Result.flatMap;
        let* allRows = SheetIO/Reader.allRows(SheetIO/RowEvaluator.getRowContents(), src);
        match allRows { 
            case Nil          => Ok(#{})
            case hdrs :: rows => { 
                let headers = Array.map(String.toUpperCase, hdrs);
                RelLib/Relation.foldMapWithIndex(makeUniProperties(headers), rows) |> Ok
            }
        }
        

    pub def readAibTypes(src: System.FilePath): Result[#{AibType | r}, String] & Impure = 
        use Result.flatMap;
        use CsvIO/RowEvaluator.{getStringAt};
        let format = CsvIO/CsvFormat.defaultFormat(None) |> CsvIO/CsvFormat.putFirstRecordAsHeader;
        let eval = Applicative.product(getStringAt(0), getStringAt(1));
        let mk1 = xy -> {let (x,y) = xy; #{ AibType(x, y). }};
        let* rows = CsvIO/CsvReader.readCsv(format, Text/Charset.utf_8(), eval, src);
        RelLib/Relation.foldMap(mk1, rows) |> Ok


    
    def makeUniProperties(headers: Array[String], row: Array[String], rowNum: Int32): #{UniProperty | r} & Impure = 
        let step = (ac, a, b) -> ac <+> #{ UniProperty(rowNum, a, b). };
        Array.foldLeft2(step, #{}, headers, row)


    pub def genProperties(input: #{UniProperty, AibType | r}): #{StringProperty, IntProperty, FloatProperty | r} = 
        let rules = #{

            StringProperty(plinum, propName, propValue) :- 
                AibType(propName, "STRING"),
                UniProperty(rowIx, propName, propValue),
                UniProperty(rowIx, "REFERENCE", plinum), 
                if not String.isEmpty(propValue).

            IntProperty(plinum, propName, intValue(propValue)) :- 
                AibType(propName, "INTEGER"),
                UniProperty(rowIx, propName, propValue),
                UniProperty(rowIx, "REFERENCE", plinum), 
                if isIntValue(propValue).

            FloatProperty(plinum, propName, floatValue(propValue)) :- 
                AibType(propName, "DECIMAL"),
                UniProperty(rowIx, propName, propValue),
                UniProperty(rowIx, "REFERENCE", plinum), 
                if isFloatValue(propValue).

        };
        let input1 = input as #{UniProperty, AibType, StringProperty, IntProperty, FloatProperty | r};
        solve (input1 <+> rules) project StringProperty, IntProperty, FloatProperty

    def isIntValue(s: String): Bool = 
        Int32.fromString(s) |> Result.isOk

    def intValue(s: String): Int32 = 
        Int32.fromString(s) |> Result.getWithDefault(-1)

    def isFloatValue(s: String): Bool = 
        Float64.fromString(s) |> Result.isOk

    def floatValue(s: String): Float64 = 
        Float64.fromString(s) |> Result.getWithDefault(-1.0f64)

    pub def storeProperties(dbpath: System.FilePath, relns: AibProperties[r1]): Result[Int32, String] & Impure = 
        use BasicDb/DbMonad.{flatMap, point};
        let steps = {
            let* n1 = storeProperties1("string_properties", stringPropertySetter, query relns select (x1, x2, x3) from StringProperty(x1, x2, x3));
            let* n2 = storeProperties1("int_properties", intPropertySetter, query relns select (x1, x2, x3) from IntProperty(x1, x2, x3));
            let* n3 = storeProperties1("float_properties", floatPropertySetter, query relns select (x1, x2, x3) from FloatProperty(x1, x2, x3));
            point(n1 + n2 + n3)
        };
        BasicDb/DbMonad.runSQLite(steps, dbpath)
            

    def storeProperties1(table: String, setter: a -> PreparedStatementSetter[Unit], rows: Array[(a)]): DbMonad[Int32] & Impure =
        use BasicDb/DbMonad.{flatMap, point, foldLeftM, setAutoCommit, prepareStatement, psExecuteUpdate, commit};
        let rows1       = Array.toList(rows);
        let* _          = setAutoCommit(false);
        let* stmt       = prepareStatement(insertPropertyRowSql(table));
        let* nrows      = Foldable.foldLeftM((ac, x) -> {let* n = psExecuteUpdate(stmt, setter(x)); point(ac+n)}, 0, rows1);
        let* _          = commit();
        point(nrows)


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


    def insertPropertyRowSql(tableName: String): String =
        String.unwords(
            "INSERT OR IGNORE INTO ${tableName} "
                :: "(pli_num, "
                :: "prop_name, "
                :: "prop_value) "
                :: "VALUES(?,?,?);"
                :: Nil
        )

    // # S4 Equi class export

    pub def storeS4ClassInfo(dbpath: System.FilePath, src: ClassList): Result[Int32, String] & Impure = 
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit, prepareStatement, psExecuteUpdate, commit};
        let steps = {
            let chars       = List.flatMap(x -> x.characteristics, src.classes);
            let* _          = setAutoCommit(false);
            let* stmt       = prepareStatement(insertDDS4PropertyRowSql());
            let* nrows      = Foldable.foldLeftM((ac, x) -> {let* n = psExecuteUpdate(stmt, ddS4PropertySetter(x)); point(ac+n)}, 0, chars);
            let* _          = commit();        
            point(nrows)
        };
        BasicDb/DbMonad.runSQLite(steps, dbpath)


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


    // # `property_aliases.csv`

    pub type alias PropertyAlias = 
        { aiName :: String
        , s4Class :: String
        , s4Char :: String
        }

    pub def readPropertyAliases(src: System.FilePath): Result[List[PropertyAlias], String] & Impure = 
        use Result.flatMap;
        use CsvIO/RowEvaluator.{getStringAt};
        let format = CsvIO/CsvFormat.defaultFormat(None) |> CsvIO/CsvFormat.putFirstRecordAsHeader;
        let eval = Applicative.liftA3((x, y, z) -> {aiName = x, s4Class = y, s4Char = z}, 
                                            getStringAt(0), getStringAt(1), getStringAt(2));
        CsvIO/CsvReader.readCsv(format, Text/Charset.utf_8(), eval, src)
        

    pub def storePropertyAliases(dbpath: System.FilePath, src: List[PropertyAlias]): Result[Int32, String] & Impure = 
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit, prepareStatement, psExecuteUpdate, commit};
        let steps = {
            let* _          = setAutoCommit(false);
            let* stmt       = prepareStatement(insertDDPropertyAliasRowSql());
            let* nrows      = Foldable.foldLeftM((ac, x) -> {let* n = psExecuteUpdate(stmt, ddPropertyAliasSetter(x)); point(ac+n)}, 0, src);
            let* _          = commit();        
            point(nrows)
        };
        BasicDb/DbMonad.runSQLite(steps, dbpath)



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

}
