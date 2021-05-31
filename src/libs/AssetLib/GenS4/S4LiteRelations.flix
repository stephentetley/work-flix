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


namespace AssetLib/GenS4/S4LiteRelations {

    use AssetLib/S4Lite/Datatypes.{FunctionalLocation => S4LiteFunctionalLocation, 
        FlocLongText => S4LiteFlocLongText, 
        FlocCharacteristic => S4LiteFlocCharacteristic, 
        Equipment => S4LiteEquipment, 
        EquiLongText => S4LiteEquiLongText, 
        EquiCharacteristic => S4LiteEquiCharacteristic, 
        S4LiteDataType};

    use AssetLib/S4Lite/Datatypes.S4LiteDataType.{Character, Date, NumericInt, NumericFloat};

    pub enum CharValue {
        case S4String(String)
        case S4Date(Time.LocalDate)
        case S4Int(Int32)
        case S4Float(Float64)
    }

    def typeOfValue(x: CharValue): S4LiteDataType = match x { 
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
            case (S4Date(dt1), S4Date(dt2)) => dt1<=> dt2
            case (S4Int(i1), S4Int(i2)) => i1 <=> i2
            case (S4Float(d1), S4Float(d2)) => d1 <=> d2
            case (S4String(_), _) => LessThan
            case (S4Date(_), _) => LessThan
            case (S4Int(_), _) => LessThan
            case (_, _) => GreaterThan
        }
    }

    instance Hash[CharValue] {
        pub def hash(x: CharValue): Int = Hash.hash(ToString.toString(x))
    }

    instance Boxable[CharValue] {
        pub def box(x: CharValue): Boxed = {
            let value = x as ##java.lang.Object;
            let compare = (o1, o2) -> Order.compare(o1 as CharValue, o2 as CharValue);
            let toString = o -> ToString.toString(o as CharValue);
            BoxedObject(value, compare, toString)
        }
        pub def unbox(x: Boxed): CharValue = match x {
            case BoxedObject(v, _, _) => v as CharValue
            case _                    => ?bug
        }
    }

    /// Arity 7
    pub rel FunctionalLocation(funcloc: String, 
                        description: String, 
                        strIndicator: String, 
                        objectType: String, 
                        startupDate: Time.LocalDate, 
                        equipInstall: Bool, 
                        userStatus: String)

    pub rel FlocLongText(funcloc: String, 
                        description: String, 
                        longText: String)

    /// Arity 4
    pub rel FlocCharacteristic(floc: String, 
                                className: String, 
                                charName: String, 
                                charValue: CharValue)

    /// Arity 16
    pub rel Equipment(equiId: String, 
                        category: String,              /// e.g "M", "I", "E"
                        description: String,
                        validFrom: Time.LocalDate,
                        objectType: String,
                        weightKg: Option[Float64],
                        startupDate: Time.LocalDate,
                        manufacturer: String,
                        model: String,
                        partNumber: String,
                        serialNumber: String,
                        functionalLocation: String,
                        superOrdinateEqui: String, 
                        position: Option[Int32],
                        techIdentNo: String,
                        status: String)

    pub rel EquiLongText(equiId: String, 
                        description: String, 
                        longText: String)


    /// Arity 4
    pub rel EquiCharacteristic(equiId: String, 
                                className: String, 
                                charName: String, 
                                charValue: CharValue)



    /// To Uxl...
    pub def toS4LiteFunctionalLocation(src: #{FunctionalLocation | r}): List[S4LiteFunctionalLocation] & Impure = 
        query src select (x1, x2, x3, x4, x5, x6, x7) from FunctionalLocation(x1, x2, x3, x4, x5, x6, x7)
            |> Array.toList
            |> List.map(functionalLocationToS4Lite)


    def functionalLocationToS4Lite(x: (String, String, String, String, 
                            Time.LocalDate, Bool, String)): S4LiteFunctionalLocation = 
        let (x1, x2, x3, x4, x5, x6, x7) = x;
        { funcloc    = x1
        , description           = x2
        , category              = Option.getWithDefault(Option.map(AssetLib/Base/S4/Floc.level, AssetLib/Base/S4/Floc.new(x1)), 0)
        , structureIndicator    = x3
        , objectType            = x4
        , startupDate           = x5
        , superiorFloc          = Option.getWithDefault(Option.map(AssetLib/Base/S4/Floc.pop >> ToString.toString, AssetLib/Base/S4/Floc.new(x1)), "")
        , equipmentInstall      = x6
        , status                = x7
        }


    pub def toS4LiteFlocLongText(src: #{FlocLongText | r}): List[S4LiteFlocLongText] & Impure = 
        query src select (x1, x2, x3) from FlocLongText(x1, x2, x3)
            |> Array.toList
            |> List.map(flocLongTextToS4Lite)

    def flocLongTextToS4Lite(x: (String, String, String)): S4LiteFlocLongText = 
        let (x1, x2, x3) = x;
        { funcloc           = x1
        , description       = x2
        , longText          = x3
        }


    pub def toS4LiteFlocCharacteristic(src: #{FlocCharacteristic | r}): List[S4LiteFlocCharacteristic] & Impure = 
        query src select (x1, x2, x3, x4) from FlocCharacteristic(x1, x2, x3, x4)
            |> Array.toList
            |> List.map(flocCharacteristicToS4Lite)

    def flocCharacteristicToS4Lite(x: (String, String, String, CharValue)): S4LiteFlocCharacteristic = 
        let (x1, x2, x3, x4) = x;
        { funcloc           = x1
        , className         = x2
        , charName          = x3
        , valueType         = typeOfValue(x4)
        , intCounterValue   = 1
        , charValue         = stringOfValue(x4)
        }

    /// pub def toEquipmentData(src: #{EquiDatum | r }): List[EquipmentData] & Impure = 
    ///     let sortStep = (x, y) -> match Order.compare(x.functionalLoc, y.functionalLoc) { 
    ///         case EqualTo => match Order.compare(x.superordEquip, y.superordEquip) {
    ///             case EqualTo => Order.compare(x.description, y.description) |> Comparison.toInt
    ///             case ans => Comparison.toInt(ans)    
    ///         }                
    ///         case ans => Comparison.toInt(ans)
    ///     };
    ///     query src select (x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16) from EquiDatum(x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16)
    ///         |> Array.toList
    ///         |> List.map(equiDatumToS4Lite)
    ///         |> List.sortWith(sortStep)


    /// def equiDatumToS4Lite(x: (String, String, String,
    ///                         Time.LocalDate, String, Option[Float64],
    ///                         Time.LocalDate, String, String, 
    ///                         String, String, String, 
    ///                         String, Option[Int32], String, 
    ///                         String)): EquipmentData = 
    ///     let (x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16) = x;
    ///     let unitOfWeight = match x6 { 
    ///         case Some(_) => "KG"
    ///         case None => ""
    ///     };
    ///     { equiId            = x1
    ///     , equipCategory     = x2
    ///     , description       = x3
    ///     , validFrom         = x4
    ///     , objectType        = x5
    ///     , grossWeight       = x6
    ///     , unitOfWeight      = unitOfWeight
    ///     , startupDate       = x7
    ///     , manufacturer      = x8
    ///     , modelNumber       = x9
    ///     , manufPartNo       = x10
    ///     , manufSerialNo     = x11
    ///     , constructYear     = Time/LocalDate.getYear(x7)
    ///     , constructMth      = Time/LocalDate.getMonthValue(x7)
    ///     , maintPlant        = 2100
    ///     , companyCode       = 2100
    ///     , coArea            = 1000
    ///     , planningPlant     = 2100
    ///     , mainWorkCenter    = "DEFAULT"
    ///     , plantWorkCenter   = 2100
    ///     , functionalLoc     = x12
    ///     , superordEquip     = x13
    ///     , position          = x14
    ///     , techIdentNo       = x15
    ///     , statusProfile     = "ZEQUIPST"
    ///     , statusOfAnObject  = x16
    ///     }


    /// pub def toEqMultilingualText(src: #{ EquiLongText | r }): List[EqMultilingualText] & Impure = 
    ///     let sortStep = (x, y) -> Order.compare(x.equiId, y.equiId) |> Comparison.toInt;
    ///     query src select (x1, x2, x3) from EquiLongText(x1, x2, x3)
    ///         |> Array.toList
    ///         |> List.map(equiLongTextToS4Lite)
    ///         |> List.sortWith(sortStep)

    /// def equiLongTextToS4Lite(x: (String, String, String)): EqMultilingualText = 
    ///     let (x1, x2, x3) = x;
    ///     { equiId                = x1
    ///     , deleteIndicator       = false
    ///     , language              = "EN"
    ///     , description           = x2
    ///     , longText              = x3
    ///     }


    /// pub def toEqClassifications(src: #{ EquiCharacteristic | r }): List[EqClassification] & Impure = 
    ///     let sortStep = (x, y) -> match Order.compare(x.equiId, y.equiId) { 
    ///         case EqualTo => Order.compare(x.className, y.className) |> Comparison.toInt
    ///         case ans => Comparison.toInt(ans)
    ///     };
    ///     query src select (x1, x2, x3, x4) from EquiCharacteristic(x1, x2, x3, x4)
    ///         |> Array.toList
    ///         |> List.map(equiCharacteristicToS4Lite)
    ///         |> List.sortWith(sortStep)

    /// def equiCharacteristicToS4Lite(x: (String, String, String, String)): EqClassification = 
    ///     let (x1, x2, x3, x4) = x;
    ///     { equiId                = x1 
    ///     , deleteInd             = false
    ///     , classType             = "002"
    ///     , className             = x2
    ///     , status                = "1"
    ///     , characteristicName    = x3
    ///     , charValue             = x4
    ///     , charDeleteInd         = false
    ///     }



}
