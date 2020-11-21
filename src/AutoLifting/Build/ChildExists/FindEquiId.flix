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

/// Find S4 equiId via YWRef - may return zero-one-or-more results.
/// One is success, zero or more-then-one are failures

namespace AutoLifting/Build/ChildExists/FindEquiId {
    
    use BasicDb.DbMonad;
    use BasicDb.PreparedStatement;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

    /// find Equi

    pub def findEquiId[r](pstmts: {selectS4SiteCode: PreparedStatement | r}, ywRef: String): DbMonad[Option[String]] = 
        use BasicDb/DbMonad.{flatMap, return, psExecuteQuery, allRows, rsClose};
        let* rs     = psExecuteQuery(pstmts.selectS4SiteCode, BasicDb/PreparedStatementSetter.putStringAt!(0,  ywRef));
        let* xs     = allRows(rs, evalWorkingLoad());
        let* _      = rsClose(rs);
        match xs {
            case (s, n) :: Nil if n == 1    => return(Some(s))
            case _ => return(None)
        }
        

    pub def prepareFindEquiQuery(): DbMonad[PreparedStatement] = 
        let sql = String.unlines(
                "SELECT"
            :: "    v.equi AS [equi_id], COUNT(*) AS [equi_count]"
            :: "FROM"
            :: "    df_valuaequi v"
            :: "JOIN df_valuaequi v2 ON v.equi == v2.equi AND v2.char_id = 'AI2_AIB_REFERENCE' AND v2.char_value LIKE 'PLI%'"
            :: "WHERE v.char_id = 'STATUTORY_REFERENCE_NUMBER'"
            :: "AND v.char_value = ?"
            :: "GROUP BY v.char_value"
            :: Nil
            );
        BasicDb/DbMonad.prepareStatement(sql)


    def evalWorkingLoad(): RowEvaluator[(String, Int32)] = 
        use BasicDb/RowEvaluator.{flatMap, return, getStringNamed, getInt32Named};
        use BasicDb/RowEvaluator.{tuple2};
        tuple2(getStringNamed("equi_id"), getInt32Named("equi_count"))



 
}