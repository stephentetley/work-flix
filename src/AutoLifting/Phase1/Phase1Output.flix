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

namespace AutoLifting/Phase1/Phase1Output {

    use AutoLifting.ReportMonad;
    use AutoLifting/Datatypes.{Phase1FinalWorkItem};

    use SheetIO.RowSetter;
    use SheetIO.SheetWriter;

    pub def writePhase1Report(rows: List[Phase1FinalWorkItem], path: System.FilePath): ReportMonad[Unit] =
        use SheetIO/SheetWriter.{runXlsx};
        AutoLifting/ReportMonad.liftActionResult(_ -> runXlsx(phase1ReportWriter(rows), path))
        
    def phase1ReportWriter(rows: List[Phase1FinalWorkItem]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, return, createSheet, liftAction, allRowsWithHeaders};
        let* s1         = createSheet("Phase_1");
        let* headers    = liftAction(_ -> getHeaders());
        allRowsWithHeaders(s1, headers, rows, setPhase1Row!)

    def getHeaders(): Array[String] & Impure = 
        [ "Reference"
        , "Parent Reference"
        , "S4 Name"
        , "S4 Floc"
        , "Equi Category"
        , "Equi Object"
        , "Equi Class"
        ]


    
    def setPhase1Row!(x: Phase1FinalWorkItem): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!};
        let* _      = putStringAt!(0, x.pliReference);
        let* _      = putStringAt!(1, x.parentSaiReference);
        let* _      = putStringAt!(2, x.s4EquiName);
        let* _      = putStringAt!(3, x.s4Floc);
        let* _      = putStringAt!(4, x.s4TyInfo.category);
        let* _      = putStringAt!(5, x.s4TyInfo.s4Object);
        let* _      = putStringAt!(6, x.s4TyInfo.s4Class);
        return()

}