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

namespace S4Loader/Aib/BuildDb {

    use Monad.{>>=};

    use Basis/System.FilePath;
    use Time.LocalDate;

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;

    use Compatibility.{XlsxSource};

    use AssetLib/FileIO/S4/ClassList/Datatypes.{ClassList, Characteristic};

    use S4Loader/Base/Schema.{StringProperty, IntProperty, FloatProperty, DateProperty, S4Properties};

    /// A temporary untyped property
    rel UniProperty(rowId: Int32, name: String, value: String)

    rel AibType(propName: String, aibType: String)


    pub def generateProperties(input: {typesCsv :: FilePath, exports :: List[XlsxSource]}): DbMonad[Int32] = 
        use BasicDb/DbMonad.{liftActionResult};
        liftActionResult(_ -> readProperties(input)) >>= S4Loader/Base/StoreProperties.storeProperties

    pub def readProperties(input: {typesCsv :: FilePath, exports :: List[XlsxSource]}): Result[S4Properties[r1], String] & Impure = 
        use Result.flatMap;        
        let* r1     = readAibTypes(input.typesCsv);
        let* rs     = Result.traverse(readAibExport, input.exports);
        let r2      = RelLib/Relation.combineAll(rs);
        let props   = genProperties(r1 <+> r2);
        query r2 select (x1, x2, x3) from UniProperty(x1, x2, x3) 
            |> Array.filter(xyz -> let (_, y, _) = xyz; y == "Installed From")
            |> Array.foreach(println);
        Ok(props)

    pub def readAibTypes(src: FilePath): Result[#{AibType | r}, String] & Impure = 
        use Result.flatMap;
        use CsvIO/RowEvaluator.{getStringAt};
        let format = CsvIO/CsvFormat.defaultFormat(None) |> CsvIO/CsvFormat.putFirstRecordAsHeader;
        let eval = Applicative.product(getStringAt(0), getStringAt(1));
        let mk1 = xy -> {let (x,y) = xy; #{ AibType(x, y). }};
        let* rows = CsvIO/CsvReader.readCsv(format, FlixSandbox/Text/Charset.utf_8(), eval, src);
        let relns = RelLib/Relation.foldMap(mk1, rows);
        Ok(relns)
    
    pub def readAibExport(src: XlsxSource): Result[#{UniProperty | r}, String] & Impure = 
        use Result.flatMap;
        let* allRows = SheetIO/Reader.allRows(SheetIO/RowEvaluator.getRowContentsIsoLocalDateTime(), src);
        match allRows { 
            case Nil          => Ok(#{})
            case hdrs :: rows => { 
                RelLib/Relation.foldMapWithIndex(makeUniProperties(hdrs), rows) |> Ok
            }
        }
        



    
    def makeUniProperties(headers: Array[String], row: Array[String], rowNum: Int32): #{UniProperty | r} & Impure = 
        let step = (ac, a, b) -> ac <+> #{ UniProperty(rowNum, a, b). };
        Array.foldLeft2(step, #{}, headers, row)


    pub def genProperties(input: #{UniProperty, AibType | r}): #{StringProperty, IntProperty, FloatProperty, DateProperty | r} = 
        let rules = #{

            StringProperty(plinum, propName, propValue) :- 
                AibType(propName, "STRING"),
                UniProperty(rowIx, propName, propValue),
                UniProperty(rowIx, "Reference", plinum), 
                if not String.isEmpty(propValue).

            IntProperty(plinum, propName, S4Loader/Base/Utils.intValue(propValue)) :- 
                AibType(propName, "INTEGER"),
                UniProperty(rowIx, propName, propValue),
                UniProperty(rowIx, "Reference", plinum), 
                if S4Loader/Base/Utils.isIntValue(propValue).

            FloatProperty(plinum, propName, S4Loader/Base/Utils.floatValue(propValue)) :- 
                AibType(propName, "DECIMAL"),
                UniProperty(rowIx, propName, propValue),
                UniProperty(rowIx, "Reference", plinum), 
                if S4Loader/Base/Utils.isFloatValue(propValue).

            DateProperty(plinum, propName, S4Loader/Base/Utils.dateFromIsoLocalDateTime(propValue)) :- 
                AibType(propName, "DATE"),
                UniProperty(rowIx, propName, propValue),
                UniProperty(rowIx, "Reference", plinum), 
                if S4Loader/Base/Utils.isIsoLocalDateTimeValue(propValue).

        };
        let input1 = input as #{UniProperty, AibType, StringProperty, IntProperty, FloatProperty, DateProperty | r};
        solve (input1 <+> rules) project StringProperty, IntProperty, FloatProperty, DateProperty


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
