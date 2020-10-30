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

namespace AutoLifting/ExistingObject/GetClassifications {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatement;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

    use AutoLifting/ExistingObject/Datatypes.{Classification};

    pub def prepareClassificationsQuery(): DbMonad[PreparedStatement] = 
        BasicDb/DbMonad.prepareStatement(getClassificationsSql())

    pub def getClassifications(pstmt: PreparedStatement, equiId: String): DbMonad[List[Classification]] = 
        use BasicDb/DbMonad.{flatMap, return, psExecuteQuery, allRows, rsClose};
        let* rs     = psExecuteQuery(pstmt, setClassificationPStmt!(equiId));
        let* xs     = allRows(rs, evalClassification());
        let* _      = rsClose(rs);
        return(xs)

    def getClassificationsSql(): String  = 
        String.unwords(
               "SELECT"
            :: "    c.equi, c.class_name, cfm.charname, cfcd.datatype, v.value_description, v.value_from"
            :: "FROM"
            :: "    class_equi c"
            :: "INNER JOIN  cf_members cfm      ON c.class_name = cfm.classname"
            :: "JOIN        cf_char_defs cfcd   ON cfm.charname = cfcd.charname"
            :: "JOIN        valua_equi v        ON c.equi = v.equi AND cfm.charname = v.char_id"
            :: "WHERE"
            :: "    c.equi = ?"
            :: "AND cfm.classtype = 'equi'"
            :: "AND cfcd.classtype = 'equi'"
            :: "ORDER BY c.class_name;"
            :: Nil
        )

    def setClassificationPStmt!(equiId: String): PreparedStatementSetter[Unit] = 
        BasicDb/PreparedStatementSetter.putStringAt!(0,  equiId)

    def evalClassification(): RowEvaluator[Classification] = 
        use BasicDb/RowEvaluator.{flatMap, return, getStringNamed, getFloat64Named};
        let* classname  = getStringNamed("class_name");
        let* charname   = getStringNamed("charname");
        let* datatype   = getStringNamed("datatype");
        let* value      = getValue(datatype);
        return( 
            { className = classname
            , charName  = charname
            , datatype  = datatype
            , value     = value
            })

    def getValue(datatype: String): RowEvaluator[String] =
        use BasicDb/RowEvaluator.{map, getStringNamed, getFloat64Named};
        if (datatype == "Int" || datatype == "Decimal")
            map(Float64.toString, getFloat64Named("value_from"))
        else
            getStringNamed("value_description")

        
}