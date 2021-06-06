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

    type alias UxlSource = 
        { funclocs: List[SLFunctionalLocation]
        , funclocLongTexts: List[SLFlocLongText]
        , funclocCharacteristics: List[SLFlocCharacteristic]
        , equipment: List[SLEquipment]
        , equiLongTexts: List[SLEquiLongText]
        , equiCharacteristics: List[SLEquiCharacteristic]
        }


    pub def combineUxlSource(s1: UxlSource, s2: UxlSource): UxlSource = 
        { funclocs = s1.funclocs ::: s2.funclocs
        , funclocLongTexts = s1.funclocLongTexts ::: s2.funclocLongTexts
        , funclocCharacteristics = s1.funclocCharacteristics ::: s2.funclocCharacteristics
        , equipment = s1.equipment ::: s2.equipment
        , equiLongTexts = s1.equiLongTexts ::: s2.equiLongTexts
        , equiCharacteristics = s1.equiCharacteristics ::: s2.equiCharacteristics
        }

    type alias SLFunctionalLocation = 
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


    type alias SLFlocLongText = 
        { funcloc: String
        , description: String
        , longText: String
        }


    type alias SLFlocCharacteristic = 
        { funcloc: String
        , className: String
        , charName: String
        , valueType: SLDatatype
        , intCounterValue: Int32
        , charValue: String
        }


    type alias SLEquipment =
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

    type alias SLEquiLongText = 
        { equiId: String
        , description: String
        , longText: String
        }

    type alias SLEquiCharacteristic = 
        { equiId: String
        , className: String
        , charName: String
        , valueType: SLDatatype
        , intCounterValue: Int32
        , charValue: String
        }


    pub enum SLDatatype { 
        case Character          /// String
        case Date
        case NumericInt
        case NumericFloat
    }

    instance ToString[SLDatatype] {
        pub def toString(x: SLDatatype): String = match x {
            case Character => "Character"
            case Date => "Date"
            case NumericInt => "NumericInt"
            case NumericFloat => "NumericFloat"
        }
    }

    instance FromString[SLDatatype] {
        pub def fromString(x: String): Option[SLDatatype] = match x {
            case "Character" => Some(Character)
            case "Date" => Some(Date)
            case "NumericInt" => Some(NumericInt)
            case "NumericFloat" => Some(NumericFloat)
            case _ => None
        }
    }
    
    instance Eq[SLDatatype] {
        pub def eq(x: SLDatatype, y: SLDatatype): Bool = match (x, y) {
            case (Character, Character) => true
            case (Date, Date) => true
            case (NumericInt, NumericInt) => true
            case (NumericFloat, NumericFloat) => true
            case (_, _) => false
        }
    }

    instance Hash[SLDatatype] {
        pub def hash(x: SLDatatype): Int = Hash.hash(ToString.toString(x))
    }

}
