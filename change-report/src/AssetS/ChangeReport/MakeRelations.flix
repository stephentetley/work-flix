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
        SimpleRow
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


    pub def makeRowRelations[rln: SchemaRow](rows: List[Map[String, String]]): #{SimpleRow | rln} = 
        let db = List.foldLeft((ac, r1) -> ac <+> makeCrRow(r1), #{}, rows);
        solve (db <+> simpleRows()) project SimpleRow

    pub def makeCrRow(m: Map[String, String]): #{CrRow | rln} = 
        #{ CrRow( rowIx(m)
                , getField("Entity Type", m)
                , getField("Value", m)
                , getField("Character ID", m)
                , getField("Class", m)
                , best("Language", "Language.1", m)
                , getField("Int counter", m)
                , best("Address Number", "Address Number.1", m)
                , getField("Change", m)
                , getField("Attribute", m)
                , getField("Old Value", m)
                , getField("New Value", m)
                , getField("Table", m)
            ).
        }


    def simpleRows(): #{ CrRow, SimpleRow | rln} = #{

        // Floc General Data
        SimpleRow(ix, makeKey3("F:GD", itemId, attrib), change, oldValue, newValue) :-
            CrRow(ix, "Functional Location", itemId, _charId, _clsname, _lang, _ic, _addr, 
                    change, attrib, oldValue, newValue, "Check Table").
    
        // Equi General Data
        SimpleRow(ix, makeKey3("E:GD", itemId, attrib), change, oldValue, newValue) :-
            CrRow(ix, "Equipment", itemId, _charId, _clsname, _lang, _ic, _addr, 
                    change, attrib, oldValue, newValue, "Check Table").

        // ClassFloc
        SimpleRow(ix, makeKey3("F:CE", itemId, className), change, oldValue, newValue) :- 
            CrRow(ix, "Functional Location", itemId, _charId, className, _lang, _ic, _addr, 
                    change, "Status", oldValue, newValue, "Table for Relationship CLASSFLOC").

        // ClassEqui
        SimpleRow(ix, makeKey3("E:CE", itemId, className), change, oldValue, newValue) :- 
            CrRow(ix, "Equipment", itemId, _charId, className, _lang, _ic, _addr,
                    change, "Status", oldValue, newValue, "Table for Relationship CLASSEQUI").

        // ValuaFlocRow - Numeric
        SimpleRow(ix, makeKey4("F:VN", itemId, characterID, intCounter), change, oldValue, newValue) :-
            CrRow(ix, "Functional Location", itemId, characterID, _clsname, _lang, intCounter, _addr,
                    change, "Value from", oldValue, newValue, "Table for Relationship VALUAFLOC").
    
        // ValuaFlocRow - String
        SimpleRow(ix, makeKey4("F:VS", itemId, characterID, intCounter), change, oldValue, newValue) :-
            CrRow(ix, "Functional Location", itemId, characterID, _clsname, _lang, intCounter, _addr,
                    change, "Characteristic Value", oldValue, newValue, "Table for Relationship VALUAFLOC").


        // ValuaEquiRow - Numeric
        SimpleRow(ix,  makeKey4("E:VN", itemId, characterID, intCounter), change, oldValue, newValue) :-
            CrRow(ix, "Equipment", itemId, characterID, _clsname, _lang, intCounter, _addr,
                    change, "Value from", oldValue, newValue, "Table for Relationship VALUAEQUI").
    
        // ValuaEquiRow - String
        SimpleRow(ix,  makeKey4("E:VS", itemId, characterID, intCounter), change, oldValue, newValue) :-
            CrRow(ix, "Equipment", itemId, characterID, _clsname, _lang, intCounter, _addr,
                    change, "Characteristic Value", oldValue, newValue, "Table for Relationship VALUAEQUI").

        // TODO - friday

        // Floc Address
        SimpleRow(ix, makeKey4("F:AD", itemId, addressNumber, attrib), change, oldValue, newValue) :- 
            CrRow(ix, "Functional Location", itemId, _charId, _clsname, _lang, _ic, addressNumber, 
                    change, attrib, oldValue, newValue, "Table for Relationship FUNCLOCAD").

        // Equi Address
        SimpleRow(ix, makeKey4("E:AD", itemId, addressNumber, attrib), change, oldValue, newValue) :- 
            CrRow(ix, "Equipment", itemId, _charId, _clsname, _lang, _ic, addressNumber, 
                    change, attrib, oldValue, newValue, "Table for Relationship EQUIADDR").

        // Floc Long Text 
        SimpleRow(ix, makeKey3("F:LT", itemId, lang), change, oldValue, newValue) :- 
            CrRow(ix, "Functional Location", itemId, _charId, _clsname, lang, _ic, _addr, 
                    change, "Description (medium text)", oldValue, newValue, "Table for Relationship IFLOTX").

        // Equi Long Text 
        SimpleRow(ix, makeKey3("E:LT", itemId, lang), change, oldValue, newValue) :- 
            CrRow(ix, "Equipment", itemId, _charId, _clsname, lang, _ic, _addr, 
                    change, "Description (medium text)", oldValue, newValue, "Table for Relationship EQMLTXT").


    }


    def makeKey3(entityType: String, itemId: String, s1: String): String = "${entityType}:${itemId}:${s1}"
    
    def makeKey4(entityType: String, itemId: String, s1: String, s2: String): String = "${entityType}:${itemId}:${s1}:${s2}"

    def best(field1: String, field2: String, m: Map[String, String]): String = 
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
