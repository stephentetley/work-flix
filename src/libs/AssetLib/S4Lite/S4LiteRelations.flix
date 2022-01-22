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


namespace AssetLib/S4Lite/S4LiteRelations {

    use AssetLib/S4Lite/Datatypes.{SLFunctionalLocation, SLFlocLongText, SLFlocCharacteristic, 
        SLEquipment, SLEquiLongText, SLEquiCharacteristic, 
        SLDatatype};

    use AssetLib/S4Lite/Datatypes.SLDatatype.{Character, Date, NumericInt, NumericFloat};

    /// No relation for `FunctionalLocation`.
    /// Use the record `SLFunctionalLocation` instead, or use a custom 
    /// relation that uses a minimal set of fields to generate an
    /// `SLFunctionalLocation`.

    pub rel FlocLongText(funcloc: String, 
                        description: String, 
                        longText: String)

    /// Arity 4
    pub rel FlocCharacteristic(floc: String, 
                                className: String, 
                                charName: String, 
                                charValue: CharValue)


    /// No relation for `Equipment`.
    /// Use the record `SLEquipment` instead, or use a custom 
    /// relation that uses a minimal set of fields to generate an
    /// `SLEquipment`.

    pub rel EquiLongText(equiId: String, 
                        description: String, 
                        longText: String)


    /// Arity 4
    pub rel EquiCharacteristic(equiId: String, 
                                className: String, 
                                charName: String,
                                charValue: CharValue)





    pub def toSLFlocLongText(src: #{FlocLongText | r}): Array[SLFlocLongText] & Impure = 
        query src select (x1, x2, x3) from FlocLongText(x1, x2, x3)
            |> Array.map(flocLongTextToS4Lite)

    def flocLongTextToS4Lite(x: (String, String, String)): SLFlocLongText = 
        let (x1, x2, x3) = x;
        { funcloc           = x1
        , description       = x2
        , longText          = x3
        }


    pub def toSLFlocCharacteristics(src: #{FlocCharacteristic | r}): Array[SLFlocCharacteristic] & Impure = 
        query src select (x1, x2, x3, x4) from FlocCharacteristic(x1, x2, x3, x4)
            |> Array.map(flocCharacteristicToS4Lite)

    def flocCharacteristicToS4Lite(x: (String, String, String, CharValue)): SLFlocCharacteristic = 
        let (x1, x2, x3, x4) = x;
        { funcloc           = x1
        , className         = x2
        , charName          = x3
        , valueType         = typeOfValue(x4)
        , charValue         = stringOfValue(x4)
        }



    pub def toSLEquiLongTexts(src: #{ EquiLongText | r }): Array[SLEquiLongText] & Impure = 
        query src select (x1, x2, x3) from EquiLongText(x1, x2, x3)
            |> Array.map(equiLongTextToS4Lite)

    def equiLongTextToS4Lite(x: (String, String, String)): SLEquiLongText = 
        let (x1, x2, x3) = x;
        { equiId                = x1
        , description           = x2
        , longText              = x3
        }


    pub def toSLEquiCharacteristics(src: #{ EquiCharacteristic | r }): Array[SLEquiCharacteristic] & Impure = 
        query src select (x1, x2, x3, x4) from EquiCharacteristic(x1, x2, x3, x4)
            |> Array.map(equiCharacteristicToS4Lite)

    def equiCharacteristicToS4Lite(x: (String, String, String, CharValue)): SLEquiCharacteristic = 
        let (x1, x2, x3, x4) = x;
        { equiId            = x1 
        , className         = x2
        , charName          = x3
        , valueType         = typeOfValue(x4)
        , charValue         = stringOfValue(x4)
        }


    /// Target relations for generating S4Lite from Datalog

    pub enum CharValue {
        case S4String(String)
        case S4Date(Time.LocalDate)
        case S4Int(Int32)
        case S4Float(Float64)
    }

    def typeOfValue(x: CharValue): SLDatatype = match x { 
        case S4String(_)    => Character
        case S4Date(_)      => Date
        case S4Int(_)       => NumericInt
        case S4Float(_)     => NumericFloat
    }

    def stringOfValue(x: CharValue): String = match x { 
        case S4String(s)    => s
        case S4Date(dt)     => AssetLib/Base/S4/Utils.printS4Date(dt)
        case S4Int(i)       => ToString.toString(i)
        case S4Float(d)     => ToString.toString(d)
    }

    instance ToString[CharValue] {
        pub def toString(x: CharValue): String = match x {
            case S4String(s)    => "S4String(${s})"
            case S4Date(dt)     => {let s = AssetLib/Base/S4/Utils.printS4Date(dt); "S4Date(${s})"}
            case S4Int(i)       => "S4Int(${i})"
            case S4Float(d)     => "S4Float(${d})"
        }
    }

    instance Eq[CharValue] {
        pub def eq(x: CharValue, y: CharValue): Bool = match (x, y) {
            case (S4String(s1), S4String(s2)) => s1 == s2
            case (S4Date(dt1), S4Date(dt2)) => dt1 == dt2
            case (S4Int(i1), S4Int(i2)) => i1 == i2
            case (S4Float(d1), S4Float(d2)) => d1 == d2
            case (_, _) => false
        }
    }

    instance Order[CharValue] {
        pub def compare(x: CharValue, y: CharValue): Comparison = match (x, y) {
            case (S4String(s1), S4String(s2)) => s1 <=> s2
            case (S4Date(dt1), S4Date(dt2)) => dt1 <=> dt2
            case (S4Int(i1), S4Int(i2)) => i1 <=> i2
            case (S4Float(d1), S4Float(d2)) => d1 <=> d2
            case (S4String(_), _) => LessThan
            case (S4Date(_), _) => LessThan
            case (S4Int(_), _) => LessThan
            case (_, _) => GreaterThan
        }
    }

    instance Hash[CharValue] {
        pub def hash(x: CharValue): Int32 = Hash.hash(ToString.toString(x))
    }

    instance Boxable[CharValue] 


}
