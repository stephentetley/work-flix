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


    rel FunclocRow(rowNum: Int32, itemId: String, change: String, attribute: String, newValue : String)
    lat FunclocFirst(itemId: String, attribute: String, first: Min[Int32])
    lat FunclocLast(itemId: String, attribute: String, last: Max[Int32])
    rel FunclocTemp(itemId : String, attrName: String, firstRow: Int32, lastRow: Int32)
    pub rel FunclocChange(itemId: String, attrName: String, change: String, value: String)

    rel FlocLongTextRow(rowNum: Int32, itemId: String, language: String, change: String, attribute: String, newValue : String) 
    lat FlocLongTextFirst(itemId: String, language: String, attribute: String, first: Min[Int32])
    lat FlocLongTextLast(itemId: String, language: String, attribute: String, last: Max[Int32])
    rel FlocLongTextTemp(itemId : String, language: String, attrName: String, firstRow: Int32, lastRow: Int32)
    pub rel FlocLongTextChange(itemId: String, language: String, attrName: String, change: String, value: String)

    /// Is Attribute always "Status"?
    rel FlocClassRow(rowNum: Int32, itemId: String, className: String, classType: String, change: String, attribute: String, newValue: String) 
    lat FlocClassFirst(itemId: String, className: String, classType: String, attribute: String, first: Min[Int32])
    lat FlocClassLast(itemId: String, className: String, classType: String, attribute: String, last: Max[Int32])
    rel FlocClassTemp(itemId : String, className: String, classType: String, attrName: String, firstRow: Int32, lastRow: Int32)
    pub rel FlocClassChange(itemId: String, className: String, classType: String, attrName: String, change: String, value: String)

    pub rel FlocCharRow(rowNum: Int32, itemId: String, charName: String, classType: String, intCounter: Int32, change: String, attribute: String, newValue: String) 
    pub lat FlocCharFirst(itemId: String, charName: String, classType: String, intCounter: Int32, attribute: String, first: Min[Int32])
    pub lat FlocCharLast(itemId: String, charName: String, classType: String, intCounter: Int32, attribute: String, last: Max[Int32])
    pub rel FlocCharTemp(itemId : String, charName: String, classType: String, intCounter: Int32, attrName: String, firstRow: Int32, lastRow: Int32)
    pub rel FlocCharChange(itemId: String, charName: String, classType: String, intCounter: Int32, attrName: String, change: String, value: String)


    rel EquipmentRow(rowNum: Int32, itemId: String, change: String, attribute: String, newValue : String)
    lat EquipmentFirst(itemId: String, attribute: String, first: Min[Int32])
    lat EquipmentLast(itemId: String, attribute: String, last: Max[Int32])
    rel EquipmentTemp(itemId : String, attrName: String, firstRow: Int32, lastRow: Int32)
    pub rel EquipmentChange(itemId: String, attrName: String, change: String, value: String)

    rel EquiLongTextRow(rowNum: Int32, itemId: String, language: String, change: String, attribute: String, newValue : String) 
    lat EquiLongTextFirst(itemId: String, language: String, attribute: String, first: Min[Int32])
    lat EquiLongTextLast(itemId: String, language: String, attribute: String, last: Max[Int32])
    rel EquiLongTextTemp(itemId : String, language: String,attrName: String, firstRow: Int32, lastRow: Int32)
    pub rel EquiLongTextChange(itemId: String, language: String,attrName: String, change: String, value: String)

    rel EquiClassRow(rowNum: Int32, itemId: String, className: String, classType: String, change: String, attribute: String, newValue: String) 
    lat EquiClassFirst(itemId: String, className: String, classType: String, attribute: String, first: Min[Int32])
    lat EquiClassLast(itemId: String, className: String, classType: String, attribute: String, last: Max[Int32])
    rel EquiClassTemp(itemId : String, className: String, classType: String, attrName: String, firstRow: Int32, lastRow: Int32)
    pub rel EquiClassChange(itemId: String, className: String, classType: String, attrName: String, change: String, value: String)

    rel EquiCharRow(rowNum: Int32, itemId: String, charName: String, classType: String, intCounter: Int32, change: String, attribute: String, newValue: String) 
    lat EquiCharFirst(itemId: String, charName: String, classType: String, intCounter: Int32, attribute: String, first: Min[Int32])
    lat EquiCharLast(itemId: String, charName: String, classType: String, intCounter: Int32, attribute: String, last: Max[Int32])
    rel EquiCharTemp(itemId : String, charName: String, classType: String, intCounter: Int32, attrName: String, firstRow: Int32, lastRow: Int32)
    pub rel EquiCharChange(itemId: String, charName: String, classType: String, intCounter: Int32, attrName: String, change: String, value: String)

    def makeRowRelations1(x: ChangeRow): #{FunclocRow, FlocLongTextRow, FlocClassRow, FlocCharRow,
                                            EquipmentRow, EquiLongTextRow, EquiClassRow, EquiCharRow | r} = match x {
        case Funcloc1(rowNum, itemId, attrs) => #{ FunclocRow(rowNum, itemId, attrs.change, attrs.attribute, attrs.newValue). }
        case FunclocLongText(rowNum, itemId, attrs) => #{ FlocLongTextRow(rowNum, itemId, attrs.language, attrs.change, attrs.attribute, attrs.newValue). } 
        case FunclocClass(rowNum, itemId, attrs) => #{ FlocClassRow(rowNum, itemId, attrs.className, attrs.classType, attrs.change, attrs.attribute, attrs.newValue). } 
        case FunclocChar(rowNum, itemId, attrs) => #{ FlocCharRow(rowNum, itemId, attrs.charId, attrs.classType, attrs.intCounter, attrs.change, attrs.attribute, attrs.newValue). } 
        
        case Equipment1(rowNum, itemId, attrs) => #{ EquipmentRow(rowNum, itemId, attrs.change, attrs.attribute, attrs.newValue). }
        case EquipmentLongText(rowNum, itemId, attrs) => #{ EquiLongTextRow(rowNum, itemId, attrs.language, attrs.change, attrs.attribute, attrs.newValue). } 
        case EquipmentClass(rowNum, itemId, attrs) => #{ EquiClassRow(rowNum, itemId, attrs.className, attrs.classType, attrs.change, attrs.attribute, attrs.newValue). } 
        case EquipmentChar(rowNum, itemId, attrs) => #{ EquiCharRow(rowNum, itemId, attrs.charId, attrs.classType, attrs.intCounter, attrs.change, attrs.attribute, attrs.newValue). } 
    }

    /// Lattices are internal...
    pub def interpretChanges(xs: List[ChangeRow]): #{FunclocChange, FlocLongTextChange, FlocClassChange, FlocCharChange,
                                                        EquipmentChange, EquiLongTextChange, EquiClassChange, EquiCharChange | r1} = 
        let db = RelLib/Relation.foldMap(makeRowRelations1, xs);
        let rules = #{

            /// Funcloc
            FunclocFirst(itemId, attrName; min1(rowNum)) :- 
                FunclocRow(rowNum, itemId, _, attrName, _).

            FunclocLast(itemId, attrName; max1(rowNum)) :- 
                FunclocRow(rowNum, itemId, _, attrName, _).

            FunclocTemp(itemId, attrName, RelLib/Lattice/Min.getValue(first), RelLib/Lattice/Max.getValue(last)) :- 
                FunclocFirst(itemId, attrName; first), 
                FunclocLast(itemId, attrName; last). 

            FunclocChange(itemId, attrName, changeStatus(changeF, changeL), value) :-
                FunclocTemp(itemId, attrName, rowF, rowL),
                FunclocRow(rowF, _, changeF, _, _),
                FunclocRow(rowL, _, changeL, _, value), 
                if not invisible(changeF, changeL).

            /// Floc long text
            FlocLongTextFirst(itemId, language, attrName; min1(rowNum)) :-
                FlocLongTextRow(rowNum, itemId, language, _, attrName, _).

            FlocLongTextLast(itemId, language, attrName; max1(rowNum)) :-
                FlocLongTextRow(rowNum, itemId, language, _, attrName, _).

            FlocLongTextTemp(itemId, language, attrName, RelLib/Lattice/Min.getValue(first), RelLib/Lattice/Max.getValue(last)) :- 
                FlocLongTextFirst(itemId, language, attrName; first), 
                FlocLongTextLast(itemId, language, attrName; last). 

            FlocLongTextChange(itemId, language, attrName, changeStatus(changeF, changeL), value) :-
                FlocLongTextTemp(itemId, language, attrName, rowF, rowL),
                FlocLongTextRow(rowF, _, _, changeF, _, _),
                FlocLongTextRow(rowL, _, _, changeL, _, value), 
                if not invisible(changeF, changeL).

            /// Floc Class
            FlocClassFirst(itemId, className, classType, attrName; min1(rowNum)) :-
                FlocClassRow(rowNum, itemId, className, classType, _, attrName, _).

            FlocClassLast(itemId, className, classType, attrName; max1(rowNum)) :-
                FlocClassRow(rowNum, itemId, className, classType, _, attrName, _).

            FlocClassTemp(itemId, className, classType, attrName, RelLib/Lattice/Min.getValue(first), RelLib/Lattice/Max.getValue(last)) :- 
                FlocClassFirst(itemId, className, classType, attrName; first), 
                FlocClassLast(itemId, className, classType, attrName; last). 

            FlocClassChange(itemId, className, classType, attrName, changeStatus(changeF, changeL), value) :-
                FlocClassTemp(itemId, className, classType, attrName, rowF, rowL),
                FlocClassRow(rowF, _, _, _, changeF, _, _),
                FlocClassRow(rowL, _, _, _, changeL, _, value), 
                if not invisible(changeF, changeL).

            /// Floc Char
            FlocCharFirst(itemId, charName, classType, intCounter, attrName; min1(rowNum)) :-
                FlocCharRow(rowNum, itemId, charName, classType, intCounter, _, attrName, _).

            FlocCharLast(itemId, charName, classType, intCounter, attrName; max1(rowNum)) :-
                FlocCharRow(rowNum, itemId, charName, classType, intCounter, _, attrName, _).

            FlocCharTemp(itemId, charName, classType, intCounter, attrName, RelLib/Lattice/Min.getValue(first), RelLib/Lattice/Max.getValue(last)) :- 
                FlocCharFirst(itemId, charName, classType, intCounter, attrName; first), 
                FlocCharLast(itemId, charName, classType, intCounter, attrName; last). 

            FlocCharChange(itemId, charName, classType, intCounter, attrName, changeStatus(changeF, changeL), value) :-
                FlocCharTemp(itemId, charName, classType, intCounter, attrName, rowF, rowL),
                FlocCharRow(rowF, _, _, _, _, changeF, _, _),
                FlocCharRow(rowL, _, _, _, _, changeL, _, value), 
                if not invisible(changeF, changeL).

            /// Equipment
            EquipmentFirst(itemId, attrName; min1(rowNum)) :- 
                EquipmentRow(rowNum, itemId, _, attrName, _).

            EquipmentLast(itemId, attrName; max1(rowNum)) :- 
                EquipmentRow(rowNum, itemId, _, attrName, _).

            EquipmentTemp(itemId, attrName, RelLib/Lattice/Min.getValue(first), RelLib/Lattice/Max.getValue(last)) :- 
                EquipmentFirst(itemId, attrName; first), 
                EquipmentLast(itemId, attrName; last). 

            EquipmentChange(itemId, attrName, changeStatus(changeF, changeL), value) :-
                EquipmentTemp(itemId, attrName, rowF, rowL),
                EquipmentRow(rowF, _, changeF, _, _),
                EquipmentRow(rowL, _, changeL, _, value), 
                if not invisible(changeF, changeL).

            /// Equi long text
            EquiLongTextFirst(itemId, language, attrName; min1(rowNum)) :-
                EquiLongTextRow(rowNum, itemId, language, _, attrName, _).

            EquiLongTextLast(itemId, language, attrName; max1(rowNum)) :-
                EquiLongTextRow(rowNum, itemId, language, _, attrName, _).

            EquiLongTextTemp(itemId, language, attrName, RelLib/Lattice/Min.getValue(first), RelLib/Lattice/Max.getValue(last)) :- 
                EquiLongTextFirst(itemId, language, attrName; first), 
                EquiLongTextLast(itemId, language, attrName; last). 

            EquiLongTextChange(itemId, language, attrName, changeStatus(changeF, changeL), value) :-
                EquiLongTextTemp(itemId, language, attrName, rowF, rowL),
                EquiLongTextRow(rowF, _, _, changeF, _, _),
                EquiLongTextRow(rowL, _, _, changeL, _, value), 
                if not invisible(changeF, changeL).
            
            /// Equi Class
            EquiClassFirst(itemId, className, classType, attrName; min1(rowNum)) :-
                EquiClassRow(rowNum, itemId, className, classType, _, attrName, _).

            EquiClassLast(itemId, className, classType, attrName; max1(rowNum)) :-
                EquiClassRow(rowNum, itemId, className, classType, _, attrName, _).

            EquiClassTemp(itemId, className, classType, attrName, RelLib/Lattice/Min.getValue(first), RelLib/Lattice/Max.getValue(last)) :- 
                EquiClassFirst(itemId, className, classType, attrName; first), 
                EquiClassLast(itemId, className, classType, attrName; last). 

            EquiClassChange(itemId, className, classType, attrName, changeStatus(changeF, changeL), value) :-
                EquiClassTemp(itemId, className, classType, attrName, rowF, rowL),
                EquiClassRow(rowF, _, _, _, changeF, _, _),
                EquiClassRow(rowL, _, _, _, changeL, _, value), 
                if not invisible(changeF, changeL).

            /// Equi Char
            EquiCharFirst(itemId, charName, classType, intCounter, attrName; min1(rowNum)) :-
                EquiCharRow(rowNum, itemId, charName, classType, intCounter, _, attrName, _).

            EquiCharLast(itemId, charName, classType, intCounter, attrName; max1(rowNum)) :-
                EquiCharRow(rowNum, itemId, charName, classType, intCounter, _, attrName, _).

            EquiCharTemp(itemId, charName, classType, intCounter, attrName, RelLib/Lattice/Min.getValue(first), RelLib/Lattice/Max.getValue(last)) :- 
                EquiCharFirst(itemId, charName, classType, intCounter, attrName; first), 
                EquiCharLast(itemId, charName, classType, intCounter, attrName; last). 

            EquiCharChange(itemId, charName, classType, intCounter, attrName, changeStatus(changeF, changeL), value) :-
                EquiCharTemp(itemId, charName, classType, intCounter, attrName, rowF, rowL),
                EquiCharRow(rowF, _, _, _, _, changeF, _, _),
                EquiCharRow(rowL, _, _, _, _, changeL, _, value), 
                if not invisible(changeF, changeL).

        };
        solve (db <+> rules) project FunclocChange, FlocLongTextChange, FlocClassChange, FlocCharChange,
                                        EquipmentChange, EquiLongTextChange, EquiClassChange, EquiCharChange

    /// invisible changes are elements created and deleted in the CR, they should not be reported
    def invisible(first: String, last: String): Bool = match (first, last) {
        case ("New", "Deleted")  => true
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
