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

namespace AutoLifting/ReportMain {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatement;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

    use AutoLifting/Base/Datatypes.{LiftingEquipment};
    use AutoLifting/Base.ReportMonad;
    use AutoLifting/Build/ChildNew.ChildNewPreparedStatements;


    pub def makeReport(description: String, uxlTemplate: System.FilePath, manualOut: System.FilePath, uxlOut: System.FilePath): ReportMonad[Unit] = 
        use AutoLifting/Base/ReportMonad.{return, flatMap, liftActionResult, liftDbMonad, mapM};
        use AutoLifting/Base/LiftingEquipmentToSimple.{translateLiftingEquipment};
        use AutoLifting/Build/ChildNew.{cachePreparedStatements => childNewPreparedStatements};
        use AutoLifting/ManualOutput.{writeManualReport};
        use AssetLib/S4/Simple/EmitUxl.{outputUxl};
        let* childPsCache   = liftDbMonad(_ -> childNewPreparedStatements());
        let* xs             = liftDbMonad(_ -> getWorklist());
        let news            = List.filter(x -> x.change == "Child New", xs);
        let* newEquis       = mapM(x -> buildNew(childPsCache, x.reference, x.assetName), news);
        let* _              = writeManualReport(newEquis, manualOut);
        let newEquis2       = List.map(translateLiftingEquipment, newEquis);    
        let* _              = liftActionResult(_ -> outputUxl(description, Nil, newEquis2, uxlTemplate, uxlOut));
        return()



    pub def buildNew(pstmts: ChildNewPreparedStatements, reference: String, commonName: String): ReportMonad[LiftingEquipment] = 
        use AutoLifting/Base/ReportMonad.{return, flatMap, genEquiId, liftDbMonad}; 
        use AutoLifting/Build/ChildNew.{childNew};
        let* equiId     = genEquiId();
        let* ans        = liftDbMonad(_ -> childNew(pstmts, reference, commonName, equiId));
        return(ans)    




    /// Read Worklist

    type alias WorkItem = 
        { reference: String
        , assetName: String
        , change: String
        }

    pub def getWorklist(): DbMonad[List[WorkItem]] = 
        use BasicDb/DbMonad.{flatMap, return, psExecuteQuery, allRows, rsClose};
        let* pstmt  = prepareWorklistQuery();
        let* rs     = psExecuteQuery(pstmt, BasicDb/PreparedStatementSetter.return());
        let* x1     = allRows(rs, evalWorkItem());
        let* _      = rsClose(rs);
        return(x1)

    pub def prepareWorklistQuery(): DbMonad[PreparedStatement] = 
        let sql = String.unlines(
                "SELECT"
                :: "    t.reference,"
                :: "    t.asset_name,"
                :: "    t.change"
                :: "FROM" 
                :: "    wl_worklist t"
                :: "ORDER BY"
                :: "    t.orderkey"
                :: Nil
            );
        BasicDb/DbMonad.prepareStatement(sql)


    def evalWorkItem(): RowEvaluator[WorkItem] = 
        use BasicDb/RowEvaluator.{flatMap, return, getStringNamed};
        use BasicDb/RowEvaluator.{<&>, <*>};
        use String.{trim};
        ((x1, x2, x3) ->
                { reference = x1
                , assetName = x2
                , change    = x3
                })
            <&> getStringNamed("reference")
            <*> getStringNamed("asset_name")
            <*> getStringNamed("change")

}