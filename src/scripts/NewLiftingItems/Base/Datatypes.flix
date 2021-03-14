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

namespace NewLiftingItems/Base/Datatypes {

    /// LiftingEquipment is essentially a refinement of S4Equipment with
    /// named fields for classification data.

    type alias LiftingEquipment = 
        { equiId: String
        , objectType: String
        , objectClass: String
        , attributes: LiftingAttributes
        , longText: String
        , classifications: LiftingClassifications
        }

    type alias LiftingAttributes = 
        { category: String
        , description: String
        , startupDate: Time.LocalDate
        , manufacturer: String
        , model: String
        , partNumber: String
        , serialNumber: String
        , maintPlant: Int32
        , companyCode: Int32
        , controllingArea: Int32
        , planningPlant: Int32
        , functionalLocation: String
        , superOrdinateEqui: String
        , status: String 
        } 

    type alias LiftingClassifications = 
        { pliReference: String
        , saiParentReference: String
        , easting: Option[Int32]
        , northing: Option[Int32]
        , locationOnSite: String
        , workingLoadFieldName: String
        , workingLoad: Option[Float64]
        , workingLoadUnitsFieldName: String
        , workingLoadUnits: String
        , statutoryReference: String
        , testCertNumber: String
        }

    /// Updates list is just fields of interest.
    type alias LiftingEquipmentUpdate = 
        { equiId: String
        , updates: List[LiftingEqUpdate1]
        }

    /// equiId is immutable
    pub enum LiftingEqUpdate1 {
        case SetObjectType(String)
        case SetObjectClass(String)
        case SetAttributes(List[LiftingAttributesUpdate])
        case SetLongText(String)
        case SetClassifications(List[LiftingClassificationsUpdate])
    }

    
    pub enum LiftingAttributesUpdate {
        case SetCategory(String)
        case SetDescription(String)
        case SetStartupDate(Time.LocalDate)
        case SetManufacturer(String)
        case SetModel(String)
        case SetPartNumber(String)
        case SetSerialNumber(String)
        case SetMaintPlant(Int32)
        case SetCompanyCode(Int32)
        case SetControllingArea(Int32)
        case SetPlanningPlant(Int32)
        case SetFunctionalLocation(String)
        case SetSuperOrdinateEqui(String)
        case SetStatus(String)
    }

    /// A case for each record field
    pub enum LiftingClassificationsUpdate { 
        case SetPliReference(String)
        case SetSaiParentReference(String)
        case SetEasting(Option[Int32])
        case SetNorthing(Option[Int32])
        case SetLocationOnSite(String)
        case SetWorkingLoadFieldName(String)
        case SetWorkingLoad(Option[Float64])
        case SetWorkingLoadUnitsFieldName(String)
        case SetWorkingLoadUnits(String)
        case SetStatutoryReference(String)
        case SetTestCertNumber(String)
    }


    /// Interim datatypes

    pub enum FixedOrPortable { 
        case Fixed
        case Portable
    }

    instance ToString[FixedOrPortable] {
        pub def toString(x: FixedOrPortable): String =  match x { 
            case Fixed => "Fixed"
            case Portable => "Portable"
        }
    }

    instance FromString[FixedOrPortable] {
        pub def fromString(s: String): Option[FixedOrPortable] = 
            match String.toUpperCase(String.trim(s)) {
                case "FIXED" => Some(Fixed)
                case "PORTABLE" => Some(Portable)
                case _ => None
            }
    }

    instance Eq[FixedOrPortable] {
        pub def eq(x: FixedOrPortable, y: FixedOrPortable): Bool =  match (x, y) { 
            case (Fixed, Fixed) => true
            case (Portable, Portable) => true
            case (_, _) => false
        }

        pub def neq(x: FixedOrPortable, y: FixedOrPortable): Bool =  not (x ==y)
    }

    type alias S4TypeInfo = 
        { category: String 
        , s4Object: String
        , s4Class: String
        , fixedOrPortable: FixedOrPortable
        }
                
}
