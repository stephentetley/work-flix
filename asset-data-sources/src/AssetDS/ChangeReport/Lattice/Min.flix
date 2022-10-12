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

namespace AssetDS/ChangeReport/Lattice/Min {


    pub enum Min[a] with Eq, Order, ToString, Hash { 
        case Min(a) 
        case MinTop        
    }



    pub def min(x: a, y: a): Min[a] with Order[a] = Min(Order.min(x, y))
    pub def min1(x: a): Min[a] = Min(x)

    pub def getMin(d: a, x: Min[a]): a = match x{ 
        case Min(i) => i
        case MinTop => d
    }

    instance PartialOrder[Min[a]] with Order[a] {
        pub def lessEqual(x: Min[a], y: Min[a]): Bool = match (x, y) {
            case (_, MinTop)         => true
            case (MinTop, Min(_))    => false
            case (Min(x1), Min(y1))  => x1 <= y1
        }
    }


    instance LowerBound[Min[a]] with LowerBound[a] {
        pub def minValue(): Min[a] = Min(LowerBound.minValue())
    }

    instance UpperBound[Min[a]] with UpperBound[a] {
        pub def maxValue(): Min[a] = MinTop
    }


    instance JoinLattice[Min[a]] with Order[a] {
        /// \/
        pub def leastUpperBound(x: Min[a], y: Min[a]): Min[a] = match (x, y) {
            case (MinTop, y1)       => y1
            case (x1, MinTop)       => x1
            case (Min(x1), Min(y1)) => if (x1 <= y1) Min(x1) else Min(y1)
        }
    }

    instance MeetLattice[Min[a]] with Order[a] {
        /// /\
        pub def greatestLowerBound(x: Min[a], y: Min[a]): Min[a] = 
            match (x, y) {
                case (MinTop, _)         => MinTop
                case (Min(_), MinTop)    => MinTop
                case (Min(x1), Min(y1))  => if (x1 <= y1) Min(x1) else MinTop
            }
    }

}
