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


namespace AssetLib/FileIO/S4/ClassList/Relations2 {

    use RelLib/Lattice/Range.{Range};

    use AssetLib/FileIO/S4/ClassList/EquiParser.{ClassListRow};
    use AssetLib/FileIO/S4/ClassList/EquiParser.ClassListRow.{ClassRow => CClassRow , CharRow => CCharRow, ValueRow};

    pub rel Characteristic(charName: String, className: String, description: String, s4Datatype: String, textLength: Int32, decimalPlaces: Option[Int32])

    pub rel ClassDescription(className: String, description: String)

    /// These are temporarily pub...
    pub rel ClassRow(index: Int32, className: String, description: String)

    pub rel CharRow(index: Int32, charName: String, description: String, s4Datatype: String, textLength: Int32, decimalPlaces: Option[Int32])

    // TODO "picklists"

    pub rel Successor(className: String, succClassName: String)

    pub lat ClassRange(className: String, range: Range)


    pub def equiClassRelations(src: System.FilePath): Result[#{Characteristic, ClassDescription | r}, String] & Impure = 
        use Result.flatMap;
        let* rows   = AssetLib/FileIO/S4/ClassList/EquiParser.parseFile(src);
        let db      = makeRows(rows) <+> makeSuccesors(rows);        
        println("Successor");
        let _       = query (db) select (x1, x2) from Successor(x1, x2) |> Array.foreach(println);
        println("ClassRange");
        let _       = query (db <+> rules()) select (x1, x2) from ClassRange(x1; x2) |> Array.foreach(println);
        let ans     = solve (db <+> rules()) project Characteristic, ClassDescription;
        Ok(ans)

    def rules(): #{Characteristic, ClassDescription, ClassRow, CharRow, Successor, ClassRange | r} = #{

        ClassDescription(name, descr) :- ClassRow(_, name, descr).

        Characteristic(name, className, descr, s4Type, textLen, decimalPlaces) :- 
            CharRow(idx, name, descr, s4Type, textLen, decimalPlaces),
            ClassRange(className; rng),
            if RelLib/Lattice/Range.inRange(idx, rng).

        ClassRange(className; RelLib/Lattice/Range.range(start, next-1)) :-
            ClassRow(start, className, _),
            Successor(className, successor),
            ClassRow(next, successor, _).

    }

    
    def makeRows(xs: List[ClassListRow]): #{CharRow, ClassRow | r} = 
        use AssetLib/FileIO/S4/ClassList/Datatypes.{s4TypeName, s4StorageSize, s4DecimalPlaces};
        let step = (x, ix) -> match x {
            case CClassRow(r1) => #{ ClassRow(ix, r1.name, r1.description). }
            case CCharRow(r1)  => #{ CharRow(ix, r1.name, r1.description, r1.chartype, r1.textLength, r1.decimalPlaces). }
            case _             => #{}
        };
        RelLib/Relation.foldMapWithIndex(step, xs)

    def makeSuccesors(xs: List[ClassListRow]): #{Successor | r} = 
        let step = (reln, s1, x) -> match x {
            case CClassRow(r1) => if (String.isEmpty(s1)) (reln, r1.name) else (reln <+> #{ Successor(s1, r1.name). }, r1.name)
            case _             => (reln, s1)
        };
        Foldable.foldLeft((acc, x) -> {let (r1, s1) = acc; step(r1, s1, x)}, (#{}, ""), xs) |> fst


}
