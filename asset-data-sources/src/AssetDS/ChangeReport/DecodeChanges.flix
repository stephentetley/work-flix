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

namespace AssetDS/ChangeReport/DecodeChanges {

    use AssetDS/ChangeReport/Lattice/Max.{Max};
    use AssetDS/ChangeReport/Lattice/Min.{Min};
    use AssetDS/ChangeReport/Relations.{SimpleRow, Change};



    // pub lat FirstChange(cmpkey: String, rowIx: Min[Int32])
    // pub lat LastChange(cmpkey: String, rowIx: Max[Int32])

    pub def decodeChanges[rln: SchemaRow](): #{ SimpleRow, Change | rln} = 
        #(SimpleRow, Change) -> #{

            FirstChange(ckey; min1(ix)) :- 
                SimpleRow(ix, ckey, _, _, _).

            LastChange(ckey; max1(ix)) :- 
                SimpleRow(ix, ckey, _, _, _).

            
            // New, New => New
            Change(ix2, cmpkey, "New", "", v2) :- 
                FirstChange(cmpkey; mrow1),
                LastChange(cmpkey; mrow2),
                SimpleRow(ix1, cmpkey, "New", _, _),
                SimpleRow(ix2, cmpkey, "New", _, v2),
                if mrow1 == min1(ix1) and mrow2 == max1(ix2).

            // New, Changed => New
            Change(ix2, cmpkey, "New", "", v2) :- 
                FirstChange(cmpkey; mrow1),
                LastChange(cmpkey; mrow2),
                SimpleRow(ix1, cmpkey, "New", _, _),
                SimpleRow(ix2, cmpkey, "Changed", _, v2),
                if mrow1 == min1(ix1) and mrow2 == max1(ix2).


            // New, Deleted => Transient
            Change(ix2, cmpkey, "Transient", v2, "") :- 
                FirstChange(cmpkey; mrow1),
                LastChange(cmpkey; mrow2),
                SimpleRow(ix1, cmpkey, "New", _, _),
                SimpleRow(ix2, cmpkey, "Deleted", v2, _),
                if mrow1 == min1(ix1) and mrow2 == max1(ix2).


            // Changed, Changed => Changed
            Change(ix2, cmpkey, "Changed", v1, v2) :- 
                FirstChange(cmpkey; mrow1),
                LastChange(cmpkey; mrow2),
                SimpleRow(ix1, cmpkey, "Changed", v1, _),
                SimpleRow(ix2, cmpkey, "Changed", _, v2),
                if mrow1 == min1(ix1) and mrow2 == max1(ix2).

            // Changed, Deleted => Deleted
            Change(ix2, cmpkey, "Deleted", v1, "") :- 
                FirstChange(cmpkey; mrow1),
                LastChange(cmpkey; mrow2),
                SimpleRow(ix1, cmpkey, "Changed", v1, _),
                SimpleRow(ix2, cmpkey, "Deleted", _, _),
                if mrow1 == min1(ix1) and mrow2 == max1(ix2).

            // Deleted, Deleted => Deleted
            Change(ix2, cmpkey, "Deleted", v1, "") :- 
                FirstChange(cmpkey; mrow1),
                LastChange(cmpkey; mrow2),
                SimpleRow(ix1, cmpkey, "Deleted", v1, _),
                SimpleRow(ix2, cmpkey, "Deleted", _, _),
                if mrow1 == min1(ix1) and mrow2 == max1(ix2).
    }

    /// CAUTION - seem to need a wrapper in same module to use a polymorphic lattice.
    def max1(x: Int32): Max[Int32] = AssetDS/ChangeReport/Lattice/Max.max1(x)

    def min1(x: Int32): Min[Int32] = AssetDS/ChangeReport/Lattice/Min.min1(x)

}
