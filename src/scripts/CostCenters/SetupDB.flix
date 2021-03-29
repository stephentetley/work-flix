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


namespace CostCenters/SetupDb {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatement;
    use BasicDb.PreparedStatementSetter;

    use SheetIO/CursorReader.POIRow;
    use SheetIO.NamedRowEvaluator;

    type alias CostCenter = 
        { reference: String
        , commonName: String
        , currentCostCenter: String
        , newCostCenter: String
        }


    pub def storeCostCenters(xlsxPath: System.FilePath): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, return, seqRight, execute, liftActionResult, liftAction, setAutoCommit, prepareStatement, psExecuteUpdate, commit};
        use BasicDb/DbMonadCursor.{foreach};
        use SheetIO/CursorReader.{newRowCursorAt, namedRowCursor};
        let* _          = setAutoCommit(false);
        let* _          = execute("DROP TABLE IF EXISTS cost_centers;");
        let* _          = execute(createCostCentersSql());
        let* stmt       = prepareStatement("INSERT INTO cost_centers (reference, common_name, current_cost_center, new_cost_center) VALUES(?, ?, ?, ?);");
        let* cursor     = liftActionResult(_ -> SheetIO/CursorReader.newRowCursorAt(xlsxPath, 0));
        let* cursor1    = liftAction(_ -> namedRowCursor(0, evalCostCenteRow(), cursor));
        let* _          = BasicDb/DbMonadCursor.foreach(writeRow(stmt), cursor1);
        let* _          = commit();
        return()

    def writeRow(stmt: PreparedStatement, x: Result[CostCenter, String]): DbMonad[Unit] = 
        use BasicDb/DbMonad.{return, throwError, seqRight};
        match x {
            case Err(msg) => throwError(msg)
            case Ok(a) => seqRight(BasicDb/DbMonad.psExecuteUpdate(stmt, costCenterRowSetter(a)), return())
        }

    def evalCostCenteRow(): NamedRowEvaluator[CostCenter] = 
        use SheetIO/NamedRowEvaluator.{<&>, <*>, getContentNamed, alt, return};
        ((x1, x2, x3, x4) -> 
            { reference         = x1
            , commonName        = x2
            , currentCostCenter = x3
            , newCostCenter     = x4
            })
            <&> getContentNamed("Reference")
            <*> getContentNamed("CommonName")
            <*> alt(getContentNamed("Current CC mapping"), return(""))
            <*> alt(getContentNamed("New Cost Centre mapping"), return(""))



    def costCenterRowSetter(x: CostCenter): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!};        
        let* _ = putStringAt!(0, x.reference);
        let* _ = putStringAt!(1, x.commonName);
        let* _ = putStringAt!(2, x.currentCostCenter);
        let* _ = putStringAt!(3, x.newCostCenter);
        return()


    def createCostCentersSql(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS cost_centers ("
                :: "reference           TEXT NOT NULL PRIMARY KEY,"
                :: "common_name         TEXT NOT NULL,"
                :: "current_cost_center TEXT NOT NULL,"
                :: "new_cost_center     TEXT NOT NULL"
                :: ")"
                :: Nil
        )

}
