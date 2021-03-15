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

namespace AssetLib/Hierarchy/Datatypes {


    type alias FlocProperties = 
        { name: String                      /// e.g "3x DWF Overflow System"
        , identifier: String                /// "SAI00073456" 
        , objectType: String
        , startupDate: Time.LocalDate
        , status: String                    /// "UCON"
        }

    type alias Site = 
        { properties: FlocProperties
        , flocTag: String                   /// e.g "NOR20"
        , attributes: List[Attribute]
        , functions: List[Function]
        }

    /// FlocTag is properties.objectType
    type alias Function = 
        { properties: FlocProperties
        , attributes: List[Attribute]
        , processGroups: List[ProcessGroup]
        }

    /// FlocTag is properties.objectType
    type alias ProcessGroup = 
        { properties: FlocProperties
        , attributes: List[Attribute]
        , processes: List[Process]
        }

    /// FlocTag is properties.objectType
    type alias Process = 
        { properties: FlocProperties
        , attributes: List[Attribute]
        , systems: List[System]
        }

    type alias System = 
        { properties: FlocProperties
        , flocIndex: Int32                  /// "tag" = "SYS${zeroPad2(x.flocIndex)}"
        , attributes: List[Attribute]
        , subsystems: List[Subsystem]
        , equipment: List[Equipment]
        }

    type alias Subsystem = 
        { properties: FlocProperties
        , flocIndex: Int32                  /// "tag" = "${x.flocTagPrefix}${zeroPad2(x.flocIndex)}"
        , flocTagPrefix: String
        , attributes: List[Attribute]
        , equipment: List[Equipment]
        }


    /// Equipment has to be an enum due to recursion...
    pub enum Equipment {
        case Equipment(EquipmentProperties, List[Equipment])
    }


    type alias EquipmentProperties = 
        { name: String
        , identifier: String
        , objectType: String
        , startupDate: Time.LocalDate
        , status: String
        , attributes: List[Attribute]
        }

    /// The category "ROOT" is used for object-level attributes (e.g. Status).
    /// Otherwise the category is the class (e.g. "EAST_NORTH")
    type alias Attribute = 
        { classification: String
        , name: String
        , value: Value
        }

    pub enum Value {
        case Text(String)
        case Integer(Int32)
        case Decimal(Float64)
        case Date(Time.LocalDate)
    }

    pub def getAttributeValue(attrClass: String, attrName: String, attrs: List[Attribute]): Option[Value] = 
        List.findMap(x -> if (x.classification == attrClass and x.name == attrName) Some(x.value) else None, attrs)
        
        

}