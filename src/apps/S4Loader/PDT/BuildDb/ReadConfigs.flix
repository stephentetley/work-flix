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

    use S4Loader/PDT/BuildDb/Schema.{FieldType};

    /// ## pdt_field_types.csv

    pub type alias FieldTypeRow = 
        { pdtFieldName :: String 
        , propertyType :: String
        }

    pub def readAndStoreFieldTypes(src: System.FilePath): DbMonad[#{FieldType | r}] =
        use BasicDb/DbMonad.{flatMap, point, liftActionResult};
        let* ans    = liftActionResult(_ -> readFieldTypes(src));
        let* _      = insertFieldTypes(ans);
        let relns   = RelLib/Relation.foldMap(x1 -> #{ FieldType(x1.pdtFieldName, x1.propertyType). }, ans);
        point(relns)

    def readFieldTypes(src: System.FilePath): Result[List[FieldTypeRow], String] & Impure = 
        use Result.flatMap;
        use CsvIO/RowEvaluator.{getStringAt};
        let format = CsvIO/CsvFormat.defaultFormat(None) |> CsvIO/CsvFormat.putFirstRecordAsHeader;
        let eval = ((x1, x2) -> { pdtFieldName = x1, propertyType = x2}) <$> getStringAt(0) <*> getStringAt(1);
        let* rows = CsvIO/CsvReader.readCsv(format, Text/Charset.utf_8(), eval, src);
        Ok(rows)

    def insertFieldTypes(src: List[FieldTypeRow]): DbMonad[Int32] = 
        let sqlstrings = { 
            prepStmt = "INSERT OR IGNORE INTO meta_pdt_field_types (pdt_field_name,property_type) VALUES(?,?);",
            tableActions = "DELETE FROM meta_pdt_field_types;" :: Nil
        };
        BasicDb/Writer.store(sqlstrings, fieldTypeSetter, src)
    

    def fieldTypeSetter(x: FieldTypeRow): PreparedStatementSetter[Unit] =
        use BasicDb/PreparedStatementSetter.{flatMap, point, putStringAt!};
        let* _  = putStringAt!(0, x.pdtFieldName);
        let* _  = putStringAt!(1, x.propertyType);
        point()

    /// ## pdt_asset_types.csv

    pub type alias AssetTypeRow = 
        { pdtAssetType :: String 
        , s4Category :: String
        , s4Object :: String
        , s4Class :: String
        }

    pub def readAndStoreAssetTypes(src: System.FilePath): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, point, liftActionResult};
        let* ans    = liftActionResult(_ -> readAssetTypes(src));
        let* _      = insertAssetTypes(ans);
        point()

    def readAssetTypes(src: System.FilePath): Result[List[AssetTypeRow], String] & Impure = 
        use Result.flatMap;
        use CsvIO/RowEvaluator.{getStringAt};
        let format = CsvIO/CsvFormat.defaultFormat(None) |> CsvIO/CsvFormat.putFirstRecordAsHeader;
        let eval = ((x1, x2, x3, x4) -> { pdtAssetType = x1, s4Category = x2, s4Object = x3, s4Class = x4}) 
                        <$> getStringAt(0) <*> getStringAt(1) <*> getStringAt(2) <*> getStringAt(3);
        let* rows = CsvIO/CsvReader.readCsv(format, Text/Charset.utf_8(), eval, src);
        Ok(rows)

    def insertAssetTypes(src: List[AssetTypeRow]): DbMonad[Int32] = 
        let sqlstrings = { 
            prepStmt = "INSERT OR IGNORE INTO meta_pdt_asset_types (pdt_asset_type, s4_category, s4_object, s4_class) VALUES(?,?,?,?);",
            tableActions = "DELETE FROM meta_pdt_asset_types;" :: Nil
        };
        BasicDb/Writer.store(sqlstrings, assetTypeSetter, src)
    

    def assetTypeSetter(x: AssetTypeRow): PreparedStatementSetter[Unit] =
        use BasicDb/PreparedStatementSetter.{flatMap, point, putStringAt!};
        let* _  = putStringAt!(0, x.pdtAssetType);
        let* _  = putStringAt!(1, x.s4Category);
        let* _  = putStringAt!(2, x.s4Object);    
        let* _  = putStringAt!(3, x.s4Class);
        point()





}
