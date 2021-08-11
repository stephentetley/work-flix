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
        , weight: String
        , impellerType: String
        , insulationClass: String
        , ipRating: String
        , installedDesignHeadM: String
        , inletSizeMM: String
        , outletSizeMM: String
        , ratedSpeedRPM: String
        , flowLS: String
        , dateOfInstallation: String
        , locationOnSite: String
        , functionalLocation: String
        , memoLine: String
        }

    pub def loadPumpRows(src: XlsxSource): Result[List[PumpRow], String] & Impure = 
        SheetIO/Reader.readAllNamedRows(src, evalPumpRow())


    pub def evalPumpRow(): NamedRowEvaluator[PumpRow] = 
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed, getInt32Named, optional};
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
        <*> getTrimmedContentNamed("Weight")
        <*> getTrimmedContentNamed("Impeller type")
        <*> getTrimmedContentNamed("Insulation Class (\u00B0c)")
        <*> getTrimmedContentNamed("IP Rating")
        <*> getTrimmedContentNamed("Installed Design Head (m)")
        <*> getTrimmedContentNamed("Inlet Size (mm)")
        <*> getTrimmedContentNamed("Outlet Size (mm)")
        <*> getTrimmedContentNamed("Rated Speed (RPM)")
        <*> getTrimmedContentNamed("Flow (l/s)")
        <*> getTrimmedContentNamed("Date of installation")
        <*> getTrimmedContentNamed("Location on Site")
        <*> getTrimmedContentNamed("Location in Asset Hierarchy")
        <*> getTrimmedContentNamed("Memo Line")
        

}
