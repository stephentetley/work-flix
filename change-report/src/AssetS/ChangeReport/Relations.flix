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

namespace AssetS/ChangeReport/Relations {

    use AssetS/ChangeReport/Lattice.{Max};

    pub rel FlocRow(rowIx: Int32, uid: String, change: String, attrib: String, oldValue: String, newValue: String)
    pub rel EquiRow(rowIx: Int32, uid: String, change: String, attrib: String, oldValue: String, newValue: String)
    pub rel ClassFlocRow(rowIx: Int32, uid: String, className: String, change: String, oldValue: String, newValue: String)
    pub rel ClassEquiRow(rowIx: Int32, uid: String, className: String, change: String, oldValue: String, newValue: String)
    pub rel ValuaFlocRow(rowIx: Int32, uid: String, characterID: String, intCounter: String, change: String, oldValue: String, newValue: String)
    pub rel ValuaEquiRow(rowIx: Int32, uid: String, characterID: String, intCounter: String, change: String, oldValue: String, newValue: String)
    pub rel FlocAddrRow(rowIx: Int32, uid: String, addressNumber: String, change: String, attrib: String, oldValue: String, newValue: String)
    pub rel EquiAddrRow(rowIx: Int32, uid: String, addressNumber: String, change: String, attrib: String, oldValue: String, newValue: String)
    pub rel FlocLongTextRow(rowIx: Int32, uid: String, language: String, change: String, attrib: String, oldValue: String, newValue: String)
    
    pub rel EquiLongTextRow(rowIx: Int32, uid: String, language: String, change: String, attrib: String, oldValue: String, newValue: String)


    pub type alias RowRelations[rln: SchemaRow] = #{ FlocRow, EquiRow, ClassFlocRow, ClassEquiRow, 
                                ValuaFlocRow, ValuaEquiRow, FlocAddrRow, EquiAddrRow,
                                FlocLongTextRow, EquiLongTextRow | rln}


    pub lat FirstRow(uid: String, rowType: String, attrib: String, rowIx: Max[Int32])
    pub lat LastRow(uid: String, rowType: String, attrib: String, rowIx: Max[Int32])


}
