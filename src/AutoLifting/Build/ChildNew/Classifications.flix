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

namespace AutoLifting/Build/ChildNew/Classifications {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatement;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

    use AssetLib/S4/Simple.Classifications;
    use AutoLifting/Build/ChildNew/AibAttributes.{AibAttributes};

    type alias WorkingLoad = 
        { loadField: String
        , unitField: String
        }

    pub def getLiftingClassifications[r](pstmts: {selectWorkingLoad: PreparedStatement | r}
                                        , classification: String
                                        , aibAttributes: AibAttributes): DbMonad[Classifications] = 
        use BasicDb/DbMonad.{flatMap, return};
        use AssetLib/S4/Simple/Classifications.{empty, singleton, append, concat, whenTrue, whenSome, 
            uniclassCode, uniclassDesc, locationOnSite, statutoryReferenceNumber, testCertNo};
        let c1  = uniclassCode(classification);
        let c2  = uniclassDesc(classification);
        let c3  = match String.length(aibAttributes.locationOnSite) {
            case x if x == 0    => empty()
            case x if x >= 30   => locationOnSite(classification, "SEE LONG TEXT")
            case _              => locationOnSite(classification, aibAttributes.locationOnSite)
            };
        let* x1 = getWorkingLoad(pstmts, classification);
        let c4 = 
            whenSome(aibAttributes.workLoad, 
                d -> singleton({className = classification, charName = x1.loadField, datatype = "Decimal", value = Float64.toString(d)})
                        `append` singleton({className = classification, charName = x1.unitField, datatype = "Text", value = aibAttributes.workLoadUnits})
            );
        let c5 = whenTrue(!String.isEmpty(aibAttributes.statutoryRef), statutoryReferenceNumber(classification, aibAttributes.statutoryRef));
        let c6 = whenTrue(!String.isEmpty(aibAttributes.testCertNum), testCertNo(classification, aibAttributes.testCertNum));
        return(c1 `append` c2 `append` c3 `append` c4 `append` c5 `append` c6)


    pub def getWorkingLoad[r](pstmts: {selectWorkingLoad: PreparedStatement | r}, classification: String): DbMonad[WorkingLoad] = 
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


    def evalWorkingLoad(): RowEvaluator[WorkingLoad] = 
        use BasicDb/RowEvaluator.{flatMap, return, getStringNamed};
        use BasicDb/RowEvaluator.{<&>, <*>};
        use String.{trim};
        ((x1, x2) ->
                { loadField = x1
                , unitField = x2
                })
            <&> getStringNamed("working_load_field")
            <*> getStringNamed("working_load_unit_field")

}
