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

namespace AutoLifting/Phase2/Phase2Output {

    use AutoLifting.ReportMonad;
    use AutoLifting/Datatypes.{Phase2WorkItem3};

    use SheetIO.RowSetter;
    use SheetIO.SheetWriter;

    pub def writePhase2Report(rows: List[Phase2WorkItem3], path: System.FilePath): ReportMonad[Unit] =
        use SheetIO/SheetWriter.{runXlsx};
        AutoLifting/ReportMonad.liftActionResult(_ -> runXlsx(phase2ReportWriter(rows), path))
        
    def phase2ReportWriter(rows: List[Phase2WorkItem3]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, return, createSheet, liftAction, allRowsWithHeaders};
        let* s1         = createSheet("Phase_2");
        let* headers    = liftAction(_ -> getHeaders());
        allRowsWithHeaders(s1, headers, rows, setPhase2Row!)

    def getHeaders(): Array[String] & Impure = 
        [ "Reference"
        , "Parent Reference"
        , "S4 Name"
        , "S4 Floc"
        , "Equi Category"
        , "Equi Object"
        , "Equi Class"
        , "Start-up Date"
        , "Long Text"
        ]

        ///  pliReference: String
        /// , parentSaiReference: String
        /// , s4EquiName: String
        /// , s4Floc: String
        /// , s4Category: String 
        /// , s4Object: String
        /// , s4Class: String
        /// , installedFrom: Time.LocalDate
        /// , manufacturer: String
        /// , model: String
        /// , partNumber: String
        /// , serialNumber: String
        /// , longText: Option[String]
        /// , easting: Int32
        /// , northing: Int32
        /// , workLoad: Option[Float64]
        /// , workLoadUnits: String
        /// , statutoryRef: String
        /// , testCertNum: String

    
    def setPhase2Row!(x: Phase2WorkItem3): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!};
        let* _      = putStringAt!(0, x.pliReference);
        let* _      = putStringAt!(1, x.parentSaiReference);
        let* _      = putStringAt!(2, x.s4EquiName);
        let* _      = putStringAt!(3, x.s4Floc);
        let* _      = putStringAt!(4, x.s4Category);
        let* _      = putStringAt!(5, x.s4Object);
        let* _      = putStringAt!(6, x.s4Class);        
        let* _      = putS4DateAt!(7, x.installedFrom);
        return()

    def putS4DateAt!(ix: Int32, dt: Time.LocalDate): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!, liftActionResult};
        let* s = liftActionResult(_ -> AutoLifting/Common.formatDateForS4(dt) as & Impure);
        putStringAt!(ix, s)

}