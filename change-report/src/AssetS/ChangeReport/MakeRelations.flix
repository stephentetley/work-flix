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
        SourceRow,
        SimpleRow
    };


    pub def makeRowRelations[rln: SchemaRow](rows: List[Map[String, String]]): #{SourceRow, SimpleRow | rln} = 
        let db = List.foldLeft((ac, r1) -> ac <+> makeSourceRow(r1), #{}, rows);
        db <+> simpleRows()

    pub def makeSourceRow(m: Map[String, String]): #{SourceRow | rln} = 
        let attrib = getField("Attribute", m);
        let oldValue = getField("Old Value", m) |> s -> if (attrib == "Value from") valueFrom(s) else s;
        let newValue = getField("New Value", m) |> s -> if (attrib == "Value from") valueFrom(s) else s;
        #{ SourceRow( rowIx(m)
                    , getField("Entity Type", m)
                    , getField("Value", m)
                    , getField("Character ID", m)
                    , getField("Class", m)
                    , best("Language", "Language.1", m)
                    , getField("Int counter", m)
                    , best("Address Number", "Address Number.1", m)
                    , getField("Change", m)
                    , attrib
                    , oldValue
                    , newValue
                    , getField("Table", m)
                    ).
        }


    def simpleRows(): #{ SourceRow, SimpleRow | rln} = #{

        // Floc General Data
        SimpleRow(ix, makeKey3("F:GD", itemId, attrib), change, oldValue, newValue) :-
            SourceRow(ix, "Functional Location", itemId, _charId, _clsname, _lang, _ic, _addr, 
                        change, attrib, oldValue, newValue, "Check Table").
    
        // Equi General Data
        SimpleRow(ix, makeKey3("E:GD", itemId, attrib), change, oldValue, newValue) :-
            SourceRow(ix, "Equipment", itemId, _charId, _clsname, _lang, _ic, _addr, 
                        change, attrib, oldValue, newValue, "Check Table").

        // ClassFloc
        SimpleRow(ix, makeKey3("F:CE", itemId, className), change, oldValue, newValue) :- 
            SourceRow(ix, "Functional Location", itemId, _charId, className, _lang, _ic, _addr, 
                        change, "Status", oldValue, newValue, "Table for Relationship CLASSFLOC").

        // ClassEqui
        SimpleRow(ix, makeKey3("E:CE", itemId, className), change, oldValue, newValue) :- 
            SourceRow(ix, "Equipment", itemId, _charId, className, _lang, _ic, _addr,
                        change, "Status", oldValue, newValue, "Table for Relationship CLASSEQUI").

        // ValuaFlocRow - Numeric
        SimpleRow(ix, makeKey4("F:VN", itemId, characterID, intCounter), change, oldValue, newValue) :-
            SourceRow(ix, "Functional Location", itemId, characterID, _clsname, _lang, intCounter, _addr,
                        change, "Value from", oldValue, newValue, "Table for Relationship VALUAFLOC").
    
        // ValuaFlocRow - String
        SimpleRow(ix, makeKey4("F:VS", itemId, characterID, intCounter), change, oldValue, newValue) :-
            SourceRow(ix, "Functional Location", itemId, characterID, _clsname, _lang, intCounter, _addr,
                        change, "Characteristic Value", oldValue, newValue, "Table for Relationship VALUAFLOC").


        // ValuaEquiRow - Numeric
        SimpleRow(ix,  makeKey4("E:VN", itemId, characterID, intCounter), change, oldValue, newValue) :-
            SourceRow(ix, "Equipment", itemId, characterID, _clsname, _lang, intCounter, _addr,
                        change, "Value from", oldValue, newValue, "Table for Relationship VALUAEQUI").
    
        // ValuaEquiRow - String
        SimpleRow(ix,  makeKey4("E:VS", itemId, characterID, intCounter), change, oldValue, newValue) :-
            SourceRow(ix, "Equipment", itemId, characterID, _clsname, _lang, intCounter, _addr,
                        change, "Characteristic Value", oldValue, newValue, "Table for Relationship VALUAEQUI").


        // Floc Address
        SimpleRow(ix, makeKey4("F:AD", itemId, addressNumber, attrib), change, oldValue, newValue) :- 
            SourceRow(ix, "Functional Location", itemId, _charId, _clsname, _lang, _ic, addressNumber, 
                        change, attrib, oldValue, newValue, "Table for Relationship FUNCLOCAD").

        // Equi Address
        SimpleRow(ix, makeKey4("E:AD", itemId, addressNumber, attrib), change, oldValue, newValue) :- 
            SourceRow(ix, "Equipment", itemId, _charId, _clsname, _lang, _ic, addressNumber, 
                        change, attrib, oldValue, newValue, "Table for Relationship EQUIADDR").

        // Floc Long Text 
        SimpleRow(ix, makeKey3("F:LT", itemId, lang), change, oldValue, newValue) :- 
            SourceRow(ix, "Functional Location", itemId, _charId, _clsname, lang, _ic, _addr, 
                        change, "Description (medium text)", oldValue, newValue, "Table for Relationship IFLOTX").

        // Equi Long Text 
        SimpleRow(ix, makeKey3("E:LT", itemId, lang), change, oldValue, newValue) :- 
            SourceRow(ix, "Equipment", itemId, _charId, _clsname, lang, _ic, _addr, 
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

    def numberFormat(): Basis/Text.DecimalFormat = 
        Basis/Text/DecimalFormat.decimalFormatWithLocale("0.0000", Basis/I18n/Locale.us())



    /// TODO - need to use NumberFormat, currently in IO ....
    def valueFrom(s: String): String = 
        match Float64.fromString(s) {
            case Some(d) => Basis/Text/DecimalFormat.formatFloat64(d, numberFormat()) |> Result.getWithDefault(s)
            case None    => s
        }
}
