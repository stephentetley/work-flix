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


    /// Start with (Reference, AssetName, NewParent)
    /// i.e. AibExportRow
  

    
    /// Get parent SAI, remove parentName
    /// Get S4 Site, remove Aib Site
    /// Add S4 Type Info and s4Floc
    type alias Phase1FinalWorkItem = 
        { aibEquiName: String
        , aibEquiType: String
        , pliReference: String
        , change: String
        , s4EquiName: String
        , s4SiteCode: String
        , parentSaiReference: String
        , s4TyInfo: S4TypeInfo
        , s4Floc: String
        }

    type alias S4TypeInfo = 
        { category: String 
        , s4Object: String
        , s4Class: String
        , fixedOrPortable: FixedOrPortable
        }


    /// Reference, Parent Reference, S4 Name, S4 Floc, Equi Category, Equi Object, Equi Class


    type alias AibMemoRow = 
        { pliReference: String
        , memo1: String
        , memo2: String
        , memo3: String
        , memo4: String
        , memo5: String
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

    type alias Phase2FinalWorkItem = 
        { pliReference: String
        , parentSaiReference: String
        , change: String
        , s4EquiName: String
        , s4Floc: String
        , s4Category: String 
        , s4Object: String
        , s4Class: String
        , equiAttributes: EquiAttributes
        , longText: Option[String]
        , charAttributes: S4CharAttributes
        }



}