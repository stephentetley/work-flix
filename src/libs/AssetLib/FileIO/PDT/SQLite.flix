/*
 * Copyright 2021 Stephen Tetley
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

namespace AssetLib/FileIO/PDT/SQLite {

    use Applicative.{*>};

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

    use AssetLib/FileIO/PDT/CollateRows.{FieldValue};

    pub def storeFieldValues(table: String, relns: #{FieldValue | r}): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, liftAction};
        let* rows = liftAction(_ -> query relns select (x1, x2, x3, x4, x5, x6) from FieldValue(x1, x2, x3, x4, x5, x6) |> Array.toList);
        store(insertFieldValueRowSql(table), fieldValueSetter, rows)

    def fieldValueSetter(x: (String, Int32, String, String, String, String)): PreparedStatementSetter[Unit] =
        use BasicDb/PreparedStatementSetter.{putInt32At!, putStringAt!};
        let (x1, x2, x3, x4, x5, x6) = x;
        putStringAt!(0, x1)
            *> putInt32At!(1, x2) 
            *> putStringAt!(2, x3) 
            *> putStringAt!(3, x4) 
            *> putStringAt!(4, x5) 
            *> putStringAt!(5, x6)
        
    def insertFieldValueRowSql(tableName: String): String =
        String.unwords(
            "INSERT OR IGNORE INTO ${tableName} "
                :: "(source_file, "
                :: "row_num, "
                :: "asset_name, "
                :: "field_name, "
                :: "field_value, "
                :: "field_units) "
                :: "VALUES(?,?,?, ?,?,?);"
                :: Nil
        )

    // Helpers

    type alias Setter[a] = a -> PreparedStatementSetter[Unit]

    def store(insertSql: String, setter: Setter[a] , rows: t[a]): DbMonad[Int32] with Foldable[t] =
        use BasicDb/DbMonad.{flatMap, point, foldLeftM, setAutoCommit, prepareStatement, psExecuteUpdate, commit};
        let* _          = setAutoCommit(false);
        let* stmt       = prepareStatement(insertSql);
        let* nrows      = Foldable.foldLeftM((ac, x) -> 
                                {let* n = psExecuteUpdate(stmt, setter(x)); point(ac+n)}, 0, rows);
        let* _          = commit();
        point(nrows)

}
