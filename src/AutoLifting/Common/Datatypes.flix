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

namespace AutoLifting/Common/Datatypes {

    pub enum FixedOrPortable { 
        case Fixed
        case Portable
    }

    pub def showFixedOrPortable(x: FixedOrPortable): String =  match x { 
        case Fixed => "Fixed"
        case Portable => "Portable"
    }


    pub def readFixedOrPortable(s: String): Result[FixedOrPortable, System.Error] = 
        match String.trim(String.toLowerCase(s)) {
            case "fixed" => Ok(Fixed)
            case "portable" => Ok(Portable)
            case _ => Err(System/Error.Generic("readFixedOrPortable"))
        }
        

    type alias S4TypeInfo = 
        { category: String 
        , s4Object: String
        , s4Class: String
        , fixedOrPortable: FixedOrPortable
        }




    type alias AibAttributeRow = 
        { pliReference: String
        , equiAttributes: EquiAttributes
        , charAttributes: AibCharAttributes
        }

    
    type alias EquiAttributes = 
        { assetStatus: String
        , installedFrom: Time.LocalDate
        , manufacturer: String
        , model: String
        , partNumber: String
        , serialNumber: String
        }



    type alias AibCharAttributes = 
        { osgb36: String
        , locationOnSite: String
        , workLoad: Option[Float64]
        , workLoadUnits: String
        , statutoryRef: String
        , testCertNum: String
        }

    type alias S4CharAttributes = 
        { easting: Int32
        , northing: Int32
        , locationOnSite: String
        , workLoad: Option[Float64]
        , workLoadUnits: String
        , statutoryRef: String
        , testCertNum: String
        }


}