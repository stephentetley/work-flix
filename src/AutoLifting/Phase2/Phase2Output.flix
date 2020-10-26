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
    use AutoLifting/Datatypes.{Phase2FinalWorkItem};

    use SheetIO.RowSetter;
    use SheetIO.SheetWriter;

    pub def writePhase2Report(rows: List[Phase2FinalWorkItem], path: System.FilePath): ReportMonad[Unit] =
        use SheetIO/SheetWriter.{runXlsx};
        AutoLifting/ReportMonad.liftActionResult(_ -> runXlsx(phase2ReportWriter(rows), path))
        
    def phase2ReportWriter(rows: List[Phase2FinalWorkItem]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, return, createSheet, liftAction, allRowsWithHeaders};
        let* s1         = createSheet("Phase_2");
        let* headers    = liftAction(_ -> getHeaders());
        allRowsWithHeaders(s1, headers, rows, setPhase2Row!)

    def getHeaders(): Array[String] & Impure = 
        [ "AIB Reference"        
        , "S4 Name"
        , "Equi Category"
        , "S4 Floc"
        , "Equi Object"
        , "Status"
        , "Start-up Date"
        , "Manufacturer"
        , "Model"
        , "Part Number"
        , "Serial Number"
        , "Long Text"
        , "Equi Class"
        , "Aib Reference 1"
        , "Aib Reference 2"
        , "Easting"
        , "Northing"
        , "Location On Site"
        , "Work Load"
        , "Work Load Units"
        , "Statutory Ref"
        , "Test Cert Num"
        ]

    def setPhase2Row!(x: Phase2FinalWorkItem): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!, putOptionStringAt!, 
                putInt32At!, putOptionFloat64At!};
        let* _      = putStringAt!(0, x.pliReference);
        let* _      = putStringAt!(1, x.s4EquiName);
        let* _      = putStringAt!(2, x.s4Category);
        let* _      = putStringAt!(3, x.s4Floc);
        let* _      = putStringAt!(4, x.s4Object);
        let* _      = putStringAt!(5, x.equiAttributes.assetStatus);
        let* _      = putS4DateAt!(6, x.equiAttributes.installedFrom);
        let* _      = putStringAt!(7, x.equiAttributes.manufacturer);
        let* _      = putStringAt!(8, x.equiAttributes.model);
        let* _      = putStringAt!(9, x.equiAttributes.partNumber);
        let* _      = putStringAt!(10, x.equiAttributes.serialNumber);
        let* _      = putOptionStringAt!(11, x.longText); 
        let* _      = putStringAt!(12, x.s4Class);       
        let* _      = putStringAt!(13, x.pliReference);
        let* _      = putStringAt!(14, x.parentSaiReference);
        let* _      = putInt32At!(15, x.charAttributes.easting);
        let* _      = putInt32At!(16, x.charAttributes.northing);
        let* _      = putStringAt!(17, x.charAttributes.locationOnSite);
        let* _      = putOptionFloat64At!(18, x.charAttributes.workLoad);
        let* _      = putStringAt!(19, x.charAttributes.workLoadUnits);
        let* _      = putStringAt!(20, x.charAttributes.statutoryRef);
        let* _      = putStringAt!(21, x.charAttributes.testCertNum);

        return()

    def putS4DateAt!(ix: Int32, dt: Time.LocalDate): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!, liftActionResult};
        let* s = liftActionResult(_ -> AutoLifting/Common.formatDateForS4(dt) as & Impure);
        putStringAt!(ix, s)

}