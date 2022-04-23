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

// Multiple tabs

namespace PDTKit/Configuration/ReadFieldValueEnumXlsx {

    use Functor.{<$>};
    use Applicative.{<*>};

    use FlixSandbox/System.FilePath;

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;

    use SheetIO.NamedRowEvaluator;


    /// ## pdt_field_value_enum_specifications.xlsx

    pub type alias FieldValueEnumRow = 
        { pdtAssetClass :: String            // e.g. "PDT_Damper"
        , pdtFieldName :: String
        , pdtEnumValue :: String
        , s4EnumValue :: String
        }

    pub def readAndStoreFieldValueEnums(src: FilePath): DbMonad[List[FieldValueEnumRow]] =
        use BasicDb/DbMonad.{flatMap, point, liftActionResult};
        let* ans    = liftActionResult(_ -> readFieldValueEnums(src));
        let* _      = insertPdtFieldValueEnums(ans);
        point(ans)

    def readFieldValueEnums(src: FilePath): Result[List[FieldValueEnumRow], String] & Impure = 
        use Result.flatMap;
        use SheetIO/NamedRowEvaluator.{optional};
        let* tabs = SheetIO/SheetReader.runXlsx(SheetIO/SheetReader.getSheetNames(), src);
        let* ans  = SheetIO/Reader.someNamedRowsOfSheets(optional(evalFieldValueEnumRow()), tabs, src);
        Ok(ans)

    /// Drop incomplete rows - caller should wrap this with `optional`
    def evalFieldValueEnumRow(): NamedRowEvaluator[FieldValueEnumRow] = 
        use SheetIO/NamedRowEvaluator.{getSheetName, getNonEmptyContentNamed, getTrimmedContentNamed}; 
        ((x1, x2, x3, x4) ->  
                { pdtAssetClass = x1, pdtFieldName = x2, pdtEnumValue = x3, s4EnumValue = x4})
            <$> getSheetName()
            <*> getNonEmptyContentNamed("pdt_field_name") 
            <*> getNonEmptyContentNamed("pdt_enum_value") 
            <*> getTrimmedContentNamed("s4_enum_value")         /// Coulbd be blank?


    def insertPdtFieldValueEnums(src: List[FieldValueEnumRow]): DbMonad[Int32] = 
        let sqlstrings = { 
            prepStmt = String.unlines(
                            "INSERT OR IGNORE INTO meta_pdt_field_value_enums"
                        :: "(pdt_asset_class, pdt_field_name, pdt_enum_value, s4_enum_value)"
                        :: "VALUES(?,?,?, ?);"
                        :: Nil),
            tableActions = "DELETE FROM meta_pdt_field_value_enums;" :: Nil
        };
        BasicDb/Writer.store(sqlstrings, fieldValueEnumSetter, src)
    

    def fieldValueEnumSetter(x: FieldValueEnumRow): PreparedStatementSetter[Unit] =
        use BasicDb/PreparedStatementSetter.{flatMap, point, putStringAt!};
        let* _  = putStringAt!(0, x.pdtAssetClass);
        let* _  = putStringAt!(1, x.pdtFieldName);
        let* _  = putStringAt!(2, x.pdtEnumValue);
        let* _  = putStringAt!(3, x.s4EnumValue);
        point()

    pub def createMetaPdtFieldValueEnumsTable(): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit, execute, commit};
        let* _  = setAutoCommit(false);
        let* _  = execute("DROP TABLE IF EXISTS meta_pdt_field_value_enums;");
        let* _  = execute(metaPdtFieldValueEnumsTableDdl());
        let* _  = commit();
        point()


    def metaPdtFieldValueEnumsTableDdl(): String =
        String.unlines(
            "CREATE TABLE IF NOT EXISTS meta_pdt_field_value_enums ("
                :: "pdt_asset_class TEXT NOT NULL,"
                :: "pdt_field_name TEXT NOT NULL,"
                :: "pdt_enum_value TEXT NOT NULL,"
                :: "s4_enum_value TEXT,"
	            :: "PRIMARY KEY(pdt_asset_class, pdt_field_name, pdt_enum_value)"
	            :: ");"
                :: Nil
        )

}
