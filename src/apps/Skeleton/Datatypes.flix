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

namespace Skeleton/Datatypes {

    /// Reference	Common Name	S4 Floc	Superior Equipment	Installed From	
    /// Manufacturer	Model	Hierarchy Key	AssetStatus	Loc.Ref.	
    /// Asset in AIDE ?	Serial No	Specific Model/Frame

    type alias AibInputRow = 
        { reference: String
        , commonName: String
        , s4Floc: String
        , s4EquiType: String
        , s4EquiClass: String
        , superiorEquipment: String
        , installedFrom: Time.LocalDate
        , manufacturer: String
        , model: String
        , specificModelFrame: String
        , serialNumber: String
        , locRef: String
        , assetStatus: String
        }

    type alias FlocInputRow = 
        { s4Floc: String
        , description: String
        , objectType: String
        , systemClass: String
        }

}
