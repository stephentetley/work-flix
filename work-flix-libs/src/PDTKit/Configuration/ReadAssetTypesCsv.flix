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

namespace PDTKit/Configuration/ReadAssetTypesCsv {

    use Functor.{<$>};
    use Applicative.{<*>, *>};

    use Basis/System.FilePath;
    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;

    use CsvIO.RowReader;

    /// ## pdt_asset_types.csv

    pub type alias AssetTypeRow = 
        { pdtAssetType :: String 
        , s4Category :: String
        , s4Object :: String
        , s4Class :: String
        }

    pub def readAndStoreAssetTypes(src: FilePath): DbMonad[List[AssetTypeRow]] =
        use BasicDb/DbMonad.{flatMap, point, liftActionResult};
        let* ans    = liftActionResult(_ -> readAssetTypes(src));
        let* _      = insertAssetTypes(ans);
        point(ans)

    pub def readAssetTypes(src: FilePath): Result[List[AssetTypeRow], String] & Impure = 
        use Result.flatMap;
        use CsvIO/RowEvaluator.{getStringNamed};
        use CsvIO/CsvFormat.PredefinedFormat.{DEFAULT};
        use CsvIO/CsvFormatBuilder.{toCsvFormatWithCsvFormat, setHeaderAuto, setHeaders, setSkipHeaderRecord};
        let* format = region r1 {
            toCsvFormatWithCsvFormat(CsvIO/CsvFormat.makeCsvFormat(DEFAULT), setHeaderAuto() *> setSkipHeaderRecord(true), r1)
        }; 
        let eval = ((x1, x2, x3, x4) -> { pdtAssetType = x1, s4Category = x2, s4Object = x3, s4Class = x4}) 
                        <$> getStringNamed("class_description") <*> getStringNamed("s4_category") 
                        <*> getStringNamed("s4_object")         <*> getStringNamed("s4_class");
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



    /// PDT only
    pub def createMetaPdtAssetTypesTable(): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit, execute, commit};
        let* _  = setAutoCommit(false);
        let* _  = execute("DROP TABLE IF EXISTS meta_pdt_asset_types;");
        let* _  = execute(metaPdtAssetTypesTableDdl());
        let* _  = commit();
        point()



    def metaPdtAssetTypesTableDdl(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS meta_pdt_asset_types ("
                :: "pdt_asset_type TEXT NOT NULL,"
                :: "s4_category TEXT NOT NULL,"
                :: "s4_object TEXT NOT NULL,"
                :: "s4_class TEXT NOT NULL,"
	            :: "PRIMARY KEY(pdt_asset_type)"
	            :: ");"
                :: Nil
        )

}
