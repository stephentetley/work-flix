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

    type alias FieldUnitType = 
        { pdtFieldUnits :: String 
        , s4Type :: String
        }

    pub def readAndStoreFieldUnitTypes(src: System.FilePath): DbMonad[List[FieldUnitType]] =
        use BasicDb/DbMonad.{flatMap, point, liftActionResult};
        let* ans    = liftActionResult(_ -> readFieldUnitTypes(src));
        let* _      = insertFieldUnitTypes(ans);
        point(ans)

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

    




}
