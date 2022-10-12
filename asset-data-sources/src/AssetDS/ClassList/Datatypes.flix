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


namespace AssetDS/ClassList/Datatypes {


    /// Parser types (low level)

    /// ValueRow could be a list-of-values item or a range. It is decoded later.
    pub enum ClassListRow {
        case ClassRow(ClassRow)
        case CharRow(CharacteristicRow)
        case ValueRow(String)
        case EmptyRow
    }

    instance ToString[ClassListRow] {
        pub def toString(x: ClassListRow): String = match x {
            case ClassRow(r)  => "ClassRow({classtype = ${r.classtype}, name = ${r.name}, description = ${r.description}})"
            case CharRow(r)   => "CharacteristicRow({name = ${r.name}, description = ${r.description}, chartype = ${r.chartype}, textLength = ${r.textLength}, decimalPlaces = ${r.decimalPlaces}})"
            case ValueRow(s)  => "ValueRow(${s})"
            case EmptyRow     => "EmptyRow"
        }
    }

    pub type alias ClassRow = 
        { classtype :: String
        , name :: String
        , description :: String 
        }

    pub type alias CharacteristicRow = 
        { name :: String
        , description :: String
        , chartype :: String
        , textLength :: Int32
        , decimalPlaces :: Option[Int32]
        }


    /// Builder types (higher level)

    pub type alias ClassRecords = 
        { classDescriptions :: List[ClassDescription]
        , characteristics :: List[Characteristic]
        , picklistValues :: List[PicklistValue]
        , intRanges :: List[IntRange]
        }


    pub type alias ClassDescription = 
        { className :: String
        , classType :: String
        , description :: String
        }


    pub type alias Characteristic = 
        { className :: String
        , classType :: String
        , charName :: String
        , description :: String
        , s4Datatype :: String
        , textLength :: Int32
        , decimalPlaces :: Option[Int32]
        }


    pub type alias PicklistValue = 
        { className :: String
        , classType :: String
        , charName :: String
        , value :: String
        }

    pub type alias IntRange = 
        { className :: String
        , classType :: String
        , charName :: String
        , rangeFrom :: Int32
        , rangeTo :: Int32
        }

}