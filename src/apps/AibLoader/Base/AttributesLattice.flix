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


namespace AibLoader/Base/AttributesLattice {

    
    pub enum AttributeValue with Eq, Order, ToString, Boxable, Hash {
        case AttrString(String)
        case AttrInt(Int32)
        case AttrFloat(Float64)
        case AttrDate(Time.LocalDate)
    }

    pub enum Attributes with Eq, Order, ToString { 
        case Top
        case Attributes(Map[String, AttributeValue])
        case Bottom
    }


    pub def getAttributes(x: Attributes): Option[Map[String, AttributeValue]] = match x {
        case Top           => None
        case Attributes(m) => Some(m)
        case Bottom        => None
    }

    pub def singleton(k: String, v: AttributeValue): Attributes = 
        Attributes(Map.singleton(k, v))

    instance LowerBound[Attributes] {
        pub def minValue(): Attributes = Bottom
    }

    instance UpperBound[Attributes] {
        pub def maxValue(): Attributes = Top
    }
    
    instance PartialOrder[Attributes] {
        pub def lessEqual(x: Attributes, y: Attributes): Bool = match (x, y) {
            case (Bottom, _)                      => true
            case (Attributes(m1), Attributes(m2)) => m1 <= m2
            case (_, Top)                         => true
            case _                                => false
        }
    }


    instance JoinLattice[Attributes] {
        /// \/
        pub def leastUpperBound(x: Attributes, y: Attributes): Attributes = match (x, y) {
            case (Bottom, _)                      => y
            case (_, Bottom)                      => x
            case (Attributes(m1), Attributes(m2)) => Attributes(Map.union(m1, m2))
            case _                                => Top
        }
    }

    instance MeetLattice[Attributes] {
        /// /\
        pub def greatestLowerBound(x: Attributes, y: Attributes): Attributes = match (x, y) {
            case (Top, _)                         => y
            case (_, Top)                         => x
            case (Attributes(m1), Attributes(m2)) => Attributes(Map.intersection(m1, m2))
            case _                                => Bottom
        }
    }

}
