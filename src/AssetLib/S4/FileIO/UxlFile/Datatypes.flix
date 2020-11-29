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
    

namespace AssetLib/S4/FileIO/UxlFile/Datatypes {
    
    
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
    type alias CreateFunctionalLocationData = 
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

    /// Updates list is just fields of interest.
    type alias UpdateFunctionalLocationData = 
        { functionalLocation: String
        , updates: List[FlDataUpdate1]
        }

    pub enum FlDataUpdate1 {
        case Description(String)
        case FunctLocCat(Int32)
        case StrIndicator(String)
        case ObjectType(String)
        case StartupDate(Time.LocalDate)
        case MaintPlant(Int32)
        case CompanyCode(Int32)
        case CoArea(Int32)
        case SupFunctLoc(String)
        case EquipInstall(Bool)
        case StatusProfile(String)
        case UserStatus(String)
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
    type alias CreateEquipmentData = 
        { equiId: String
        , equipCategory: String
        , description: String
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
        , functionalLoc: String
        , superordEquip: String
        , position: Option[Int32]
        , techIdentNo: String
        , statusProfile: String
        , statusOfAnObject: String
        }

    /// Updates list is just fields of interest.
    type alias UpdateEquipmentData = 
        { equiId: String
        , updates: List[EqDataUpdate1]
        }


    pub enum EqDataUpdate1 {
        case EquipCategory(String)
        case Description(String)
        case ObjectType(String)
        case GrossWeight(Float64)
        case UnitOfWeight(String)
        case StartupDate(Time.LocalDate)
        case Manufacturer(String)
        case ModelNumber(String)
        case ManufPartNo(String)
        case ManufSerialNo(String)
        case ConstructYear(Int32)
        case ConstructMth(Int32)
        case MaintPlant(Int32)
        case CompanyCode(Int32)
        case CoArea(Int32)
        case PlanningPlant(Int32)
        case FunctionalLoc(String)
        case SuperordEquip(String)
        case Position(Int32)
        case TechIdentNo(String)
        case StatusProfile(String)
        case StatusOfAnObject(String)
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

    pub enum S4Value {
        case Bool(Bool)
        case Text(String)
        case Int(Int32)
        case Decimal(Float64)
    }


}