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

namespace AssetS/ChangeReport/Lattice {


    pub enum Max[a] with Eq, Order, ToString, Hash { 
        case Max(a) 
        case MaxBottom
    }



    pub def max(x: a, y: a): Max[a] with Order[a] = Max(Order.max(x, y))
    pub def max1(x: a): Max[a] = Max(x)

    pub def getMax(d: a, x: Max[a]): a = match x{ 
        case Max(i)     => i
        case MaxBottom  => d
    }

    instance PartialOrder[Max[a]] with Order[a] {
        pub def lessEqual(x: Max[a], y: Max[a]): Bool = match (x, y) {
            case (MaxBottom, _)         => true
            case (Max(_), MaxBottom)    => false
            case (Max(x1), Max(y1))     => x1 <= y1
        }
    }


    instance LowerBound[Max[a]] with LowerBound[a] {
        pub def minValue(): Max[a] = MaxBottom
    }

    instance UpperBound[Max[a]] with UpperBound[a] {
        pub def maxValue(): Max[a] = Max(UpperBound.maxValue())
    }


    instance JoinLattice[Max[a]] with Order[a] {
        /// \/
        pub def leastUpperBound(x: Max[a], y: Max[a]): Max[a] = match (x, y) {
            case (MaxBottom, y1)        => y1
            case (x1, MaxBottom)        => x1
            case (Max(x1), Max(y1))     => if (x1 <= y1) Max(y1) else Max(x1)
        }
    }

    instance MeetLattice[Max[a]] with Order[a] {
        /// /\
        pub def greatestLowerBound(x: Max[a], y: Max[a]): Max[a] = 
            match (x, y) {
                case (MaxBottom, _)         => MaxBottom
                case (Max(_), MaxBottom)    => MaxBottom   
                case (Max(x1), Max(y1))     => if (x1 <= y1) Max(x1) else MaxBottom
            }
    }

}
