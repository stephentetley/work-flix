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


namespace AssetLib/FileIO/S4/ClassList/Datatypes {

    use Time.LocalDate;

    /// Source type indicates minor but important formatting differences in the input files
    pub enum SourceType {
        case FlocClasses
        case EquiClasses
    }


    /// Flat representation - not a tree.
    pub type alias ClassListFile = 
        { dateStamp :: LocalDate
        , rows :: List[ClassListRow]
        }

    /// ValueRow could be a list-of-values item or a range. It is decoded later.
    pub enum ClassListRow {
        case ClassRow(ClassRow)
        case CharacteristicRow(CharacteristicRow)
        case ValueRow(String)
    }

    pub type alias ClassRow = 
        { classtype :: String
        , name :: String
        , description :: String 
        }

    pub type alias CharacteristicRow = 
        { name :: String
        , description :: String
        , chartype :: Datatype 
        }

    /// Nested representation.
    pub type alias ClassList = 
        { dateStamp :: LocalDate
        , classes :: List[Class]
        }


    // classType eg "002", "003"
    pub type alias Class = 
        { name :: String
        , description :: String
        , classtype :: String
        , characteristics :: List[Characteristic] 
        }

    pub type alias Characteristic = 
        { name :: String
        , description :: String
        , chartype :: Datatype
        , refinement :: Option[Refinement] 
        }

    pub enum Datatype with Eq, Order, ToString, Hash, Boxable { 
        case Text(Int32)
        case Date(Int32)
        case NumInt(Int32)
        case NumDecimal(Int32, Int32)
    }

    pub def s4StorageSize(x: Datatype): Int32 = match x {
        case Text(i)            => i
        case Date(i)            => i
        case NumInt(i)          => i
        case NumDecimal(i, _)   => i
    }

    pub def s4DecimalPlaces(x: Datatype): Option[Int32] = match x {
        case Text(_)            => None
        case Date(_)            => None
        case NumInt(_)          => None
        case NumDecimal(_, p)   => Some(p)
    }

    /// Instances ???

    pub def s4TypeName(x: Datatype): String = match x {
        case Text(_)            => "Char"
        case Date(_)            => "Date"
        case NumInt(_)          => "Int"
        case NumDecimal(_, _)   => "Float"
    }

    pub enum Refinement with Eq, Order, ToString, Hash, Boxable {
        case ListOfValues(List[String])
        case IntRange(Int32, Int32)
        case DecimalRange(Float64, Float64)
    }
    
    /// Instances ???
    
}