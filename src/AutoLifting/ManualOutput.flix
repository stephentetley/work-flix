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

namespace AutoLifting/ManualOutput {

    use SheetIO.RowSetter;
    use SheetIO.SheetWriter;

    use AutoLifting/Base/Datatypes.{LiftingEquipment};
    use AutoLifting/Base.ReportMonad;


    /// Using LiftingEquipment makes this significantly neater than S4Equipment...

    pub def writeManualReport(rows: List[LiftingEquipment], path: System.FilePath): ReportMonad[Unit] =
        use SheetIO/SheetWriter.{runXlsx};
        AutoLifting/Base/ReportMonad.liftActionResult(_ -> runXlsx(manualReportWriter(rows), path))
        
    pub def manualReportWriter(rows: List[LiftingEquipment]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, return, createSheet, liftAction, allRowsWithHeaders};
        let* s1         = createSheet("Manual_Report");
        let* headers    = liftAction(_ -> getHeaders());
        allRowsWithHeaders(s1, headers, rows, setManualReportRow!)

    def getHeaders(): Array[String] & Impure = 
        [ "Change"
        , "AIB Reference"
        , "Equi Id"
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

    def setManualReportRow!(x: LiftingEquipment): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!,
                putOptionInt32At!, putOptionFloat64At!};
        use AssetLib/S4/Base/SheetIOUtils.{putS4DateAt!};
        let* _      = putStringAt!(0, "Child New");
        let* _      = putStringAt!(1, x.classifications.pliReference);
        let* _      = putStringAt!(3, x.attributes.description);
        let* _      = putStringAt!(4, x.attributes.category);
        let* _      = putStringAt!(5, x.attributes.functionalLocation);
        let* _      = putStringAt!(6, x.objectType);
        let* _      = putStringAt!(7, x.attributes.status);
        let* _      = putS4DateAt!(8, x.attributes.startupDate);
        let* _      = putStringAt!(9, x.attributes.manufacturer);
        let* _      = putStringAt!(10, x.attributes.model);
        let* _      = putStringAt!(11, x.attributes.partNumber);
        let* _      = putStringAt!(12, x.attributes.serialNumber);
        let* _      = putStringAt!(13, x.longText); 
        let* _      = putStringAt!(14, x.objectClass);
        let* _      = putStringAt!(15, x.classifications.pliReference);
        let* _      = putStringAt!(16, x.classifications.saiParentReference);
        let* _      = putOptionInt32At!(17, x.classifications.easting);
        let* _      = putOptionInt32At!(18, x.classifications.northing);
        let* _      = putStringAt!(19, x.classifications.locationOnSite);
        let* _      = putOptionFloat64At!(20, x.classifications.workingLoad);
        let* _      = putStringAt!(21, x.classifications.workingLoadUnits);
        let* _      = putStringAt!(22, x.classifications.statutoryReference);
        let* _      = putStringAt!(23, x.classifications.testCertNumber);

        return()

}