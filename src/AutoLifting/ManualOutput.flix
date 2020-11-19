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

    use AssetLib/S4/Simple/Datatypes.{S4Equipment};
    use AutoLifting/Common.ReportMonad;


    /// Note - this would be significantly neater if we were using a tighter immediate form
    /// than S4Equipment...

    pub def writeManualReport(rows: List[S4Equipment], path: System.FilePath): ReportMonad[Unit] =
        use SheetIO/SheetWriter.{runXlsx};
        AutoLifting/Common/ReportMonad.liftActionResult(_ -> runXlsx(manualReportWriter(rows), path))
        
    pub def manualReportWriter(rows: List[S4Equipment]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, return, createSheet, liftAction, allRowsWithHeaders};
        let* s1         = createSheet("Manual_Report");
        let* headers    = liftAction(_ -> getHeaders());
        allRowsWithHeaders(s1, headers, rows, setManualReportRow!)

    def getHeaders(): Array[String] & Impure = 
        [ "Change"
        , "AIB Reference"
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

    def setManualReportRow!(x: S4Equipment): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!,
                putOptionInt32At!, putOptionFloat64At!};
        use AssetLib/S4/Base/SheetIOUtils.{putS4DateAt!};
        let* _      = putStringAt!(0, "Child New");
        let* _      = putStringAt!(1, x.pliNumber());
        let* _      = putStringAt!(2, x.attributes.description);
        let* _      = putStringAt!(3, x.attributes.category);
        let* _      = putStringAt!(4, x.attributes.functionalLocation);
        let* _      = putStringAt!(5, x.attributes.objectType);
        let* _      = putStringAt!(6, x.attributes.status);
        let* _      = putS4DateAt!(7, x.attributes.startupDate);
        let* _      = putStringAt!(8, x.attributes.manufacturer);
        let* _      = putStringAt!(9, x.attributes.model);
        let* _      = putStringAt!(10, x.attributes.partNumber);
        let* _      = putStringAt!(11, x.attributes.serialNumber);
        let* _      = putStringAt!(12, x.equipmentLongText()); 
        let* _      = putStringAt!(13, x.equipmentClass());
        let* _      = putStringAt!(14, x.pliNumber());
        let* _      = putStringAt!(15, x.saiNumber());
        let* _      = putOptionInt32At!(16, x.easting());
        let* _      = putOptionInt32At!(17, x.northing());
        let* _      = putStringAt!(18, x.locationOnSite());
        let* _      = putOptionFloat64At!(19, x.workLoad());
        let* _      = putStringAt!(20, x.workLoadUnits());
        let* _      = putStringAt!(21, x.statutoryReferenceNumber());
        let* _      = putStringAt!(22, x.testCertNo());

        return()

    def equipmentLongText(x: S4Equipment): String = match x.longText {
        case Some(x1) => x1.longText
        case None => ""
    }


    def equipmentClass(x: S4Equipment): String = 
        let fn = c -> String.startsWith(c.className, x.attributes.objectType);
        match List.find(fn, x.classifications) {
            case Some(x1) => x1.className
            case None => ""
        }

    def pliNumber(x: S4Equipment): String = 
        let fn = c -> String.startsWith(c.value, "PLI") && c.charName == "AI2_AIB_REFERENCE";
        match List.find(fn, x.classifications) {
            case Some(x1) => x1.value
            case None => ""
        }

    def saiNumber(x: S4Equipment): String = 
        let fn = c -> !String.startsWith(c.value, "PLI") && c.charName == "AI2_AIB_REFERENCE";
        match List.find(fn, x.classifications) {
            case Some(x1) => x1.value
            case None => ""
        }

    def easting(x: S4Equipment): Option[Int32] = 
        let fn = c -> c.className == "EAST_NORTH" && c.charName == "EASTING";
        match List.find(fn, x.classifications) {
            case Some(x1) => Result.toOption(Int32.fromString(x1.value))
            case None => None
        }

    def northing(x: S4Equipment): Option[Int32] = 
        let fn = c -> c.className == "EAST_NORTH" && c.charName == "NORTHING";
        match List.find(fn, x.classifications) {
            case Some(x1) => Result.toOption(Int32.fromString(x1.value))
            case None => None
        }

    def locationOnSite(x: S4Equipment): String = 
        let fn = c -> String.startsWith(c.className, x.attributes.objectType) && c.charName == "LOCATION_ON_SITE";
        match List.find(fn, x.classifications) {
            case Some(x1) => x1.value
            case None => ""
        }

    def workLoad(x: S4Equipment): Option[Float64] = 
        let fn = c -> String.startsWith(c.className, x.attributes.objectType) && (String.endsWith(c.charName, "_LOAD") || String.endsWith(c.charName, "_RATING"));
        match List.find(fn, x.classifications) {
            case Some(x1) => Result.toOption(Float64.fromString(x1.value))
            case None => None
        }

    def workLoadUnits(x: S4Equipment): String = 
        let fn = c -> String.startsWith(c.className, x.attributes.objectType) && String.endsWith(c.charName, "_UNITS");
        match List.find(fn, x.classifications) {
            case Some(x1) => x1.value
            case None => ""
        }

    def statutoryReferenceNumber(x: S4Equipment): String = 
        let fn = c -> String.startsWith(c.className, x.attributes.objectType) && c.charName == "STATUTORY_REFERENCE_NUMBER";
        match List.find(fn, x.classifications) {
            case Some(x1) => x1.value
            case None => ""
        }

    def testCertNo(x: S4Equipment): String = 
        let fn = c -> String.startsWith(c.className, x.attributes.objectType) && c.charName == "TEST_CERT_NO";
        match List.find(fn, x.classifications) {
            case Some(x1) => x1.value
            case None => ""
        }


}