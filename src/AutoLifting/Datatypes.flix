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

namespace AutoLifting/Datatypes {

    pub enum FixedOrPortable { 
        case Fixed
        case Portable
    }

    pub def showFixedOrPortable(x: FixedOrPortable): String =  match x { 
        case Fixed => "Fixed"
        case Portable => "Portable"
    }


    /// Start with (Reference, AssetName, NewParent)
  
    /// Result of Phase1Renaming
    type alias EquiWorkItem1 = 
        { aibEquiName: String
        , aibEquiType: String
        , aibSiteName: String
        , s4EquiName: String
        , pliReference: String
        , parentName: String
        }


    /// Get parent SAI, remove parentName
    type alias EquiWorkItem2 = 
        { aibEquiName: String
        , aibEquiType: String
        , pliReference: String
        , aibSiteName: String
        , s4EquiName: String
        , parentSaiReference: String
        }

    /// Get S4 Site, remove Aib Site
    type alias EquiWorkItem3 = 
        { aibEquiName: String
        , aibEquiType: String
        , pliReference: String
        , s4EquiName: String
        , s4SiteCode: String
        , parentSaiReference: String
        }


    /// Add S4 Type Info
    type alias EquiWorkItem4 = 
        { aibEquiName: String
        , aibEquiType: String
        , pliReference: String
        , s4EquiName: String
        , s4SiteCode: String
        , parentSaiReference: String
        , s4TyInfo: S4TypeInfo
        }

    type alias S4TypeInfo = 
        { category: String 
        , s4Object: String
        , s4Class: String
        , fixedOrPortable: FixedOrPortable
        }




}