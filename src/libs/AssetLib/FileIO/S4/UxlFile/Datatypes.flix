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
    

namespace AssetLib/FileIO/S4/UxlFile/Datatypes {
    
    
    /// Typically `changeRequestType` = "AIWEAM0P"
    /// Typically `processRequester` = "ASSET DATA"
    /// Just fields of interest...
    /// Either `flFunctionalLocation` or `eqEquipment`
    type alias ChangeRequestDetails = 
        { description: String
        , changeRequestType: String
        , flFunctionalLocation: String
        , eqEquipment: String
        , processRequester: String
        }

    
    
    
    /// Just fields of interest...
    type alias FunctionalLocationData = 
        { functionalLocation: String
        , maskedFuncLoc: String
        , description: String
        , functLocCat: Int32
        , strIndicator: String
        , objectType: String
        , startupDate: Time.LocalDate
        , maintPlant: Int32
        , companyCode: Int32
        , coArea: Int32
        , supFunctLoc: String
        , equipInstall: Bool
        , statusProfile: String
        , userStatus: String        
        } 


    /// `description` should be the same value as description on FunctionalLocationData page.
    /// `longText` is the actual long text
    type alias FlMultilingualText = 
        { functionalLocation: String
        , deleteIndicator: Bool
        , language: String
        , description: String
        , longText: String
        }

    // Functional Location,Deletion Ind,Class Type,Class,Status,Characteristics,Char Value,Ch.Deletion Ind.
    type alias FlClassification = 
        { functionalLocation: String
        , deletionInd: Bool
        , classType: String
        , className: String
        , status: String
        , characteristicName: String
        , charValue: String
        , charDeletionInd: Bool 
        }

    /// Just fields of interest...
    type alias EquipmentData = 
        { equiId: String
        , equipCategory: String
        , description: String
        , validFrom: Time.LocalDate
        , objectType: String
        , grossWeight: Option[Float64]
        , unitOfWeight: String
        , startupDate: Time.LocalDate
        , manufacturer: String
        , modelNumber: String
        , manufPartNo: String
        , manufSerialNo: String
        , constructYear: Int32
        , constructMth: Int32
        , maintPlant: Int32
        , companyCode: Int32
        , coArea: Int32
        , planningPlant: Int32
        , mainWorkCenter: String            /// default: DEFAULT
        , plantWorkCenter: Int32            /// default: 2100
        , functionalLoc: String
        , superordEquip: String
        , position: Option[Int32]
        , techIdentNo: String
        , statusProfile: String
        , statusOfAnObject: String
        }



    /// `description` should be the same value as description on FunctionalLocationData page.
    /// `longText` is the actual long text
    type alias EqMultilingualText = 
        { equiId: String
        , deleteIndicator: Bool
        , language: String
        , description: String
        , longText: String
        }

    // Equipment,Delete Ind.,Class Type,Class,Status,Characteristics,Char Value,Ch. Delete Ind.
    type alias EqClassification = 
        { equiId: String
        , deleteInd: Bool
        , classType: String
        , className: String
        , status: String
        , characteristicName: String
        , charValue: String
        , charDeleteInd: Bool 
        }



}