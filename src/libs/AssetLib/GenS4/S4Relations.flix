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


namespace AssetLib/GenS4/S4Relations {

    use AssetLib/S4/FileIO/UxlFile/Datatypes.{FunctionalLocationData, FlMultilingualText, 
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

    /// Arity 13
    pub rel EquiDatum(equiId: String, 
                        category: String,              /// e.g "M", "I", "E"
                        description: String,
                        objectType: String,
                        startupDate: Time.LocalDate,
                        manufacturer: String,
                        model: String,
                        partNumber: String,
                        serialNumber: String,
                        functionalLocation: String,
                        superOrdinateEqui: String,
                        techIdentNo: String,
                        status: String)

    pub rel EquiLongText(equiId: String, 
                        description: String, 
                        longText: String)


    /// Arity 4
    pub rel EquiCharacteristic(equiId: String, className: String, charName: String, charValue: String)


    /// To Uxl...
    pub def toFunctionalLocationData(src: #{FlocDatum | r}): List[FunctionalLocationData] & Impure = 
        let sortStep = (x, y) -> Order.compare(x.functionalLocation, y.functionalLocation) |> Order.toInt;
        query src select (x1, x2, x3, x4, x5, x6, x7) from FlocDatum(x1, x2, x3, x4, x5, x6, x7) 
            |> Array.toList 
            |> List.map(flocDatumToUxl)
            |> List.sortWith(sortStep)

    def flocDatumToUxl(x: (String, String, String, String, 
                            Time.LocalDate, Bool, String)): FunctionalLocationData = 
        let (x1, x2, x3, x4, x5, x6, x7) = x;
        { functionalLocation    = x1
        , maskedFuncLoc         = x1
        , description           = x2
        , functLocCat           = Option.getWithDefault(Option.map(AssetLib/S4/Base/Floc.level, AssetLib/S4/Base/Floc.new(x1)), 0)
        , strIndicator          = x3
        , objectType            = x4
        , startupDate           = x5
        , maintPlant            = 2100
        , companyCode           = 2100
        , coArea                = 1000
        , supFunctLoc           = Option.getWithDefault(Option.map(AssetLib/S4/Base/Floc.pop >> ToString.toString, AssetLib/S4/Base/Floc.new(x1)), "")
        , equipInstall          = x6
        , statusProfile         = "ZEQUIPST"
        , userStatus            = x7
        }


    pub def toFlMultilingualText(src: #{FlocLongText | r}): List[FlMultilingualText] & Impure = 
        let sortStep = (x, y) -> Order.compare(x.functionalLocation, y.functionalLocation) |> Order.toInt;
        query src select (x1, x2, x3) from FlocLongText(x1, x2, x3) 
            |> Array.toList 
            |> List.map(flocLongTextToUxl)
            |> List.sortWith(sortStep)


    def flocLongTextToUxl(x: (String, String, String)): FlMultilingualText = 
        let (x1, x2, x3) = x;
        { functionalLocation    = x1
        , deleteIndicator       = false
        , language              = "EN"
        , description           = x2
        , longText              = x3
        }


    pub def toFlClassifications(src: #{FlocCharacteristic | r}): List[FlClassification] & Impure = 
        let sortStep = (x, y) -> match Order.compare(x.functionalLocation, y.functionalLocation) { 
            case EqualTo => Order.compare(x.className, y.className) |> Order.toInt
            case ans => Order.toInt(ans)
        };
        query src select (x1, x2, x3, x4) from FlocCharacteristic(x1, x2, x3, x4) 
            |> Array.toList 
            |> List.map(flocCharacteristicToUxl)
            |> List.sortWith(sortStep)

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

    pub def toEquipmentData(src: #{EquiDatum | r}): List[EquipmentData] & Impure = 
        let sortStep = (x, y) -> Order.compare(x.equiId, y.equiId) |> Order.toInt;
        query src select (x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13) from EquiDatum(x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13) 
            |> Array.toList 
            |> List.map(equiDatumToUxl)
            |> List.sortWith(sortStep)


    def equiDatumToUxl(x: (String, String, String,
                            String, Time.LocalDate, String,
                            String, String, String,
                            String, String, String, 
                            String)): EquipmentData & Impure = 
        let (x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13) = x;
        let nonef64: Option[Float64] = None;    /// Avoids a typing problem with using None directly...
        let nonei32: Option[Int32] = None;
        { equiId            = x1
        , equipCategory     = x2
        , description       = x3
        , validFrom         = Time/LocalDate.now()
        , objectType        = x4
        , grossWeight       = nonef64
        , unitOfWeight      = ""
        , startupDate       = x5
        , manufacturer      = x6
        , modelNumber       = x7
        , manufPartNo       = x8
        , manufSerialNo     = x9
        , constructYear     = Time/LocalDate.getYear(x5)
        , constructMth      = Time/LocalDate.getMonth(x5)
        , maintPlant        = 2100
        , companyCode       = 2100
        , coArea            = 1000
        , planningPlant     = 2100
        , functionalLoc     = x10
        , superordEquip     = x11
        , position          = nonei32
        , techIdentNo       = x12
        , statusProfile     = "ZEQUIPST"
        , statusOfAnObject  = x13
        }


    pub def toEqMultilingualText(src: #{EquiLongText | r}): List[EqMultilingualText] & Impure = 
        let sortStep = (x, y) -> Order.compare(x.equiId, y.equiId) |> Order.toInt;
        query src select (x1, x2, x3) from EquiLongText(x1, x2, x3) 
            |> Array.toList 
            |> List.map(equiLongTextToUxl)
            |> List.sortWith(sortStep)


    def equiLongTextToUxl(x: (String, String, String)): EqMultilingualText = 
        let (x1, x2, x3) = x;
        { equiId                = x1
        , deleteIndicator       = false
        , language              = "EN"
        , description           = x2
        , longText              = x3
        }


    pub def toEqClassifications(src: #{EquiCharacteristic | r}): List[EqClassification] & Impure = 
        let sortStep = (x, y) -> match Order.compare(x.equiId, y.equiId) { 
            case EqualTo => Order.compare(x.className, y.className) |> Order.toInt
            case ans => Order.toInt(ans)
        };
        query src select (x1, x2, x3, x4) from EquiCharacteristic(x1, x2, x3, x4) 
            |> Array.toList 
            |> List.map(equiCharacteristicToUxl)
            |> List.sortWith(sortStep)

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

}
