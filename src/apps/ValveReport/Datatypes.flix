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

namespace ValveReport/Datatypes {


    /// This is obsolete already - looking to use just S4Lite and "substitutions"...

    /// Valve is essentially a refinement of S4Equipment with
    /// named fields for classification data.

    type alias Valve = 
        { equiId: String
        , objectType: String
        , objectClass: String
        , attributes: ValveAttributes
        , longText: String
        , classifications: ValveClassifications
        }

    type alias ValveAttributes = 
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

    type alias ValveClassifications = 
        { pliReference: String
        , saiParentReference: String
        , easting: Int32
        , northing: Int32
        , locationOnSite: String
        , valveSize: Float64
        , sizeUnits: String
        }



        
}