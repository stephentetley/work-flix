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

namespace Aruba/Aib/Base {



    /// Distinguish flocId and flocPath so we can handle internalFlocIds


    pub rel AibFloc(sainum: String, commonName: String, hkey: String)

    pub rel AibEqui(equiId: String, commonName: String, equiType: String)

    pub def flocLevel(hkey: String): String = match String.length(hkey) {
        case 1  => "Business_Unit"
        case 4  => "System"
        case 8  => "Function"
        case 13 => "Installation"
        case 18 => "Sub_Installation"
        case 20 => "Process_Group"
        case 24 => "Process"
        case 31 => "Plant"
        case 36 => "Plant_Item"
        case _  => "Unknown"
    }

}
