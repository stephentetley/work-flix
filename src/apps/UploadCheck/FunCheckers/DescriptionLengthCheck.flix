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

namespace UploadCheck/FunCheckers/DescriptionLengthCheck {

    use DataCheck.Check;
    use DataCheck.Check.{Pass};
    use DataCheck/Check.{failure, mapFail};


    use AssetLib/S4/FileIO/UxlFile/Datatypes.{CreateFunctionalLocationData, CreateEquipmentData};
    use UploadCheck/Base/RowCheck.{FunRowChecker};
    use UploadCheck/Base/RowCheck.FunRowChecker.{FunRowChecker};


    pub def flocDescriptionLength(): FunRowChecker[CreateFunctionalLocationData] = 
        FunRowChecker((row, ix) -> 
            mapFail(
                msg1 -> 
                { sheetName = "Functional Location Data", rowIndex = ix, failMessage = "${row.functionalLocation} - flocDescriptionLength failed -${msg1}"}
                ,  descriptionLengthHelper(row.description)
            ) as & Impure
                      
        )

    pub def equiDescriptionLength(): FunRowChecker[CreateEquipmentData] = 
        FunRowChecker((row, ix) -> 
            mapFail(
                msg1 -> 
                { sheetName = "Equipment Data", rowIndex = ix, failMessage = "${row.equiId} - flocDescriptionLength failed -${msg1}"}
                ,  descriptionLengthHelper(row.description)
            ) as & Impure
                      
        )

    def descriptionLengthHelper(descriptionMedium: String): Check[String] =         
        match String.length(descriptionMedium) {
            case len if len < 1     => failure("empty text")
            case len if len > 40    => failure("`${descriptionMedium}` too long")
            case _                  => Pass
        }



}