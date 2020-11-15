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

namespace AutoLifting/ChildNew/Classifications {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatement;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

    use AssetLib/S4/Simple/Datatypes.{Classification};
    use AutoLifting/ChildNew/AibAttributes.{AibAttributes};

    type alias WorkingLoad = 
        { loadField: String
        , unitField: String
        }

    pub def getLiftingClassifications[r](pstmts: {selectWorkingLoad: PreparedStatement | r}
                                        , classification: String
                                        , aibAttributes: AibAttributes): DbMonad[List[Classification]] = 
        use BasicDb/DbMonad.{flatMap, return};
        let c1  = {className = classification, charName = "UNICLASS_CODE", datatype = "Text", value = ""};
        let c2  = {className = classification, charName = "UNICLASS_DESC", datatype = "Text", value = ""};
        let cs3  = match String.length(aibAttributes.locationOnSite) {
            case x if x == 0 => Nil
            case x if x >= 0 => {className = classification, charName = "LOCATION_ON_SITE", datatype = "Text", value = "SEE LONG TEXT"} :: Nil
            case _           => {className = classification, charName = "LOCATION_ON_SITE", datatype = "Text", value = aibAttributes.locationOnSite} :: Nil
            };
        let* x1 = getWorkingLoad(pstmts, classification);
        let cs4 = match aibAttributes.workLoad {
            case None => Nil
            case Some(d) => 
                    {className = classification, charName = x1.loadField, datatype = "Decimal", value = Float64.toString(d)}
                ::  {className = classification, charName = x1.unitField, datatype = "Text", value = aibAttributes.workLoadUnits}
                :: Nil            
            };
        let cs5 = { 
            if (String.isEmpty(aibAttributes.statutoryRef))
                Nil
            else 
                {className = classification, charName = "STATUTORY_REFERENCE_NUMBER", datatype = "Text", value = aibAttributes.statutoryRef} :: Nil
            };
        let cs6 = { 
            if (String.isEmpty(aibAttributes.testCertNum))
                Nil
            else 
                {className = classification, charName = "TEST_CERT_NO", datatype = "Text", value = aibAttributes.testCertNum} :: Nil
            };
        return(c1 :: c2 :: cs3 ::: cs4 ::: cs5 ::: cs6)

    pub def getWorkingLoad[r](pstmts: {selectWorkingLoad: PreparedStatement | r}, classification: String): DbMonad[WorkingLoad] = 
        use BasicDb/DbMonad.{flatMap, return, psExecuteQuery, firstRow, rsClose};
        let* _      = BasicDb/DbMonad.liftAction(_ -> Console.printLine("Classification: ${classification}"));
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
