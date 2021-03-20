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


namespace AssetLib/S4Rel/Relations {

    use AssetLib/S4/FileIO/UxlFile/Datatypes.{FunctionalLocationData, FlClassification, EquipmentData, EqClassification};


    /// Arity 7
    pub rel FlocDatum(funcloc: String, 
                        description: String, 
                        strIndicator: String, 
                        objectType: String, 
                        startupDate: Time.LocalDate, 
                        equipInstall: Bool, 
                        userStatus: String)

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

    /// Arity 4
    pub rel EquiCharacteristic(equiId: String, className: String, charName: String, charValue: String)


    /// To Uxl...
    pub def toFunctionalLocationData[r](src: #{ FlocDatum | r }): List[FunctionalLocationData] = 
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


    pub def toFlClassifications[r](src: #{ FlocCharacteristic | r }): List[FlClassification] = 
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

    pub def toEqClassifications[r](src: #{ EquiCharacteristic | r }): List[EqClassification] = 
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

}
