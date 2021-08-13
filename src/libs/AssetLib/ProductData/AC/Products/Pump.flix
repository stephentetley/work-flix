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

namespace AssetLib/ProductData/AC/Products/Pump {

    use SheetIO.NamedRowEvaluator;
    use SheetIO/Reader.XlsxSource;

    use AssetLib/S4Lite/Datatypes.{UxlSource, SLEquipment, SLEquiCharacteristic, SLDatatype};
    use AssetLib/S4Lite/Datatypes.SLDatatype.{Character, NumericInt, NumericFloat};
    use AssetLib/ProductData/Base/Classification.{ObjectClassification};

    /// Base is PUMP (category "M") / PUMS (category "E")
    /// PUMPDI | ...

    
    type alias PumpRow = 
        { description: String
        , className: String
        , pandiTag: String
        , manufacturer: String
        , modelNumber: String
        , specificModel: String
        , manufSerialNumber: String
        , weight: Option[Float64]
        , impellerType: String
        , insulationClass: String
        , ipRating: String
        , installedDesignHeadM: Option[Float64]
        , inletSizeMM: Option[Int32]
        , outletSizeMM: Option[Int32]
        , ratedSpeedRPM: Option[Int32]
        , flowLS: Option[Float64]
        , dateOfInstallation: Option[Time.LocalDate]
        , locationOnSite: String
        , functionalLocation: String
        , memoLine: String
        }

    pub def loadPumpRows(src: XlsxSource): Result[List[PumpRow], String] & Impure = 
        SheetIO/Reader.readAllNamedRows(src, evalPumpRow())


    pub def evalPumpRow(): NamedRowEvaluator[PumpRow] = 
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed, 
            getInt32Named, getFloat64Named, getLocalDateNamed, optional};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20) -> 
            { description           = x1
            , className             = x2
            , pandiTag              = x3
            , manufacturer          = x4
            , modelNumber           = x5
            , specificModel         = x6
            , manufSerialNumber     = x7
            , weight                = x8
            , impellerType          = x9
            , insulationClass       = x10
            , ipRating              = x11
            , installedDesignHeadM  = x12
            , inletSizeMM           = x13
            , outletSizeMM          = x14
            , ratedSpeedRPM         = x15
            , flowLS                = x16
            , dateOfInstallation    = x17
            , locationOnSite        = x18
            , functionalLocation    = x19
            , memoLine              = x20
            })
        <&> getTrimmedContentNamed("Description")
        <*> getTrimmedContentNamed("Class Name")
        <*> getTrimmedContentNamed("Tag")
        <*> getTrimmedContentNamed("Manufacturer")
        <*> getTrimmedContentNamed("Model Number")
        <*> getTrimmedContentNamed("Specific Model")
        <*> getTrimmedContentNamed("Manufacturer's serial number")
        <*> optional(getFloat64Named("Weight"))
        <*> getTrimmedContentNamed("Impeller type")
        <*> getTrimmedContentNamed("Insulation Class (\u00B0c)")
        <*> getTrimmedContentNamed("IP Rating")
        <*> optional(getFloat64Named("Installed Design Head (m)"))
        <*> optional(getInt32Named("Inlet Size (mm)"))
        <*> optional(getInt32Named("Outlet Size (mm)"))
        <*> optional(getInt32Named("Rated Speed (RPM)"))
        <*> optional(getFloat64Named("Flow (l/s)"))
        <*> optional(getLocalDateNamed("Date of installation"))
        <*> getTrimmedContentNamed("Location on Site")
        <*> getTrimmedContentNamed("Location in Asset Hierarchy")
        <*> getTrimmedContentNamed("Memo Line")
        


    pub def pumpClassification(x: String): ObjectClassification = match String.toUpperCase(x) { 
        case "CENTRIFUGAL" => { category = "M", objectType = "PUMP", classType = "PUMPCE"}
        case _  => { category = "M", objectType = "PUMP", classType = "PUMPMISC"}
    }




    /// Translation
    pub def pumpToSLEquipment(params: {equiId: String, today: Time.LocalDate, funcloc: String}, x: PumpRow): SLEquipment = 
        let i32None: Option[Int32] = None;
        let classification = pumpClassification(x.className);
        { equiId                = params.equiId
        , category              = classification.category
        , description           = x.description
        , validFrom             = params.today
        , objectType            = classification.objectType
        , weightKg              = x.weight
        , startupDate           = params.today      // Should be x.dateOfInstallation
        , manufacturer          = x.manufacturer
        , model                 = x.modelNumber
        , partNumber            = x.specificModel
        , serialNumber          = x.manufSerialNumber
        , functionalLocation    = params.funcloc
        , superOrdinateEqui     = ""
        , position              = i32None
        , techIdentNo           = x.pandiTag
        , status                = "OPER"
        }

}
