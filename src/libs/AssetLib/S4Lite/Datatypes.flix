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


namespace AssetLib/S4Lite/Datatypes {

    /// Note - no nesting, it is much easier to generate from Datalog
    /// without nesting and to emit UXL and File Uploads

    use AssetLib/FileIO/S4/UxlFile/Datatypes.{ChangeRequestDetails, 
        FunctionalLocationData, FlMultilingualText, FlClassification, 
        EquipmentData, EqMultilingualText, EqClassification};

    type alias FunctionalLocation = 
        { funcloc: String
        , description: String
        , category: Int32
        , structureIndicator: String
        , objectType: String
        , startupDate: Time.LocalDate
        , superiorFloc: String
        , equipmentInstall: Bool
        , status: String
        }


    type alias FlocLongText = 
        { funcloc: String
        , description: String
        , longText: String
        }


    type alias FlocCharacteristic = 
        { funcloc: String
        , className: String
        , charName: String
        , valueType: S4LiteDataType
        , intCounterValue: Int32
        , charValue: String
        }


    type alias Equipment =
        { equiId: String
        , category: String              /// e.g "M", "I", "E"
        , description: String
        , validFrom: Time.LocalDate
        , objectType: String
        , weightKg: Option[Float64]
        , startupDate: Time.LocalDate
        , manufacturer: String
        , model: String
        , partNumber: String
        , serialNumber: String
        , functionalLocation: String
        , superOrdinateEqui: String
        , position: Option[Int32]
        , techIdentNo: String
        , status: String
        }

    type alias EquiLongText = 
        { equiId: String
        , description: String
        , longText: String
        }

    type alias EquiCharacteristic = 
        { equiId: String
        , className: String
        , charName: String
        , valueType: S4LiteDataType
        , intCounterValue: Int32
        , charValue: String
        }


    pub enum S4LiteDataType { 
        case Character          /// String
        case Date
        case NumericInt
        case NumericFloat
    }

    instance ToString[S4LiteDataType] {
        pub def toString(x: S4LiteDataType): String = match x {
            case Character => "Character"
            case Date => "Date"
            case NumericInt => "NumericInt"
            case NumericFloat => "NumericFloat"
        }
    }

    instance FromString[S4LiteDataType] {
        pub def fromString(x: String): Option[S4LiteDataType] = match x {
            case "Character" => Some(Character)
            case "Date" => Some(Date)
            case "NumericInt" => Some(NumericInt)
            case "NumericFloat" => Some(NumericFloat)
            case _ => None
        }
    }
    
    instance Eq[S4LiteDataType] {
        pub def eq(x: S4LiteDataType, y: S4LiteDataType): Bool = match (x, y) {
            case (Character, Character) => true
            case (Date, Date) => true
            case (NumericInt, NumericInt) => true
            case (NumericFloat, NumericFloat) => true
            case (_, _) => false
        }
    }

    instance Hash[S4LiteDataType] {
        pub def hash(x: S4LiteDataType): Int = Hash.hash(ToString.toString(x))
    }

}
