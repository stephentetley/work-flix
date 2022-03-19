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

namespace PDTKit/Configuration/ReadFieldTypesCsv {

    use Functor.{<$>};
    use Applicative.{<*>};

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;

    use CsvIO.RowReader;


    /// ## pdt_field_types.csv

    pub type alias FieldTypeRow = 
        { pdtFieldName :: String 
        , propertyType :: String
        }

    pub def readAndStoreFieldTypes(src: System.FilePath): DbMonad[List[FieldTypeRow]] =
        use BasicDb/DbMonad.{flatMap, point, liftActionResult};
        let* ans    = liftActionResult(_ -> readFieldTypes(src));
        let* _      = insertFieldTypes(ans);
        point(ans)

    def readFieldTypes(src: System.FilePath): Result[List[FieldTypeRow], String] & Impure = 
        use Result.flatMap;
        use CsvIO/RowEvaluator.{getStringNamed};
        let format = CsvIO/CsvFormat.defaultFormat(None) |> CsvIO/CsvFormat.putFirstRecordAsHeader;
        let eval = ((x1, x2) -> { pdtFieldName = x1, propertyType = x2}) 
                        <$> getStringNamed("pdt_field_name") <*> getStringNamed("property_type");
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

    pub def createMetaPdtFieldTypesTable(): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, point, setAutoCommit, execute, commit};
        let* _  = setAutoCommit(false);
        let* _  = execute("DROP TABLE IF EXISTS meta_pdt_field_types;");
        let* _  = execute(metaPdtFieldTypesTableDdl());
        let* _  = commit();
        point()


    def metaPdtFieldTypesTableDdl(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS meta_pdt_field_types ("
                :: "pdt_field_name TEXT NOT NULL,"
                :: "property_type TEXT NOT NULL,"
	            :: "PRIMARY KEY(pdt_field_name)"
	            :: ");"
                :: Nil
        )

}
