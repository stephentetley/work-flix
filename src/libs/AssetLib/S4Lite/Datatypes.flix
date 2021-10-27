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

    /// TODO - group with List or Chain?
    /// If we use Chain we should probably make it an opaque type...
    /// The (assumed) speed loss of List concat is probably not enough to merit 
    /// a non-standard type (Chain)
    
    pub type alias UxlSource = 
        { funclocs :: Chain[SLFunctionalLocation]
        , funclocLongTexts :: Chain[SLFlocLongText]
        , funclocCharacteristics :: Chain[SLFlocCharacteristic]
        , equipment :: Chain[SLEquipment]
        , equiLongTexts :: Chain[SLEquiLongText]
        , equiCharacteristics :: Chain[SLEquiCharacteristic]
        }

    pub def emptyUxlSource(): UxlSource = 
        { funclocs = Chain.empty()
        , funclocLongTexts = Chain.empty()
        , funclocCharacteristics = Chain.empty()
        , equipment = Chain.empty()
        , equiLongTexts = Chain.empty()
        , equiCharacteristics = Chain.empty()
        }

    pub def combineUxlSource(s1: UxlSource, s2: UxlSource): UxlSource = 
        { funclocs = Monoid.combine(s1.funclocs, s2.funclocs)
        , funclocLongTexts = Monoid.combine(s1.funclocLongTexts, s2.funclocLongTexts)
        , funclocCharacteristics = Monoid.combine(s1.funclocCharacteristics, s2.funclocCharacteristics)
        , equipment = Monoid.combine(s1.equipment, s2.equipment)
        , equiLongTexts = Monoid.combine(s1.equiLongTexts, s2.equiLongTexts)
        , equiCharacteristics = Monoid.combine(s1.equiCharacteristics, s2.equiCharacteristics)
        }

    pub type alias SLFunctionalLocation = 
        { funcloc :: String
        , description :: String
        , category :: Int32
        , structureIndicator :: String
        , objectType :: String
        , startupDate :: Time.LocalDate
        , position :: Option[Int32]
        , superiorFloc :: String
        , equipmentInstall :: Bool
        , status :: String
        }


    pub type alias SLFlocLongText = 
        { funcloc :: String
        , description :: String
        , longText :: String
        }


    pub type alias SLFlocCharacteristic = 
        { funcloc :: String
        , className :: String
        , charName :: String
        , valueType :: SLDatatype
        , intCounterValue :: Int32
        , charValue :: String
        }


    pub type alias SLEquipment =
        { equiId :: String
        , category :: String              /// e.g "M", "I", "E"
        , description :: String
        , validFrom :: Time.LocalDate     /// usually today (i.e. Time/LocaleDate.now())
        , objectType :: String
        , weightKg :: Option[Float64]
        , startupDate :: Time.LocalDate
        , manufacturer :: String
        , model :: String
        , partNumber :: String
        , serialNumber :: String
        , functionalLocation :: String
        , superOrdinateEqui :: String
        , position :: Option[Int32]
        , techIdentNo :: String
        , status :: String
        }

    pub type alias SLEquiLongText = 
        { equiId :: String
        , description :: String
        , longText :: String
        }

    pub type alias SLEquiCharacteristic = 
        { equiId :: String
        , className :: String
        , charName :: String
        , valueType :: SLDatatype
        , intCounterValue :: Int32
        , charValue :: String
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
