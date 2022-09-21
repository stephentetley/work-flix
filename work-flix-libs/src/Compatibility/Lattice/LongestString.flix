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

namespace Compatibility/Lattice/LongestString {


    pub enum LongestString with Eq, Order, ToString, Boxable {
        case Top
        case LongestString(String) 
        case Bottom
    }

    pub def longestString(x: String): LongestString = LongestString(x)

    pub def getValue(x: LongestString): Option[String] = match x {
        case Top               => None
        case LongestString(s1) => Some(s1)
        case Bottom            => None
    }

    
    instance PartialOrder[LongestString] {
        pub def lessEqual(x: LongestString, y: LongestString): Bool = match (x, y) {
            case (Bottom, _)                            => true
            case (Top, Bottom)                          => false
            case (Top, LongestString(_))                => false
            case (Top, Top)                             => true
            case (LongestString(_), Bottom)             => false
            case (LongestString(_), Top)                => true
            case (LongestString(x1), LongestString(y1)) => x1 <= y1
        }
    }


    instance LowerBound[LongestString] {
        pub def minValue(): LongestString = Bottom
    }

    instance UpperBound[LongestString] {
        pub def maxValue(): LongestString = Top
    }

    instance JoinLattice[LongestString] {
        /// \/
        pub def leastUpperBound(x: LongestString, y: LongestString): LongestString = match (x, y) {
            case (Top, _)                               => Top
            case (Bottom, y1)                           => y1
            case (LongestString(_), Top)                => Top
            case (LongestString(x1), Bottom)            => LongestString(x1)
            case (LongestString(x1), LongestString(y1)) => 
                if (String.length(x1) <= String.length(y1)) LongestString(y1) else LongestString(x1)
        }
    }

    instance MeetLattice[LongestString] {
        /// /\
        pub def greatestLowerBound(x: LongestString, y: LongestString): LongestString = match (x, y) {
            case (Bottom, _)                            => Bottom
            case (Top, y1)                              => y1
            case (LongestString(_), Bottom)             => Bottom
            case (LongestString(x1), Top)               => LongestString(x1)    
            case (LongestString(x1), LongestString(y1)) => 
                if (String.length(x1) <= String.length(y1)) LongestString(x1) else Bottom
        }
    }

}
