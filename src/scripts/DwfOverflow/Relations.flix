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


namespace DwfOverflow/Relations {

    use AssetLib/S4/FileIO/UxlFile/Datatypes.{FunctionalLocationData, FlClassification};

    pub rel WorkListItem(reference: String, commonName: String, assetType: String, siteName: String)

    pub rel Floc(floc: String, name: String, sainum: String, overflowType: String, level: Int32, ngr: String, objType: String)

    pub rel AibSite(siteName: String, installedFrom: Time.LocalDate, ngr: String)

    /// Note - much of this is common code which merits being put in a library...


    /// Arity 14
    pub rel FlocDatum(funcloc: String, maskedFuncloc: String, description: String, 
        category: Int32, strIndicator: String, objectType: String, 
        startupDate: Time.LocalDate, maintPlant: Int32, companyCode: Int32, 
        coArea: Int32, supFunctLoc: String, equipInstall: Bool, 
        statusProfile: String, userStatus: String)

    /// Arity 6
    pub rel Characteristic(floc: String, classType: String, className: String, status: Int32, charName: String, charValue: String)




    /// To Uxl...
    pub def toFunctionalLocationData[r](src: #{ FlocDatum | r }): List[FunctionalLocationData] = 
        let buildStep = (x, ac) -> flocDatumToUxl(x) :: ac;
        let sortStep = (x, y) -> Order.compare(x.functionalLocation, y.functionalLocation) |> Order.toInt;
        let xs = { fold FlocDatum Nil buildStep src };
        List.sortWith(sortStep, xs)


    def flocDatumToUxl(x: (String, String, String, Int32, String, String, 
                            Time.LocalDate, Int32, Int32, Int32, String, Bool, 
                            String, String)): FunctionalLocationData = 
        let (x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14) = x;
        { functionalLocation    = x1
        , maskedFuncLoc         = x2
        , description           = x3
        , functLocCat           = x4
        , strIndicator          = x5
        , objectType            = x6
        , startupDate           = x7
        , maintPlant            = x8
        , companyCode           = x9
        , coArea                = x10
        , supFunctLoc           = x11
        , equipInstall          = x12
        , statusProfile         = x13
        , userStatus            = x14
        }


    pub def toFlClassifications[r](src: #{ Characteristic | r }): List[FlClassification] = 
        let buildStep = (x, ac) -> characteristicToUxl(x) :: ac;
        let sortStep = (x, y) -> match Order.compare(x.functionalLocation, y.functionalLocation) { 
            case EqualTo => Order.compare(x.className, y.className) |> Order.toInt
            case ans => Order.toInt(ans)
        };
        let xs = { fold Characteristic Nil buildStep src };
        List.sortWith(sortStep, xs)

    def characteristicToUxl(x: (String, String, String, Int32, String, String)): FlClassification = 
        let (x1, x2, x3, x4, x5, x6) = x;
        { functionalLocation    = x1 
        , deletionInd           = false
        , classType             = x2
        , className             = x3
        , status                = ToString.toString(x4)
        , characteristicName    = x5
        , charValue             = x6
        , charDeletionInd       = false
        }

}