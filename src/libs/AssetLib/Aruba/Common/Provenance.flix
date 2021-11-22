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

    pub rel Provenance(uid: String, label: String, provenance: String)

    /// Generate provenance on base relations
    pub def s4Provenance(source: String): #{S4Floc, S4Equi, Provenance | r1} = #{

        Provenance(funcloc, descr, source) :- S4Floc(funcloc, descr).

        Provenance(equiId, descr, source) :- S4Equi(equiId, descr).
    }

    pub def genS4Provenance(source: String, relns: #{S4Floc, S4Equi | r1}): #{Provenance | r2} = 
        let relns1 = relns as #{S4Floc, S4Equi, Provenance | r1};
        solve relns1 <+> s4Provenance(source) project Provenance



    pub def toSaltTreeTable(printKey: (String, String) -> Creole,
                            printLabel: (String, String) -> Creole,
                            src: #{Site, Function, ProcessGroup, Process, System, Subsystem, Equipment, 
                                    ChildFloc, ChildEqui, Provenance | r}): PlantUml/Puml.Puml =
        let tree1 = match toRoseForest(src) { 
            case t1 :: Nil => t1
            case xs => RoseTree(("Root", "", ""), xs)
        };
        let headers = List.map(PlantUml/Creole.text, "Key" :: "Name" :: Nil);
        PlantUml/SaltTreeTable.treeTable(printCells = xy -> {let (x1, y1, z1) = xy; printKey(x1, z1) :: printLabel(y1, z1) :: Nil}, headers, tree1)


    def toRoseForest(src: #{Site, Function, ProcessGroup, Process, System, Subsystem, Equipment, 
                                ChildFloc, ChildEqui, Provenance | r}): RoseForest[(String, String, String)] =                                
        
        let extractor = 
            { getKey    = RelLib/Tuple.decons5((x, _, _, _, _) -> x)
            , getValue  = RelLib/Tuple.decons5((_, x, y, z, _) -> (x, y, z))
            , getParent = RelLib/Tuple.decons5((_, _, _, _, x) -> x)
            };
        let src1 = src as #{Site, Function, ProcessGroup, Process, System, Subsystem, Equipment, ChildFloc, 
                                ChildEqui, PreorderRow, PreorderRow5, Provenance, HasProvenance | r};
        let db1 = src1 <+> AssetLib/Aruba/S4/Hierarchy.preorderRows() <+> elaborateRows();
        (query db1 select (x1, x2, x3, x4, x5) from PreorderRow5(x1, x2, x3, x4, x5) 
            |> RelLib/UnboundedTree.unboundForest("", extractor)) as & Pure 

    rel PreorderRow5(treeKey: String, uid: String, descr: String, provenance: String, parentKey: String)

    rel HasProvenance(key: String)

    def elaborateRows(): #{Provenance, PreorderRow, PreorderRow5, HasProvenance | r1} = #{
        
        HasProvenance(key: String) :- Provenance(key, _, _).

        PreorderRow5(key: String, uid: String, descr: String, provenance: String, parentKey: String) :- 
            PreorderRow(key, _, uid, descr, parentKey),
            Provenance(uid, _, provenance).
        
        PreorderRow5(key, uid, descr, "Unknown", parentKey) :- 
            PreorderRow(key, _, uid, descr, parentKey),
            not HasProvenance(uid).
    
    }



}
