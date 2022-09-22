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

namespace AssetS/ChangeReport/MakeRelations {


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
        RowRelations
    };

    pub rel CrRow(rowIx: Int32,
                    entityType: String, 
                    table: String,
                    attrib: String, 
                    uid: String, 
                    charId: String, 
                    className: String, 
                    addressNumber: String, 
                    language: String, 
                    intCounter: String, 
                    change: String, 
                    oldValue: String, 
                    newValue: String)


    pub def makeRowRelations(rows: List[Map[String, String]]): RowRelations[rln] = 
        let db = List.foldLeft((ac, r1) -> ac <+> makeCrRow(r1), #{}, rows);
        db <+> translate()

    pub def makeCrRow(m: Map[String, String]): #{CrRow | rln} = 
        #{ CrRow( rowIx(m)
                , getField("Entity Type", m)
                , getField("Table", m)
                , getField("Attribute", m)
                , getField("Value", m)
                , getField("Character ID", m)
                , getField("Class", m)
                , best("Address Number", "Address Number.1", m)
                , best("Language", "Language.1", m)
                , getField("Int counter", m)
                , getField("Change", m)
                , getField("Old Value", m)
                , getField("New Value", m)
            ).
        }


    pub def translate(): #{ CrRow, FlocRow, EquiRow, ClassFlocRow, ClassEquiRow, 
                                ValuaFlocRow, ValuaEquiRow, FlocAddrRow, EquiAddrRow,
                                FlocLongTextRow, EquiLongTextRow | rln} = #{

        FlocRow(ix, uid, change, attrib, oldValue, newValue) :-
            CrRow(ix, "Functional Location", "Check Table", attrib, uid, _, _, _, _, _, change, oldValue, newValue).

        EquiRow(ix, uid, change, attrib, oldValue, newValue) :-
            CrRow(ix, "Equipment", "Check Table", attrib, uid, _, _, _, _, _, change, oldValue, newValue).

        ClassFlocRow(ix, uid, className, change, oldValue, newValue) :- 
            CrRow(ix, "Functional Location", "Table for Relationship CLASSFLOC", "Functional Location", 
                    uid, _, className, _, _, _, change, oldValue, newValue).

        ClassEquiRow(ix, uid, className, change, oldValue, newValue) :- 
            CrRow(ix, "Equipment", "Table for Relationship CLASSEQUI", "Equipment", 
                    uid, _, className, _, _, _, change, oldValue, newValue).

        // ValuaFlocRow - Numeric
        ValuaFlocRow(ix, uid, characterID, intCounter, change, oldValue, newValue) :-
            CrRow(ix, "Functional Location", "Table for Relationship VALUAFLOC", "Value from", 
                    uid, characterID, _, _, _, intCounter, change, oldValue, newValue).
    
        // ValuaFlocRow - String
        ValuaFlocRow(ix, uid, characterID, intCounter, change, oldValue, newValue) :-
            CrRow(ix, "Functional Location", "Table for Relationship VALUAFLOC", "Characteristic Value", 
                    uid, characterID, _, _, _, intCounter, change, oldValue, newValue).


        // ValuaEquiRow - Numeric
        ValuaEquiRow(ix, uid, characterID, intCounter, change, oldValue, newValue) :-
            CrRow(ix, "Equipment", "Table for Relationship VALUAEQUI", "Value from", 
                    uid, characterID, _, _, _, intCounter, change, oldValue, newValue).
    
        // ValuaEquiRow - String
        ValuaEquiRow(ix, uid, characterID, intCounter, change, oldValue, newValue) :-
            CrRow(ix, "Equipment", "Table for Relationship VALUAEQUI", "Characteristic Value", 
                    uid, characterID, _, _, _, intCounter, change, oldValue, newValue).

        // Address

        FlocAddrRow(ix, uid, addressNumber, change, attrib, oldValue, newValue) :- 
            CrRow(ix, "Functional Location", "Table for Relationship FUNCLOCAD", attrib, 
                    uid, _, _, addressNumber, _, _, change, oldValue, newValue).

        EquiAddrRow(ix, uid, addressNumber, change, attrib, oldValue, newValue) :- 
            CrRow(ix, "Equipment", "Table for Relationship EQUIADDR", attrib, 
                    uid, _, _, addressNumber, _, _, change, oldValue, newValue).

        // Long Text 

        FlocLongTextRow(ix, uid, language, change, attrib, oldValue, newValue) :- 
            CrRow(ix, "Functional Location", "Table for Relationship IFLOTX", attrib, 
                    uid, _, _, _, language, _, change, oldValue, newValue).

        EquiLongTextRow(ix, uid, language, change, attrib, oldValue, newValue) :- 
            CrRow(ix, "Equipment", "Table for Relationship EQMLTXT", attrib, 
                    uid, _, _, _, language, _, change, oldValue, newValue).

    }


    pub def best(field1: String, field2: String, m: Map[String, String]): String = 
        match (Map.get(field1, m), Map.get(field2, m)) {
            case (Some(s1), Some(s2))   => if (String.isEmpty(s1)) s2 else s1
            case (Some(s1), _)          => s1
            case (_, Some(s2))          => s2
            case (_, _)                 => ""
        }

    def rowIx(m: Map[String, String]): Int32 = 
        Map.get("RowIx", m) |> Option.flatMap(Int32.fromString) |> Option.getWithDefault(-1)

    def getField(name: String, m: Map[String, String]): String = 
        Map.get(name, m) |> Option.getWithDefault("")

}
