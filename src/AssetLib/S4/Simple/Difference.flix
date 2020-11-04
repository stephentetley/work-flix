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
    

namespace AssetLib/S4/FileIO/Simple/Difference {
    
    /// Should we be working on Simple instead?

    pub enum DiffValue[v] {
        case Same(v)
        case Diff(v, v)        
    }

    pub enum DiffOption[v] {
        case InLeft(v)
        case InRight(v)
        case Both(DiffValue[v])
    }


    type alias EquipmentDiff = 
        { equiId: String
        , attributes: EquiAttributesDiff
        , longText: Option[LongTextDiff]
        , classifications: List[DiffOption[Classification]]
        }   

    type alias EquiAttributesDiff = 
        { category: DiffValue[String]
        , description: DiffValue[String]
        , objectType: DiffValue[String]
        , startupDate: DiffValue[Time.LocalDate]
        , manufacturer: DiffValue[String]
        , model: DiffValue[String]
        , partNumber: DiffValue[String]
        , serialNumber: DiffValue[String]
        , constructionYear: DiffValue[Int32]
        , constructionMonth: DiffValue[Int32]
        , maintPlant: DiffValue[Int32]
        , companyCode: DiffValue[Int32]
        , costCenter: DiffValue[Int32]
        , planningPlant: DiffValue[Int32]
        , functionalLocation: DiffValue[String]
        , superOridinateEqui: DiffValue[String]
        , status: DiffValue[String]
        }

    /// shortText = description.
    type alias LongTextDiff = 
        { shortText: DiffValue[String]
        , longText: DiffValue[String]
        }


    //// Whoa - a classification may be present in one version of an equipment, but abset in another.

    type alias ClassificationDiff = 
        { className: String
        , charName: String
        , datatype: String
        , value: DiffValue[String]
        }




    /// pub def equiDiff(e1: )

}