/*
 * Copyright 2020 Stephen Tetley
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

namespace AssetLib/S4/Simple/FlocDownloadBuilder {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatement;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

    use AssetLib/S4/Simple/Datatypes.{LongText};

    /// TODO - needs completing, see EquiBuilder 

    /// Classification
    pub def prepareFlocClassificationsQuery(): DbMonad[PreparedStatement] = 
        BasicDb/DbMonad.prepareStatement(getFlocClassificationsSql())

    pub def getFlocClassifications(pstmt: PreparedStatement, floc: String): DbMonad[List[Classification]] = 
        use BasicDb/DbMonad.{flatMap, return, psExecuteQuery, allRows, rsClose};
        let* rs     = psExecuteQuery(pstmt, setFlocClassificationPStmt!(floc));
        let* xs     = allRows(rs, evalClassification());
        let* _      = rsClose(rs);
        return(xs)

    def getFlocClassificationsSql(): String  = 
        String.unwords(
               "SELECT"
            :: "    c.class_name, cfm.charname, cfcd.datatype, v.value_description, v.value_from"
            :: "FROM"
            :: "    class_floc c"
            :: "INNER JOIN  cf_members cfm      ON c.class_name = cfm.classname"
            :: "JOIN        cf_char_defs cfcd   ON cfm.charname = cfcd.charname"
            :: "JOIN        valua_floc v        ON c.floc = v.floc AND cfm.charname = v.char_id"
            :: "WHERE"
            :: "    c.floc = ?"
            :: "AND cfm.classtype = 'floc'"
            :: "AND cfcd.classtype = 'floc'"
            :: "ORDER BY c.class_name;"
            :: Nil
        )

    def setFlocClassificationPStmt!(floc: String): PreparedStatementSetter[Unit] = 
        BasicDb/PreparedStatementSetter.putStringAt!(0,  floc)




    /// Long Text
    pub def prepareFlocLongTextQuery(): DbMonad[PreparedStatement] = 
        BasicDb/DbMonad.prepareStatement(getFlocLongTextSql())

    pub def getFlocLongText(pstmt: PreparedStatement, floc: String): DbMonad[Option[LongText]] = 
        use BasicDb/DbMonad.{flatMap, return, psExecuteQuery, optional, firstRow, rsClose};
        let* rs     = psExecuteQuery(pstmt, setFlocLongTextPStmt!(floc));
        let* ans    = optional(firstRow(rs, evalLongText()));
        let* _      = rsClose(rs);
        return(ans)

    def getFlocLongTextSql(): String  = 
        String.unwords(
               "SELECT"
            :: "    t.short_text, t.long_text"
            :: "FROM"
            :: "    iflotx t"
            :: "WHERE"
            :: "    t.floc = ?;"
            :: Nil
        )

    def setFlocLongTextPStmt!(floc: String): PreparedStatementSetter[Unit] = 
        BasicDb/PreparedStatementSetter.putStringAt!(0,  floc)



        
}