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

namespace AutoLifting/Base/Datatypes {

    /// LiftingEquipment is essentially a refinement of S4Equipment with
    /// named fields for classifaction data.

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
        , superOridinateEqui: String
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

    /// Interim datatypes

    pub enum FixedOrPortable { 
        case Fixed
        case Portable
    }

    pub def showFixedOrPortable(x: FixedOrPortable): String =  match x { 
        case Fixed => "Fixed"
        case Portable => "Portable"
    }


    pub def readFixedOrPortable(s: String): Result[FixedOrPortable, System.Error] = 
        match String.trim(String.toUpperCase(s)) {
            case "FIXED" => Ok(Fixed)
            case "PORTABLE" => Ok(Portable)
            case _ => Err(System/Error.Generic("readFixedOrPortable"))
        }
        

    type alias S4TypeInfo = 
        { category: String 
        , s4Object: String
        , s4Class: String
        , fixedOrPortable: FixedOrPortable
        }


        
}