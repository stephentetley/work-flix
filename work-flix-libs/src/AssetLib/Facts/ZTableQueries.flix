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

/*
namespace AssetLib/Facts/ZTableQueries {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;

    use AssetLib/Base/S4.{Floc};

    /// Query Site Mapping...

    pub def cacheFlocdesQuery(tableName: String): DbMonad[Unit] = 
        let sql = String.unlines(
                "SELECT"
                :: "    t.description"
                :: "FROM ${tableName} t"
                :: "WHERE "
                :: "    t.object_type = ?"
                :: Nil
            );
        BasicDb/DbMonad.cachePreparedStatement("getFlocDescription", sql)


    pub def getFlocDescription(floc: Floc): DbMonad[Option[String]] = 
        use BasicDb/DbMonad.{flatMap, point, psExecuteCachedQuery, firstRow, optional, liftOption, rsClose};
        let* suffix = liftOption(AssetLib/Base/S4/Floc.getSuffix(floc), "getFlocDescription - invalid floc - ${floc}");
        let* rs     = psExecuteCachedQuery("getFlocDescription", BasicDb/PreparedStatementSetter.putStringAt!(0,  suffix));
        let* x1     = optional(firstRow(rs, BasicDb/RowEvaluator.getStringNamed("description")));        
        let* _      = rsClose(rs);
        point(x1)

}
*/
