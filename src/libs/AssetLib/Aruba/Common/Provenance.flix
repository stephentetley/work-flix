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

namespace AssetLib/Aruba/Common/Provenance {

    use Data.RoseForest;
    use Data.RoseTree.RoseTree;    
    use PlantUml/Creole.Creole;

    use AssetLib/Aruba/S4/Base.{S4Floc, S4Equi};
    use AssetLib/Aruba/S4/Hierarchy.{Site, Function, ProcessGroup, Process, System, Subsystem, 
        Equipment, ChildFloc, ChildEqui, PreorderRow};

    /// Provenance needs an explicit Bottom
    pub enum Provenance with Eq, Order, ToString, Hash, Boxable { 
        case Delete
        case New
        case Existing    
        case Bottom
    }

    instance PartialOrder[Provenance] {
        pub def lessEqual(x: Provenance, y: Provenance): Bool = match (x, y) {
            case (Bottom, _)    => true
            case (New, New)   => true
            case (Existing, Existing) => true
            case (_, Delete)    => true
            case _              => false
        }
    }

    instance LowerBound[Provenance] {
        pub def minValue(): Provenance = Bottom
    }

    instance UpperBound[Provenance] {
        pub def maxValue(): Provenance = Delete
    }


    instance JoinLattice[Provenance] {
        /// \/
        pub def leastUpperBound(x: Provenance, y: Provenance): Provenance = match (x, y) {
            case (Bottom, x1)         => x1
            case (x1, Bottom)         => x1
            case (New, New)           => New
            case (New, Existing)      => New
            case (Existing, New)      => New
            case (Existing, Existing) => Existing
            case _                    => Delete
        }
    }

    instance MeetLattice[Provenance] {
        /// /\
        pub def greatestLowerBound(x: Provenance, y: Provenance): Provenance = match (x, y) {
            case (Delete, x1)         => x1
            case (x1, Delete)         => x1
            case (New, New)           => New
            case (New, Existing)      => Existing
            case (Existing, New)      => Existing
            case (Existing, Existing) => Existing
            case _                    => Bottom
        }
    }


    pub lat S4Provenance(uid: String, provenance: Provenance)

    /// Generate provenance on base relations
    pub def s4Provenance(source: Provenance): #{S4Floc, S4Equi, S4Provenance | r1} = #{

        S4Provenance(funcloc; source) :- S4Floc(funcloc, _).

        S4Provenance(equiId; source) :- S4Equi(equiId, _).
    }

    pub def genS4Provenance(source: Provenance, relns: #{S4Floc, S4Equi | r1}): #{S4Provenance | r2} = 
        let relns1 = relns as #{S4Floc, S4Equi, S4Provenance | r1};
        solve relns1 <+> s4Provenance(source) project S4Provenance



    pub def toSaltTreeTable(printKey: (String, Provenance) -> Creole,
                            printLabel: (String, Provenance) -> Creole,
                            src: #{Site, Function, ProcessGroup, Process, System, Subsystem, Equipment, 
                                    ChildFloc, ChildEqui, S4Provenance | r}): PlantUml/Puml.Puml =
        let tree1 = match toRoseForest(src) { 
            case t1 :: Nil => t1
            case xs => RoseTree(("Root", "", Existing), xs)
        };
        let headers = List.map(PlantUml/Creole.text, "Key" :: "Name" :: Nil);
        PlantUml/SaltTreeTable.treeTable(printCells = xy -> {let (x1, y1, z1) = xy; printKey(x1, z1) :: printLabel(y1, z1) :: Nil}, headers, tree1)


    def toRoseForest(src: #{Site, Function, ProcessGroup, Process, System, Subsystem, Equipment, 
                                ChildFloc, ChildEqui, S4Provenance | r}): RoseForest[(String, String, Provenance)] =                                
        
        let extractor = 
            { getKey    = RelLib/Tuple.decons5((x, _, _, _, _) -> x)
            , getValue  = RelLib/Tuple.decons5((_, x, y, _, z) -> (x, y, z))
            , getParent = RelLib/Tuple.decons5((_, _, _, x, _) -> x)
            };
        let src1 = src as #{Site, Function, ProcessGroup, Process, System, Subsystem, Equipment, ChildFloc, 
                                ChildEqui, PreorderRow, PreorderRow5, S4Provenance, HasS4Provenance | r};
        let db1 = src1 <+> AssetLib/Aruba/S4/Hierarchy.preorderRows() <+> elaborateRows();
        (query db1 select (x1, x2, x3, x4; x5) from PreorderRow5(x1, x2, x3, x4; x5) 
            |> RelLib/UnboundedTree.unboundForest("", extractor)) as & Pure 

    lat PreorderRow5(treeKey: String, uid: String, descr: String, parentKey: String, provenance: Provenance)

    rel HasS4Provenance(key: String)

    def elaborateRows(): #{S4Provenance, PreorderRow, PreorderRow5, HasS4Provenance | r1} = #{
        
        HasS4Provenance(key: String) :- S4Provenance(key; _).

        PreorderRow5(key: String, uid: String, descr, parentKey; provenance) :- 
            PreorderRow(key, _, uid, descr, parentKey),
            S4Provenance(uid; provenance).
        
        PreorderRow5(key, uid, descr, parentKey; Existing) :- 
            PreorderRow(key, _, uid, descr, parentKey),
            not HasS4Provenance(uid).
    
    }



}
