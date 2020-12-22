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

namespace AssetLib/S4Lite/CreateNew/Datatypes {


    type alias S4Floc = 
        { functionalLocation: String
        , attributes: FlocAttributes
        , longText: Option[LongText]
        , classifications: List[Classification]
        }

    type alias FlocAttributes = 
        { description: String
        , category: Int32
        , structureIndicator: String
        , objectType: String
        , startupDate: Time.LocalDate
        , maintPlant: Int32
        , companyCode: Int32
        , controllingArea: Int32
        , superiorFloc: String
        , equipmentInstall: Bool
        , status: String
        }


    type alias S4Equipment = 
        { equiId: String
        , attributes: EquiAttributes
        , longText: Option[LongText]
        , classifications: List[Classification]
        }

    type alias EquiAttributes = 
        { category: String
        , description: String
        , objectType: String
        , startupDate: Time.LocalDate
        , manufacturer: String
        , model: String
        , partNumber: String
        , serialNumber: String
        , constructionYear: Int32
        , constructionMonth: Int32
        , maintPlant: Int32
        , companyCode: Int32
        , controllingArea: Int32
        , planningPlant: Int32
        , functionalLocation: String
        , superOrdinateEqui: String
        , techIdentNo: String
        , status: String
        }

    /// shortText = description.
    type alias LongText = 
        { shortText: String
        , longText: String
        }

    type alias Classification = 
        { className: String
        , charName: String
        , datatype: ValueType
        , value: String
        }

    pub enum ValueType {
        case Text
        case Integer
        case Decimal
    }


}