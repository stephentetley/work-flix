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


namespace AssetLib/Base/OrderedStringsLattice {

    
    /// Special lattice for MemoLines...

    pub enum OrderedStrings(Set[(Int32, String)]) with Eq, Order, ToString, Boxable, Hash

    pub def count(x: OrderedStrings): Int32 = 
        let OrderedStrings(x1) = x;
        Set.size(x1)

    pub def getValue(x: OrderedStrings): String = 
        let OrderedStrings(x1) = x;
        x1 |> Set.toList |> List.sort |> List.map(snd) |> String.unlines

    pub def singleton(ix: Int32, s: String): OrderedStrings = 
        OrderedStrings(Set.singleton((ix, s)))

    instance LowerBound[OrderedStrings] {
        pub def minValue(): OrderedStrings = OrderedStrings(Set.empty())
    }

    instance PartialOrder[OrderedStrings] {
        pub def lessEqual(x: OrderedStrings, y: OrderedStrings): Bool = x <= y
    }


    instance JoinLattice[OrderedStrings] {
        /// \/
        pub def leastUpperBound(x: OrderedStrings, y: OrderedStrings): OrderedStrings = 
            let OrderedStrings(x1) = x;
            let OrderedStrings(y1) = y;
            OrderedStrings(Set.union(x1, y1))
    }

    instance MeetLattice[OrderedStrings] {
        /// /\
        pub def greatestLowerBound(x: OrderedStrings, y: OrderedStrings): OrderedStrings = 
            let OrderedStrings(x1) = x;
            let OrderedStrings(y1) = y;
            OrderedStrings(Set.intersection(x1, y1))
    }

}
