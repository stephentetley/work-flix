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

namespace S4Loader/PDT/BuildDb/StoreProperties {

    use Monad.{>>=};

    use Time.LocalDate;

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;
    use BasicDb/Writer.RowSetter;

    use Compatibility.{XlsxSource};

    use RelLib/Lattice/Constant.Constant;

    use S4Loader/PDT/BuildDb/Schema.{StringPropertyLat, IntPropertyLat, FloatPropertyLat, DatePropertyLat, S4Properties};


    pub def storeProperties(relns: S4Properties[r1]): DbMonad[Int32] = 
        use BasicDb/DbMonad.{flatMap, point, liftAction};
        let* n1 = (query relns select (x1, x2, x3) from StringPropertyLat(x1, x2; x3))  |> storeStringProperties;
        let* n2 = (query relns select (x1, x2, x3) from IntPropertyLat(x1, x2; x3))     |> storeIntProperties;
        let* n3 = (query relns select (x1, x2, x3) from FloatPropertyLat(x1, x2; x3))   |> storeFloatProperties;
        let* n4 = (query relns select (x1, x2, x3) from DatePropertyLat(x1, x2; x3))    |> storeDateProperties;
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

    def getValuableRow(t: (String, String, Constant[a])): Option[(String, String, a)] = 
        let (x1, x2, x3) = t;
        x3 
            |> RelLib/Lattice/Constant.getValue
            |> Option.map(ans -> (x1, x2, ans))

    def storeStringProperties(rows: Array[(String, String, Constant[String])]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, liftAction};
        let sqlstrings = 
            { prepStmt = insertPropertyRowSql("string_properties")
            , tableActions = "DELETE FROM string_properties;" :: Nil 
            };
        let* rows1 = liftAction(_ -> Array.filterMap(getValuableRow, rows));
        BasicDb/Writer.storeArray(sqlstrings, stringPropertySetter, rows1)


    def stringPropertySetter(x: (String, String, String)): PreparedStatementSetter[Unit] =
        use BasicDb/PreparedStatementSetter.{flatMap, point, putStringAt!};
        let (pli, name, value) = x;
        let* _  = putStringAt!(0, pli);
        let* _  = putStringAt!(1, name);
        let* _  = putStringAt!(2, value);        
        point()

    def storeIntProperties(rows: Array[(String, String, Constant[Int32])]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, liftAction};
        let sqlstrings = 
            { prepStmt = insertPropertyRowSql("int_properties")
            , tableActions = "DELETE FROM int_properties;" :: Nil 
            };
        let* rows1 = liftAction(_ -> Array.filterMap(getValuableRow, rows));
        BasicDb/Writer.storeArray(sqlstrings, intPropertySetter, rows1)


    def intPropertySetter(x: (String, String, Int32)): PreparedStatementSetter[Unit] =
        use BasicDb/PreparedStatementSetter.{flatMap, point, putStringAt!, putInt32At!};
        let (pli, name, value) = x;
        let* _  = putStringAt!(0, pli);
        let* _  = putStringAt!(1, name);
        let* _  = putInt32At!(2, value);
        point()


    def storeFloatProperties(rows: Array[(String, String, Constant[Float64])]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, liftAction};
        let sqlstrings = 
            { prepStmt = insertPropertyRowSql("float_properties")
            , tableActions = "DELETE FROM float_properties;" :: Nil 
            };
        let* rows1 = liftAction(_ -> Array.filterMap(getValuableRow, rows));
        BasicDb/Writer.storeArray(sqlstrings, floatPropertySetter, rows1)


    def floatPropertySetter(x: (String, String, Float64)): PreparedStatementSetter[Unit] =
        use BasicDb/PreparedStatementSetter.{flatMap, point, putStringAt!, putFloat64At!};
        let (pli, name, value) = x;
        let* _  = putStringAt!(0, pli);
        let* _  = putStringAt!(1, name);
        let* _  = putFloat64At!(2, value);
        point()


    def storeDateProperties(rows: Array[(String, String, Constant[LocalDate])]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, liftAction};
        let sqlstrings = 
            { prepStmt = insertPropertyRowSql("date_properties")
            , tableActions = "DELETE FROM date_properties;" :: Nil 
            };
        let* rows1 = liftAction(_ -> Array.filterMap(getValuableRow, rows));
        BasicDb/Writer.storeArray(sqlstrings, datePropertySetter, rows1)

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


}
