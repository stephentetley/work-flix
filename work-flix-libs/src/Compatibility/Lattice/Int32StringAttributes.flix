/*
 * Copyright 2022 Stephen Tetley
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

/// Temporary while we investigate problems with the polymorphic Attributes lattice...

namespace Compatibility/Lattice/Int32StringAttributes {

    
    pub enum Int32StringAttributes with Eq, Order, ToString { 
        case Top
        case Attributes(Map[Int32, String])
        case Bottom
    }

    pub def getAttributes(x: Int32StringAttributes): Option[Map[Int32, String]] = match x {
        case Top           => None
        case Attributes(m) => Some(m)
        case Bottom        => None
    }

    pub def getAttributes1(x: Int32StringAttributes): Map[Int32, String] = match x {
        case Top           => Map.empty()
        case Attributes(m) => m
        case Bottom        => Map.empty()
    }


    pub def singleton(k: Int32, v: String): Int32StringAttributes = 
        Attributes(Map.singleton(k, v))

    instance LowerBound[Int32StringAttributes] {
        pub def minValue(): Int32StringAttributes = Bottom
    }

    instance UpperBound[Int32StringAttributes] {
        pub def maxValue(): Int32StringAttributes = Top
    }

    instance PartialOrder[Int32StringAttributes] {
        pub def lessEqual(x: Int32StringAttributes, y: Int32StringAttributes): Bool = match (x, y) {
            case (Bottom, _)                      => true
            case (Attributes(m1), Attributes(m2)) => m1 <= m2
            case (_, Top)                         => true
            case _                                => false
        }
    }

    /// Uses left-biased union
    instance JoinLattice[Int32StringAttributes] {
        /// \/ Union
        pub def leastUpperBound(x: Int32StringAttributes, y: Int32StringAttributes): Int32StringAttributes = match (x, y) {
            case (Bottom, _)                      => y
            case (_, Bottom)                      => x
            case (Attributes(m1), Attributes(m2)) => Attributes(Map.union(m1, m2))
            case _                                => Top
        }
    }

    /// Uses left-biased union
    instance MeetLattice[Int32StringAttributes] {
        /// /\ Intersection
        pub def greatestLowerBound(x: Int32StringAttributes, y: Int32StringAttributes): Int32StringAttributes = match (x, y) {
            case (Top, _)                         => y
            case (_, Top)                         => x
            case (Attributes(m1), Attributes(m2)) => Attributes(Map.intersection(m1, m2))
            case _                                => Bottom
        }
    }

}
