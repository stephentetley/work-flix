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

namespace AutoLifting/Build/ChildNew/WorkingLoadFields {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatement;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

    type alias WorkingLoadFields = 
        { valueFieldName: String
        , unitFieldName: String
        }

    pub def getWorkingLoadFields[r](pstmts: {selectWorkingLoad: PreparedStatement | r}, classification: String): DbMonad[WorkingLoadFields] = 
        use BasicDb/DbMonad.{flatMap, return, psExecuteQuery, firstRow, rsClose};
        let* rs     = psExecuteQuery(pstmts.selectWorkingLoad, BasicDb/PreparedStatementSetter.putStringAt!(0,  classification));
        let* x1     = firstRow(rs, evalWorkingLoad());
        let* _      = rsClose(rs);
        return(x1)

    pub def prepareWorkingLoadQuery(): DbMonad[PreparedStatement] = 
        let sql = String.unlines(
                "SELECT"
                :: "    t.working_load_field,"
                :: "    t.working_load_unit_field"
                :: "FROM lookup_working_load t"
                :: "WHERE "
                :: "    t.classification = ?"
                :: Nil
            );
        BasicDb/DbMonad.prepareStatement(sql)


    def evalWorkingLoad(): RowEvaluator[WorkingLoadFields] = 
        use BasicDb/RowEvaluator.{flatMap, return, getStringNamed};
        use BasicDb/RowEvaluator.{<&>, <*>};
        use String.{trim};
        ((x1, x2) ->
                { valueFieldName = x1
                , unitFieldName = x2
                })
            <&> getStringNamed("working_load_field")
            <*> getStringNamed("working_load_unit_field")

}
