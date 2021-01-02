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

namespace AutoLifting/Build/ChildNew/LiftingTypeMapping {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatement;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

    use AutoLifting/Base/Datatypes.{S4TypeInfo, FixedOrPortable};

    pub def getTypeMapping[r](pstmts: { selectTyDistinguished: PreparedStatement, selectTyOrdinary: PreparedStatement | r}
                          , equiName: String
                          , equiType: String): DbMonad[S4TypeInfo] = 
        use BasicDb/DbMonad.{flatMap, return};
        let* ty1    = getDistinguisedTypeMapping(pstmts.selectTyDistinguished, equiName, equiType);
        match ty1 { 
            case Some(ans) => return(ans)
            case None => getOrdinaryTypeMapping(pstmts.selectTyOrdinary, equiType)
        }

    /// Distinguished Mapping

    def getDistinguisedTypeMapping(pstmt: PreparedStatement, equiName: String, equiType: String): DbMonad[Option[S4TypeInfo]] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult, psExecuteQuery, allRows, rsClose};
        let* rs     = psExecuteQuery(pstmt, BasicDb/PreparedStatementSetter.putStringAt!(0,  equiType));
        let* xs     = allRows(rs, evalDistinguishedAnswer());
        let* _      = rsClose(rs);
        let x1      = List.findMap(xy -> if (String.contains(equiName, fst(xy))) Some(snd(xy)) else None, xs);
        return(x1)

    pub def prepareDistinguishedQuery(): DbMonad[PreparedStatement] = 
        let sql = String.unlines(
                "SELECT "
                :: "    t.name_contains,"
                :: "    t.category,"
                :: "    t.object_type,"
                :: "    t.object_class,"
                :: "    t.fixed_or_portable"
                :: "FROM"
                :: "    lookup_lifting_type t"
                :: "WHERE"
                :: "    t.equi_type = ?"
                :: "AND t.name_contains is NOT NULL"
                :: Nil
            );
        BasicDb/DbMonad.prepareStatement(sql)

    def evalDistinguishedAnswer(): RowEvaluator[(String, S4TypeInfo)] = 
        use BasicDb/RowEvaluator.{getStringNamed};
        use BasicDb/RowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5) ->
                (x1, 
                    { category      = x2
                    , s4Object      = x3
                    , s4Class       = x4
                    , fixedOrPortable   = x5
                    }))
            <&> getStringNamed("name_contains")
            <*> getStringNamed("category")
            <*> getStringNamed("object_type")
            <*> getStringNamed("object_class")
            <*> getFixedOrPortable("fixed_or_portable")



    /// Ordinary Mapping

    def getOrdinaryTypeMapping(pstmt: PreparedStatement, equiType: String): DbMonad[S4TypeInfo] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult, psExecuteQuery, firstRow, rsClose};
        let* rs     = psExecuteQuery(pstmt, BasicDb/PreparedStatementSetter.putStringAt!(0,  equiType));
        let* x1     = firstRow(rs, evalOrdinaryAnswer());
        let* _      = rsClose(rs);
        return(x1)

    pub def prepareOrdinaryQuery(): DbMonad[PreparedStatement] = 
        let sql = String.unlines(
                "SELECT "
                :: "    t.category,"
                :: "    t.object_type,"
                :: "    t.object_class,"
                :: "    t.fixed_or_portable"
                :: "FROM"
                :: "    lookup_lifting_type t"
                :: "WHERE"
                :: "    t.equi_type = ?"
                :: "AND t.name_contains is NULL"
                :: Nil
            );
        BasicDb/DbMonad.prepareStatement(sql)

    def evalOrdinaryAnswer(): RowEvaluator[S4TypeInfo] = 
        use BasicDb/RowEvaluator.{getStringNamed};
        use BasicDb/RowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4) ->
                { category      = x1
                , s4Object      = x2
                , s4Class       = x3
                , fixedOrPortable   = x4
                })
            <&> getStringNamed("category")
            <*> getStringNamed("object_type")
            <*> getStringNamed("object_class")
            <*> getFixedOrPortable("fixed_or_portable")

    def getFixedOrPortable(label: String): RowEvaluator[FixedOrPortable] = 
        use BasicDb/RowEvaluator.{flatMap, return, liftOption, getStringNamed, liftAction};
        let* s      = getStringNamed(label);        
        let a1: Option[FixedOrPortable]     = FromString.fromString(s);
        let* ans    = liftOption(a1, "getFixedOrPortable('${label}') '${s}'");
        return(ans)

    /// def decodeFoP(s: String): Option[FixedOrPortable] = 
    ///     use AutoLifting/Base/Datatypes.FixedOrPortable.{Fixed, Portable};
    ///     match String.toUpperCase(String.trim(s)) {
    ///         case "FIXED" => Some(Fixed)
    ///         case "PORTABLE" => Some(Portable)
    ///         case _ => None
    ///     }

}
