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


namespace EquiCompare/Report/Loader {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatement;
    use BasicDb.RowEvaluator;



    type alias EquiRow = 
        { uid: String
        , name: String
        , site: String
        , installDate: Time.LocalDate
        , manufacturer: String
        , modelName: String
        , serialNumber: String
        }

    /// Aib

    pub def getAibEquis(tableName: String): DbMonad[List[EquiRow]] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult, psExecuteQuery, allRows, rsClose};
        let* ps     = prepareAibEquisQuery(tableName);
        let* rs     = psExecuteQuery(ps, BasicDb/PreparedStatementSetter.return());
        let* xs     = allRows(rs, evalAibEquiRow());
        let* _      = rsClose(rs);
        return(xs)

    def prepareAibEquisQuery(tableName: String): DbMonad[PreparedStatement] = 
        let sql = String.unlines(
                "SELECT"
            :: "    t.reference,"
            :: "    t.common_name,"
            :: "    t.site,"
            :: "    t.installed_from,"
            :: "    t.manufacturer,"
            :: "    t.model,"
            :: "    t.serial_number"
            :: "FROM"
            :: "    ${tableName} t"
            :: Nil
            );
        BasicDb/DbMonad.prepareStatement(sql)

    def evalAibEquiRow(): RowEvaluator[EquiRow] = 
        use BasicDb/RowEvaluator.{getStringNamed, getFloat64Named, optional};
        use BasicDb/RowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7) ->
                { uid           = x1
                , name          = x2
                , site          = x3
                , installDate   = x4
                , manufacturer  = x5
                , modelName     = x6
                , serialNumber  = x7
                })
            <&> getStringNamed("reference")
            <*> getStringNamed("common_name")
            <*> getStringNamed("site")
            <*> EquiCompare/Utils.getBasicDbLocalDateNamed("installed_from")
            <*> getStringNamed("manufacturer")
            <*> getStringNamed("model")
            <*> getStringNamed("serial_number")


    /// S4
    
    pub def getS4Equis(tableName: String): DbMonad[List[EquiRow]] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult, psExecuteQuery, allRows, rsClose};
        let* ps     = prepareS4EquisQuery(tableName);
        let* rs     = psExecuteQuery(ps, BasicDb/PreparedStatementSetter.return());
        let* xs     = allRows(rs, evalS4EquiRow());
        let* _      = rsClose(rs);
        return(xs)

    def prepareS4EquisQuery(tableName: String): DbMonad[PreparedStatement] = 
        let sql = String.unlines(
                "SELECT"
            :: "    t.equipment,"
            :: "    t.description,"
            :: "    t.site,"
            :: "    t.startup_date,"
            :: "    t.manufacturer,"
            :: "    t.model,"
            :: "    t.serial_number"
            :: "FROM"
            :: "    ${tableName} t"
            :: Nil
            );
        BasicDb/DbMonad.prepareStatement(sql)

    def evalS4EquiRow(): RowEvaluator[EquiRow] = 
        use BasicDb/RowEvaluator.{getStringNamed, getFloat64Named, optional};
        use BasicDb/RowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7) ->
                { uid           = x1
                , name          = x2
                , site          = x3
                , installDate   = x4
                , manufacturer  = x5
                , modelName     = x6
                , serialNumber  = x7
                })
            <&> getStringNamed("equipment")
            <*> getStringNamed("description")
            <*> getStringNamed("site")
            <*> EquiCompare/Utils.getBasicDbLocalDateNamed("startup_date")
            <*> getStringNamed("manufacturer")
            <*> getStringNamed("model")
            <*> getStringNamed("serial_number")


}
