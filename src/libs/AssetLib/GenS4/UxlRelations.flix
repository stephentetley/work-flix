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


namespace AssetLib/GenS4/UxlRelations {

    use AssetLib/FileIO/S4/UxlFile/Datatypes.{FunctionalLocationData, FlMultilingualText, 
        FlClassification, EquipmentData, EqMultilingualText, EqClassification};

    /// Arity 7
    pub rel FlocDatum(funcloc: String, 
                        description: String, 
                        strIndicator: String, 
                        objectType: String, 
                        startupDate: Time.LocalDate, 
                        equipInstall: Bool, 
                        userStatus: String)

    pub rel FlocLongText(funcloc: String, 
                        description: String, 
                        longText: String)

    /// Arity 4
    pub rel FlocCharacteristic(floc: String, className: String, charName: String, charValue: String)

    /// Arity 16
    pub rel EquiDatum(equiId: String, 
                        category: String,              /// e.g "M", "I", "E"
                        description: String,
                        validFrom: Time.LocalDate,
                        objectType: String,
                        weightKg: Option[Float64],
                        startupDate: Time.LocalDate,
                        manufacturer: String,
                        model: String,
                        partNumber: String,
                        serialNumber: String,
                        functionalLocation: String,
                        superOrdinateEqui: String, 
                        position: Option[Int32],
                        techIdentNo: String,
                        status: String)

    pub rel EquiLongText(equiId: String, 
                        description: String, 
                        longText: String)


    /// Arity 4
    pub rel EquiCharacteristic(equiId: String, className: String, charName: String, charValue: String)



