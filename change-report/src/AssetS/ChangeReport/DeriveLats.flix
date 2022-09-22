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

namespace AssetS/ChangeReport/DeriveLats {

    use AssetS/ChangeReport/Lattice.{Max};
    use AssetS/ChangeReport/Relations.{
        FlocRow, 
        EquiRow, 
        ClassFlocRow,
        ClassEquiRow,
        ValuaFlocRow,
        ValuaEquiRow,
        FlocAddrRow,
        EquiAddrRow,
        FlocLongTextRow,
        EquiLongTextRow, 
        RowRelations, 
        FirstRow,
        LastRow
    };


    pub def deriveLats(): #{ FlocLongTextRow, EquiLongTextRow, LastRow | rln} = #{

        LastRow(uid, "FlocLongTextRow", attrib; wrapMax1(ix)) :-
            FlocLongTextRow(ix, uid, _, _, attrib, _, _).

        LastRow(uid, "EquiLongTextRow", attrib; wrapMax1(ix)) :-
            EquiLongTextRow(ix, uid, _, _, attrib, _, _).

    }

    /// CAUTION - seem to need a wrapper in same module to use polymorphic Max lattice.
    def wrapMax1(x: Int32): Max[Int32] = AssetS/ChangeReport/Lattice.max1(x)

}
