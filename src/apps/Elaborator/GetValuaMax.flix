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

namespace Elaborator/GetValuaMax {
    
    use BasicDb.DbMonad;
    use BasicDb.PreparedStatement;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

    /// TODO - this would not work "interactively" if we have more-than-one update of
    /// the same equi x characteristic...
    /// ... needs to be a state monad.

    pub def getValuaEquiMax(equiId: String, characteristicName: String): DbMonad[Int32] = 
        use BasicDb/DbMonad.{flatMap, return, psExecuteCachedQuery, firstRow, rsClose, alt};
        let* rs     = psExecuteCachedQuery("ValuaEquiMax", setValuaEquiMaxParams!(equiId,  characteristicName));
        let* x1     = alt(firstRow(rs, evalValuaEquiMax()), return(0));
        let* _      = rsClose(rs);
        return(x1)

    pub def cacheValuaEquiMaxQuery(): DbMonad[Unit] = 
        let sql = String.unlines(
               "SELECT"
            :: "    max(t1.int_counter_value) AS counter_max"
            :: "FROM valuaequi t1"
            :: "WHERE "
            :: "    t1.equi = ?"
            :: "AND t1.char_id = ?"
            :: Nil
        );
        BasicDb/DbMonad.cachePreparedStatement("ValuaEquiMax", sql)

    def setValuaEquiMaxParams!(equiId: String, characteristicName: String): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!};
        let* _  = putStringAt!(0, equiId);
        let* _  = putStringAt!(1, characteristicName);
        return() 

    def evalValuaEquiMax(): RowEvaluator[Int32] = 
        BasicDb/RowEvaluator.getInt32Named("counter_max")


}
