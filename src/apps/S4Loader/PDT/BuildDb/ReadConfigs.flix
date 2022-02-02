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

namespace S4Loader/PDT/BuildDb/ReadConfigs {

    use Functor.{<$>};
    use Applicative.{<*>};

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;

    use CsvIO.RowReader;

    use S4Loader/PDT/BuildDb/Schema.{UnitsType};

    /// ## pdt_field_unit_types.csv

    pub type alias FieldUnitType = 
        { pdtFieldUnits :: String 
        , s4Type :: String
        }

    pub def readAndStoreFieldUnitTypes(src: System.FilePath): DbMonad[#{UnitsType | r}] =
        use BasicDb/DbMonad.{flatMap, point, liftActionResult};
        let* ans    = liftActionResult(_ -> readFieldUnitTypes(src));
        let* _      = insertFieldUnitTypes(ans);
        let relns   = RelLib/Relation.foldMap(x1 -> #{ UnitsType(x1.pdtFieldUnits, x1.s4Type). }, ans);
        point(relns)

    def readFieldUnitTypes(src: System.FilePath): Result[List[FieldUnitType], String] & Impure = 
        use Result.flatMap;
        use CsvIO/RowEvaluator.{getStringAt};
        let format = CsvIO/CsvFormat.defaultFormat(None) |> CsvIO/CsvFormat.putFirstRecordAsHeader;
        let eval = ((x1, x2) -> { pdtFieldUnits = x1, s4Type = x2}) <$> getStringAt(0) <*> getStringAt(1);
        let* rows = CsvIO/CsvReader.readCsv(format, Text/Charset.utf_8(), eval, src);
        Ok(rows)

    def insertFieldUnitTypes(src: List[FieldUnitType]): DbMonad[Int32] = 
        let sqlstrings = { 
            prepStmt = "INSERT OR IGNORE INTO meta_pdt_field_unit_types (field_unit, s4_type) VALUES(?,?);",
            tableActions = "DELETE FROM meta_pdt_field_unit_types;" :: Nil
        };
        BasicDb/Writer.store(sqlstrings, fieldUnitTypeSetter, src)
    

    def fieldUnitTypeSetter(x: FieldUnitType): PreparedStatementSetter[Unit] =
        use BasicDb/PreparedStatementSetter.{flatMap, point, putStringAt!};
        let* _  = putStringAt!(0, x.pdtFieldUnits);
        let* _  = putStringAt!(1, x.s4Type);
        point()

    /// ## pdt_asset_types.csv

    pub type alias AssetType = 
        { pdtAssetType :: String 
        , s4Object :: String
        , s4Class :: String
        }

    pub def readAndStoreAssetTypes(src: System.FilePath): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, point, liftActionResult};
        let* ans    = liftActionResult(_ -> readAssetTypes(src));
        let* _      = insertAssetTypes(ans);
        point()

    def readAssetTypes(src: System.FilePath): Result[List[AssetType], String] & Impure = 
        use Result.flatMap;
        use CsvIO/RowEvaluator.{getStringAt};
        let format = CsvIO/CsvFormat.defaultFormat(None) |> CsvIO/CsvFormat.putFirstRecordAsHeader;
        let eval = ((x1, x2, x3) -> { pdtAssetType = x1, s4Object = x2, s4Class = x3}) <$> getStringAt(0) <*> getStringAt(1) <*> getStringAt(2);
        let* rows = CsvIO/CsvReader.readCsv(format, Text/Charset.utf_8(), eval, src);
        Ok(rows)

    def insertAssetTypes(src: List[AssetType]): DbMonad[Int32] = 
        let sqlstrings = { 
            prepStmt = "INSERT OR IGNORE INTO meta_pdt_asset_types (pdt_asset_type, s4_object, s4_class) VALUES(?,?,?);",
            tableActions = "DELETE FROM meta_pdt_asset_types;" :: Nil
        };
        BasicDb/Writer.store(sqlstrings, assetTypeSetter, src)
    

    def assetTypeSetter(x: AssetType): PreparedStatementSetter[Unit] =
        use BasicDb/PreparedStatementSetter.{flatMap, point, putStringAt!};
        let* _  = putStringAt!(0, x.pdtAssetType);
        let* _  = putStringAt!(1, x.s4Object);
        let* _  = putStringAt!(2, x.s4Class);
        point()





}
