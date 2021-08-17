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

namespace AssetLib/ProductData/AC/EquipmentCommon {

    use SheetIO.NamedRowEvaluator;
    use SheetIO/Reader.XlsxSource;

    use AssetLib/S4Lite/Datatypes.{UxlSource, SLEquipment, SLEquiCharacteristic, SLDatatype};
    use AssetLib/S4Lite/Datatypes.SLDatatype.{Character, NumericInt, NumericFloat};
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3, 
        ConditionGrade, LoadingFactor, PerformanceGrade, SurveyYear, 
        PumpFlow, DutyHead, ImpellerType};
    use AssetLib/GenS4.GenEquiMonad;
    use AssetLib/GenS4/GenEquiMonad.EquiRef;
    use AssetLib/GenS4/GenEquiMonad.EquiRef.{EquiRef};
    use AssetLib/ProductData/Base/Classification.{ObjectClassification};


    
    type alias EquipmentCommon = 
        { description: String
        , className: String
        , category: String
        , objectType: String
        , pandiTag: String
        , comment: String
        , manufacturer: String
        , modelNumber: String
        , specificModel: String
        , manufSerialNumber: String
        , weight: Option[Float64]
        , dateOfInstallation: Option[Time.LocalDate]
        , locationOnSite: String
        , locationInHierarchy: String
        , memoLine: String
        }



    /// An equi-specific pasrer must decode className to supply category and objectType.
    pub def evalEquipmentCommon(category: String, objectType: String): NamedRowEvaluator[EquipmentCommon] = 
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed, 
            getInt32Named, getFloat64Named, getLocalDateNamed, optional};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13) -> 
            { description           = x1
            , className             = x2
            , category              = category
            , objectType            = objectType
            , pandiTag              = x3
            , comment               = x4
            , manufacturer          = x5
            , modelNumber           = x6
            , specificModel         = x7
            , manufSerialNumber     = x8
            , weight                = x9
            , dateOfInstallation    = x10
            , locationOnSite        = x11
            , locationInHierarchy   = x12
            , memoLine              = x13
            })
        <&> getTrimmedContentNamed("Description")
        <*> getTrimmedContentNamed("Class Name")
        <*> getTrimmedContentNamed("Tag")
        <*> getTrimmedContentNamed("Comment")
        <*> getTrimmedContentNamed("Manufacturer")
        <*> getTrimmedContentNamed("Model Number")
        <*> getTrimmedContentNamed("Specific Model")
        <*> getTrimmedContentNamed("Manufacturer's serial number")
        <*> optional(getFloat64Named("Weight"))
        <*> optional(getLocalDateNamed("Date of installation"))
        <*> getTrimmedContentNamed("Location on Site")
        <*> getTrimmedContentNamed("Location in Asset Hierarchy")
        <*> getTrimmedContentNamed("Memo Line")
        


    pub def genEquipment(x: EquipmentCommon): GenEquiMonad[EquiRef] = 
        AssetLib/GenS4/GenEquiMonad.genEqui((x1, x2) -> equipmentCommonToSLEquipment({equiId = x1, today = x2}, x))

    /// Translation
    pub def equipmentCommonToSLEquipment(params: {equiId: String, today: Time.LocalDate}, x: EquipmentCommon): SLEquipment = 
        let i32None: Option[Int32] = None;
        let defaultDate = Time/LocalDate.new({dayOfMonth = 1, month = 1, year = 1970});
        { equiId                = params.equiId
        , category              = x.category
        , description           = x.description
        , validFrom             = params.today
        , objectType            = x.objectType
        , weightKg              = x.weight
        , startupDate           = Option.getWithDefault(x.dateOfInstallation, defaultDate)
        , manufacturer          = x.manufacturer
        , model                 = x.modelNumber
        , partNumber            = x.specificModel
        , serialNumber          = x.manufSerialNumber
        , functionalLocation    = x.locationInHierarchy
        , superOrdinateEqui     = ""
        , position              = i32None
        , techIdentNo           = x.pandiTag
        , status                = "OPER"
        }


}
