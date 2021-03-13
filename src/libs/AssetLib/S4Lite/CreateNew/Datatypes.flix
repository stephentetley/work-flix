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


    type alias FlocDatum = 
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


    type alias EquiDatum = 
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
        , value: Value
        }

    pub enum Value {
        case Text(String)
        case Integer(Int32)
        case Decimal(Float64)
    }

    instance ToString[Value] {        
        pub def toString(x: Value): String = match x {
            case Text(s)    => s
            case Integer(i) => ToString.toString(i)
            case Decimal(d) => ToString.toString(d)
        }
    }

    instance Eq[Value] {
        pub def eq(x: Value, y: Value): Bool = match (x, y) {
            case (Text(s1), Text(s2)) => s1 == s2
            case (Integer(i1), Integer(i2)) => i1 == i2
            case (Decimal(d1), Decimal(d2)) => d1 == d2
            case (_, _) => false
        }

        pub def neq(x: Value, y: Value): Bool = not (x == y)
    }

    pub def getTextValue(x: Value): Option[String] = match x { 
        case Text(x1) => Some(x1)
        case _ => None
    }

    pub def getIntegerValue(x: Value): Option[Int32] = match x { 
        case Integer(x1) => Some(x1)
        case _ => None
    }

    pub def getDecimalValue(x: Value): Option[Float64] = match x { 
        case Decimal(x1) => Some(x1)
        case _ => None
    }

    pub enum ValueType {
        case TextType
        case IntegerType
        case DecimalType
    }

    instance ToString[ValueType] {        
        pub def toString(x: ValueType): String = match x {
            case TextType => "TextType"
            case IntegerType => "IntegerType"
            case DecimalType => "DecimalType"
        }
    }

    instance Eq[ValueType] {
        pub def eq(x: ValueType, y: ValueType): Bool = match (x, y) {
            case (TextType, TextType) => true
            case (IntegerType, IntegerType) => true
            case (DecimalType, DecimalType) => true
            case (_, _) => false
        }

        pub def neq(x: ValueType, y: ValueType): Bool = not (x == y)
    }

}