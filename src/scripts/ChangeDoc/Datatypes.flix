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


namespace ChangeDoc/Datatypes {

    type alias ItemId = String



    type alias FlocTabItem = 
        { internalFuncloc :: String
        , funcloc :: String
        , description :: String
        , structureInd :: String
        , objectType :: String
        }
    
    type alias EquiTabItem = 
        { equiId :: String
        , description :: String
        , funcloc :: String
        , category :: String
        , objectType :: String
        , objectClass :: String
        }

    type alias ChangeDoc = List[ChangeRow]

    /// Address not processed at the moment
    /// Use RowNumber rather than Date and Time for an orderable.
    pub enum ChangeRow { 
        case Funcloc1(Int32, ItemId, Level1Attrs)
        case FunclocLongText(Int32, ItemId, LongTextAttrs)
        case FunclocClass(Int32, ItemId, ClassAttrs)
        case FunclocChar(Int32, ItemId, CharAttrs)
        case Equipment1(Int32, ItemId, Level1Attrs)
        case EquipmentLongText(Int32, ItemId, LongTextAttrs)
        case EquipmentClass(Int32, ItemId, ClassAttrs)
        case EquipmentChar(Int32, ItemId, CharAttrs)
    }

    /// Funclocs and Equipment are considered "Level1"
    type alias Level1Attrs = 
        { change :: String
        , attribute :: String 
        , oldValue :: String
        , newValue :: String
        , tableDest :: String
        }

    type alias LongTextAttrs = 
        { language :: String
        , change :: String
        , attribute :: String 
        , oldValue :: String
        , newValue :: String
        , tableDest :: String
        }


    type alias ClassAttrs = 
        { className :: String
        , classType :: String
        , change :: String
        , attribute :: String
        , oldValue :: String         
        , newValue :: String
        , tableDest :: String
        }

    type alias CharAttrs = 
        { charId :: String
        , classType :: String
        , intCounter :: Int32
        , change :: String
        , attribute :: String
        , oldValue :: String 
        , newValue :: String
        , tableDest :: String
        }




    pub enum EntityType with ToString, Eq, Order, Hash, Boxable {
        case Equi
        case Floc
    }



    pub enum Origin with ToString, Eq, Order, Hash, Boxable {
        case Direct
        case HSuperior
        case RRef
    }



    pub enum CharValue {
        case S4String(String)
        case S4Date(Time.LocalDate)
        case S4Int(Int32)
        case S4Float(Float64)
    }

    instance ToString[CharValue] {
        pub def toString(x: CharValue): String = match x {
            case S4String(x1)    => "S4String('${x1}')"
            case S4Date(x1)     => "S4Date(${x1})"
            case S4Int(x1)       => "S4Int(${x1})"
            case S4Float(x1)     => "S4Float(${x1})"
        }
    }

    instance Eq[CharValue] {
        pub def eq(x: CharValue, y: CharValue): Bool = match (x, y) {
            case (S4String(x1), S4String(y1))   => x1 == y1
            case (S4Date(x1), S4Date(y1))       => x1 == y1
            case (S4Int(x1), S4Int(y1))         => x1 == y1
            case (S4Float(x1), S4Float(y1))     => x1 == y1     /// Shock: ffloat equality!
            case _ => false
        }
    }

}