    /// To Uxl...
    pub def toFunctionalLocationData(src: #{FlocDatum | r}): List[FunctionalLocationData] = 
        let buildStep = (x, ac) -> flocDatumToUxl(x) :: ac;
        let sortStep = (x, y) -> Order.compare(x.functionalLocation, y.functionalLocation) |> Order.toInt;
        let xs = { fold FlocDatum Nil buildStep src };
        List.sortWith(sortStep, xs)


    def flocDatumToUxl(x: (String, String, String, String, 
                            Time.LocalDate, Bool, String)): FunctionalLocationData = 
        let (x1, x2, x3, x4, x5, x6, x7) = x;
        { functionalLocation    = x1
        , maskedFuncLoc         = x1
        , description           = x2
        , functLocCat           = Option.getWithDefault(Option.map(AssetLib/Base/S4/Floc.level, AssetLib/Base/S4/Floc.new(x1)), 0)
        , strIndicator          = x3
        , objectType            = x4
        , startupDate           = x5
        , maintPlant            = 2100
        , companyCode           = 2100
        , coArea                = 1000
        , supFunctLoc           = Option.getWithDefault(Option.map(AssetLib/Base/S4/Floc.pop >> ToString.toString, AssetLib/Base/S4/Floc.new(x1)), "")
        , equipInstall          = x6
        , statusProfile         = "ZEQUIPST"
        , userStatus            = x7
        }


    pub def toFlMultilingualText(src: #{FlocLongText | r}): List[FlMultilingualText] = 
        let buildStep = (x, ac) -> flocLongTextToUxl(x) :: ac;
        let sortStep = (x, y) -> Order.compare(x.functionalLocation, y.functionalLocation) |> Order.toInt;
        let xs = { fold FlocLongText Nil buildStep src };
        List.sortWith(sortStep, xs)

    def flocLongTextToUxl(x: (String, String, String)): FlMultilingualText = 
        let (x1, x2, x3) = x;
        { functionalLocation    = x1
        , deleteIndicator       = false
        , language              = "EN"
        , description           = x2
        , longText              = x3
        }


    pub def toFlClassifications(src: #{FlocCharacteristic | r}): List[FlClassification] = 
        let buildStep = (x, ac) -> flocCharacteristicToUxl(x) :: ac;
        let sortStep = (x, y) -> match Order.compare(x.functionalLocation, y.functionalLocation) { 
            case EqualTo => Order.compare(x.className, y.className) |> Order.toInt
            case ans => Order.toInt(ans)
        };
        let xs = { fold FlocCharacteristic Nil buildStep src };
        List.sortWith(sortStep, xs)

    def flocCharacteristicToUxl(x: (String, String, String, String)): FlClassification = 
        let (x1, x2, x3, x4) = x;
        { functionalLocation    = x1 
        , deletionInd           = false
        , classType             = "003"
        , className             = x2
        , status                = "1"
        , characteristicName    = x3
        , charValue             = x4
        , charDeletionInd       = false
        }

    pub def toEquipmentData(src: #{EquiDatum | r }): List[EquipmentData] = 
        let buildStep = (x, ac) -> equiDatumToUxl(x) :: ac;
        let sortStep = (x, y) -> match Order.compare(x.functionalLoc, y.functionalLoc) { 
            case EqualTo => match Order.compare(x.superordEquip, y.superordEquip) {
                case EqualTo => Order.compare(x.description, y.description) |> Order.toInt
                case ans => Order.toInt(ans)    
            }                
            case ans => Order.toInt(ans)
        };
        let xs = { fold EquiDatum Nil buildStep src };
        List.sortWith(sortStep, xs)


    def equiDatumToUxl(x: (String, String, String,
                            Time.LocalDate, String, Option[Float64],
                            Time.LocalDate, String, String, 
                            String, String, String, 
                            String, Option[Int32], String, 
                            String)): EquipmentData = 
        let (x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16) = x;
        let unitOfWeight = match x6 { 
            case Some(_) => "KG"
            case None => ""
        };
        { equiId            = x1
        , equipCategory     = x2
        , description       = x3
        , validFrom         = x4
        , objectType        = x5
        , grossWeight       = x6
        , unitOfWeight      = unitOfWeight
        , startupDate       = x7
        , manufacturer      = x8
        , modelNumber       = x9
        , manufPartNo       = x10
        , manufSerialNo     = x11
        , constructYear     = Time/LocalDate.getYear(x7)
        , constructMth      = Time/LocalDate.getMonthValue(x7)
        , maintPlant        = 2100
        , companyCode       = 2100
        , coArea            = 1000
        , planningPlant     = 2100
        , mainWorkCenter    = "DEFAULT"
        , plantWorkCenter   = 2100
        , functionalLoc     = x12
        , superordEquip     = x13
        , position          = x14
        , techIdentNo       = x15
        , statusProfile     = "ZEQUIPST"
        , statusOfAnObject  = x16
        }


    pub def toEqMultilingualText(src: #{ EquiLongText | r }): List[EqMultilingualText] = 
        let buildStep = (x, ac) -> equiLongTextToUxl(x) :: ac;
        let sortStep = (x, y) -> Order.compare(x.equiId, y.equiId) |> Order.toInt;
        let xs = { fold EquiLongText Nil buildStep src };
        List.sortWith(sortStep, xs)

    def equiLongTextToUxl(x: (String, String, String)): EqMultilingualText = 
        let (x1, x2, x3) = x;
        { equiId                = x1
        , deleteIndicator       = false
        , language              = "EN"
        , description           = x2
        , longText              = x3
        }


    pub def toEqClassifications(src: #{ EquiCharacteristic | r }): List[EqClassification] = 
        let buildStep = (x, ac) -> equiCharacteristicToUxl(x) :: ac;
        let sortStep = (x, y) -> match Order.compare(x.equiId, y.equiId) { 
            case EqualTo => Order.compare(x.className, y.className) |> Order.toInt
            case ans => Order.toInt(ans)
        };
        let xs = { fold EquiCharacteristic Nil buildStep src };
        List.sortWith(sortStep, xs)

    def equiCharacteristicToUxl(x: (String, String, String, String)): EqClassification = 
        let (x1, x2, x3, x4) = x;
        { equiId                = x1 
        , deleteInd             = false
        , classType             = "002"
        , className             = x2
        , status                = "1"
        , characteristicName    = x3
        , charValue             = x4
        , charDeleteInd         = false
        }


    /// pub def toClassEquiRow(src: #{ EquiCharacteristic | r }): List[ClassEquiRow] = 
    ///     let buildStep = (x, ac) -> equiCharacteristicToUxl(x) :: ac;
    ///     let sortStep = (x, y) -> match Order.compare(x.equiId, y.equiId) { 
    ///         case EqualTo => Order.compare(x.className, y.className) |> Order.toInt
    ///         case ans => Order.toInt(ans)
    ///     };
    ///     let xs = { fold EquiCharacteristic Nil buildStep src };
    ///     List.sortWith(sortStep, xs)

    /// def equiCharacteristicToUpload(x: (String, String, String, String)): ClassEquiRow = 
    ///     let (x1, x2, x3, x4) = x;
    ///     { equi: String
    ///     , className: String
    ///     , classType             = "002"
    ///     , internalClassNumber   = ""
    ///     , status                = Some(1)
    ///     }

}
