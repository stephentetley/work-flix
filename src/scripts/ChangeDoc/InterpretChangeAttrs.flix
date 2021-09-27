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


namespace ChangeDoc/InterpretChangeAttrs {

    use RelLib/Lattice/Min.Min;
    use RelLib/Lattice/Min.{min1};

    use RelLib/Lattice/Max.Max;
    use RelLib/Lattice/Max.{max1};

    use ChangeDoc/Datatypes.{ChangeDoc, ChangeRow};
    use ChangeDoc/Datatypes.ChangeRow.{Funcloc1, FunclocLongText, FunclocClass, FunclocChar, 
        Equipment1, EquipmentLongText, EquipmentClass, EquipmentChar};


    pub rel FunclocRow(rowNum: Int32, itemId: String, change: String, attribute: String, newValue : String)
    pub lat FuncLocLast(itemId: String, attribute: String, last: Max[Int32])
    pub lat FuncLocFirst(itemId: String, attribute: String, first: Min[Int32])
    pub rel FunctionalLocation(itemId: String, attrName: String, change: String, value: String)

    pub rel FunclocLongTextRow(rowNum: Int32, itemId: String, language: String, change: String, attribute: String, newValue : String) 
    pub lat FunclocLongTextLast(itemId: String, language: String, attribute: String, last: Max[Int32])

    pub rel EquipmentRow(rowNum: Int32, itemId: String, change: String, attribute: String, newValue : String)
    pub lat EquipmentLast(itemId: String, attribute: String, last: Max[Int32])

    pub rel EquipmentLongTextRow(rowNum: Int32, itemId: String, language: String, change: String, attribute: String, newValue : String) 
    pub lat EquipmentLongTextLast(itemId: String, language: String, attribute: String, last: Max[Int32])

    def makeRowRelations1(x: ChangeRow): #{FunclocRow, EquipmentRow | r} = match x {
        case Funcloc1(rowNum, itemId, attrs) => #{ FunclocRow(rowNum, itemId, attrs.change, attrs.attribute, attrs.newValue). }
        case FunclocLongText(rowNum, itemId, attrs) =>#{ FunclocLongTextRow(rowNum, itemId, attrs.language, attrs.change, attrs.attribute, attrs.newValue). } 
        case Equipment1(rowNum, itemId, attrs) => #{ EquipmentRow(rowNum, itemId, attrs.change, attrs.attribute, attrs.newValue). }
        case EquipmentLongText(rowNum, itemId, attrs) =>#{ EquipmentLongTextRow(rowNum, itemId, attrs.language, attrs.change, attrs.attribute, attrs.newValue). } 
        case _ => #{}
    }

    /// TODO change lattice to Max(rowNum), this will be easier to integrate into subsequent Datalog rules...
    pub def getFuncLocLast(xs: List[ChangeRow]): #{FunctionalLocation | r1} = 
        let db = RelLib/Relation.foldMap(makeRowRelations1, xs);
        let rules = #{
            FuncLocLast(itemId, attrName; max1(rowNum)) :- 
                FunclocRow(rowNum, itemId, _, attrName, _).

            FuncLocFirst(itemId, attrName; min1(rowNum)) :- 
                FunclocRow(rowNum, itemId, _, attrName, _).

            FunctionalLocation1(itemId, attrName, RelLib/Lattice/Min.getValue(first), RelLib/Lattice/Max.getValue(last)) :- 
                FuncLocFirst(itemId, attrName; first), 
                FuncLocLast(itemId, attrName; last). 

            FunctionalLocation(itemId, attrName, changeStatus(changeF, changeL), value) :-
                FunctionalLocation1(itemId, attrName, rowF, rowL),
                FunclocRow(rowF, _, changeF, _, _),
                FunclocRow(rowL, _, changeL, _, value), 
                if not invisible(changeF, changeL).


            FunclocLongTextLast(itemId, language, attrName; max1(rowNum)) :-
                FunclocLongTextRow(rowNum, itemId, language, _, attrName, _).

            EquipmentLast(itemId, attrName; max1(rowNum)) :- 
                EquipmentRow(rowNum, itemId, _, attrName, _).

            EquipmentLongTextLast(itemId, language, attrName; max1(rowNum)) :-
                EquipmentLongTextRow(rowNum, itemId, language, _, attrName, _).
        };
        solve (db <+> rules) project FunctionalLocation

    /// invisible changes are elements created and deleted in the CR, they should not be reported
    def invisible(first: String, last: String): Bool = match (first, last) {
        case ("New", "Changed")  => true
        case (_, _) => false
    }

    def changeStatus(first: String, last: String): String = match (first, last) {
        case (_,            "Deleted")  => "Deleted"
        case ("New",        "Changed")  => "New"
        case ("New",        "New")      => "New"            // first and last are same row
        case ("Changed",    "Changed")  => "Changed"
        case (_,            final)      => final
    }
        


}
