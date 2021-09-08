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

    use EquiCompare/Report/Relations.{AibEquipment, S4Equipment, SiteMap};

    
    /// Aib
    pub def getAibEquipment[r](tableName: String): DbMonad[#{AibEquipment | r}] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult, psExecuteQuery, foldAllRows, rsClose};
        let* ps     = prepareAibEquisQuery(tableName);
        let* rs     = psExecuteQuery(ps, BasicDb/PreparedStatementSetter.return());
        let* db     = foldAllRows(rs, (ac,x) -> ac <+> x, #{}, evalAibEquiRow());
        let* _      = rsClose(rs);
        return(solve db)

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

    def evalAibEquiRow[r](): RowEvaluator[#{AibEquipment | r}] = 
        use BasicDb/RowEvaluator.{getStringNamed, getFloat64Named, optional};
        use BasicDb/RowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7) -> AibEquipment(x1, x2, x3, x4, x5, x6, x7). )
            <&> getStringNamed("reference")
            <*> getStringNamed("common_name")
            <*> getStringNamed("site")
            <*> EquiCompare/Utils.getBasicDbLocalDateNamed("installed_from")
            <*> getStringNamed("manufacturer")
            <*> getStringNamed("model")
            <*> getStringNamed("serial_number")


    /// S4
    

    pub def getS4Equipment[r](tableName: String): DbMonad[#{S4Equipment | r}] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult, psExecuteQuery, foldAllRows, rsClose};
        let* ps     = prepareS4EquisQuery(tableName);
        let* rs     = psExecuteQuery(ps, BasicDb/PreparedStatementSetter.return());
        let* db     = foldAllRows(rs, (ac,x) -> ac <+> x, #{}, evalS4EquiRow());
        let* _      = rsClose(rs);
        return(solve db)

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

    def evalS4EquiRow[r](): RowEvaluator[#{S4Equipment | r}] = 
        use BasicDb/RowEvaluator.{getStringNamed, getFloat64Named, optional};
        use BasicDb/RowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7) -> S4Equipment(x1, x2, x3, x4, x5, x6, x7). )
            <&> getStringNamed("equipment")
            <*> getStringNamed("description")
            <*> getStringNamed("site")
            <*> EquiCompare/Utils.getBasicDbLocalDateNamed("startup_date")
            <*> getStringNamed("manufacturer")
            <*> getStringNamed("model")
            <*> getStringNamed("serial_number")


    /// Site Mapping
    
    pub def getSiteMap[r](tableName: String): DbMonad[#{SiteMap | r}] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult, psExecuteQuery, foldAllRows, rsClose};
        let* ps     = prepareSiteMapRowQuery(tableName);
        let* rs     = psExecuteQuery(ps, BasicDb/PreparedStatementSetter.return());
        let* db     = foldAllRows(rs, (a,b) -> a <+> b, #{}, evalSiteMapRow());
        let* _      = rsClose(rs);
        return(solve db)

    def prepareSiteMapRowQuery(tableName: String): DbMonad[PreparedStatement] = 
        let sql = String.unlines(
                "SELECT"
            :: "    t.installation_common_name,"
            :: "    t.s4_level1_code"
            :: "FROM"
            :: "    ${tableName} t"
            :: Nil
            );
        BasicDb/DbMonad.prepareStatement(sql)

    def evalSiteMapRow[r](): RowEvaluator[#{SiteMap | r}] = 
        use BasicDb/RowEvaluator.{getStringNamed, getFloat64Named, optional};
        use BasicDb/RowEvaluator.{<&>, <*>};
        ((x1, x2) -> RelLib/Relation.whenNot(String.isEmpty(x2), #{ SiteMap(x1, x2). }))
            <&> getStringNamed("installation_common_name")
            <*> getStringNamed("s4_level1_code")

}
