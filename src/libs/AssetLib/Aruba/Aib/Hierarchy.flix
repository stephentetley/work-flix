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

namespace AssetLib/Aruba/Aib/Hierarchy {

    use Data.RoseForest;
    use Data.RoseTree.RoseTree;
    use AssetLib/Aruba/Aib/Base.{AibFloc, AibEqui, AibSubFloc, AibSubEqui, AibFlocLevel, AibEquiType};


    /// Note - we want to represent partial hierarchies (i.e. not starting from Installation), 
    /// so we still have separate relations for Parent/Child.
    /// Similarly we may not have full type information so types are separate relations.


    pub rel Installation(sainum: String, commonName: String, name: String)
    
    pub rel SubInstallation(sainum: String, commonName: String, name: String)

    pub rel ProcessGroup(sainum: String, commonName: String, name: String)

    pub rel Process(sainum: String, commonName: String, name: String)

    pub rel Plant(sainum: String, commonName: String, name: String)

    /// Level 6 - e.g "Heating Unit", "Pump Assembly"
    pub rel PlantItem(sainum: String, commonName: String, name: String)

    pub rel Equipment(equiId: String, commonName: String, equiType: String)

    /// Floc childOf relation
    pub rel ChildFloc(parentFlocId: String, childFlocId: String)

    pub rel EquiType(equiId: String, equitype: String)

    pub rel CommonName(sainum: String, commonName: String)

    /// Translation is input source specific, we rely on S4 specific site levels, etc.
    pub def fromAibBaseRelations(input: #{AibFloc, AibEqui, AibSubFloc, AibSubEqui, AibFlocLevel, AibEquiType | r}): 
                            #{Installation, SubInstallation, ProcessGroup, Process, Plant, PlantItem, 
                                Equipment, ChildFloc, EquiType, CommonName | r1} = 
        let rules = #{
            Installation(sainum, commonName, name):- 
                AibFloc(sainum, commonName, name),
                AibFlocLevel(sainum, "Installation").

            SubInstallation(sainum, commonName, name):- 
                AibFloc(sainum, commonName, name),
                AibFlocLevel(sainum, "Sub_Installation").

            ProcessGroup(sainum, commonName, name):- 
                AibFloc(sainum, commonName, name),
                AibFlocLevel(sainum, "Process_Group").

            Process(sainum, commonName, name):- 
                AibFloc(sainum, commonName, name),
                AibFlocLevel(sainum, "Process").

            Plant(sainum, commonName, name):- 
                AibFloc(sainum, commonName, name),
                AibFlocLevel(sainum, "Plant").

            PlantItem(sainum, commonName, name):- 
                AibFloc(sainum, commonName, name),
                AibFlocLevel(sainum, "Plant_Item").

            Equipment(equiId, commonName, equiType) :- 
                AibEqui(equiId, commonName, equiType).

            EquiType(equiId, tyname) :- AibEquiType(equiId, tyname).

            ChildFloc(parent: String, child) :- 
                AibSubFloc(parent, child).

            CommonName(sainum, commonName) :- AibFloc(sainum, commonName, _).


        };
        let input1 = input as #{AibFloc, AibEqui, AibSubFloc, AibSubEqui, AibFlocLevel, AibEquiType,  
                                    Installation, SubInstallation, ProcessGroup, Process, Plant, PlantItem, Equipment, ChildFloc, EquiType, CommonName | r};
        solve input1 <+> rules project Installation, SubInstallation, ProcessGroup, Process, Plant, PlantItem, Equipment, ChildFloc, EquiType, CommonName



    /// toPlantUml / RoseTree

    pub rel PreorderRow(treeKey: String, flocOrEqui: String, uid: String, descr: String, parentKey: String)

    pub rel HasParent(commonName: String)

    /// Note - can "map" the array of PreorderRows, elaborating the uid to a more descriptive type.
    pub def preorderRows(): #{Installation, SubInstallation, ProcessGroup, Process, Plant, PlantItem, 
                                Equipment, ChildFloc, CommonName, PreorderRow | r1} = #{


        HasParent(refnum) :- ChildFloc(_, refnum).

        /// Unbounded tree - including equipment at various levels and subequipment.
        
        /// Installation is root
        PreorderRow(flocKey(commonName), "FLOC", refnum, name, "") :- 
            Installation(refnum, commonName, name).

        
        /// SubInstallation is root
        PreorderRow(flocKey(commonName), "FLOC", refnum, name, "") :- 
            SubInstallation(refnum, commonName, name),
            not HasParent(refnum).
        
        /// SubInstallation is not root
        PreorderRow(flocKey(commonName), "FLOC", refnum, name, flocKey(parentName)) :- 
            SubInstallation(refnum, commonName, name),
            ChildFloc(parentRef, refnum),
            CommonName(parentRef, parentName).


        /// ProcessGroup is root
        PreorderRow(flocKey(commonName), "FLOC", refnum, name, "") :- 
            ProcessGroup(refnum, commonName, name), 
            not HasParent(refnum).

        /// ProcessGroup is not root
        PreorderRow(flocKey(commonName), "FLOC", refnum, name, flocKey(parentName)) :- 
            ProcessGroup(refnum, commonName, name),
            ChildFloc(parentRef, refnum),
            CommonName(parentRef, parentName).

        
        /// Process is root
        PreorderRow(flocKey(commonName), "FLOC", refnum, name, "") :- 
            Process(refnum, commonName, name), 
            not HasParent(refnum).

        /// Process is not root
        PreorderRow(flocKey(commonName), "FLOC", refnum, name, flocKey(parentName)) :- 
            Process(refnum, commonName, name),
            ChildFloc(parentRef, refnum),
            CommonName(parentRef, parentName).

        
        /// Plant is root
        PreorderRow(flocKey(commonName), "FLOC", refnum, name, "") :- 
            Plant(refnum, commonName, name), 
            not HasParent(refnum).

        /// Plant is not root
        PreorderRow(flocKey(commonName), "FLOC", refnum, name, flocKey(parentName)) :- 
            Plant(refnum, commonName, name),
            ChildFloc(parentRef, refnum),
            CommonName(parentRef, parentName).
        
        /// PlantItem is root
        PreorderRow(flocKey(commonName), "FLOC", refnum, name, "") :- 
            PlantItem(refnum, commonName, name), 
            not HasParent(refnum).

        /// PlantItem is not root
        PreorderRow(flocKey(commonName), "FLOC", refnum, name, flocKey(parentName)) :- 
            PlantItem(refnum, commonName, name),
            ChildFloc(parentRef, refnum),
            CommonName(parentRef, parentName).

        /// EQuipment
        PreorderRow(commonName, "EQUI", refnum, typeName, equiParentKey(commonName)) :- 
            Equipment(refnum, commonName, typeName). 

    }

    def flocKey(commonName: String): String = "${commonName}/"

    def equiParentKey(commonName: String): String = 
        let (s1, s2) = String.breakOnLeft(substr = "/EQUIPMENT:", commonName);
        if (not String.isEmpty(s2)) 
            "${s1}/"
        else {
            let (t1, _) = String.breakOnLeft(substr = "EQPT:", commonName);
            "${t1}/"
        }

    pub def toRoseForest(src: #{Installation, SubInstallation, ProcessGroup, Process, Plant, PlantItem, 
                                Equipment, ChildFloc, CommonName | r}): RoseForest[(String, String)] =                                
        
        let extractor = 
            { getKey    = RelLib/Tuple.decons5((x, _, _, _, _) -> x)
            , getValue  = RelLib/Tuple.decons5((_, _, x, y, _) -> (x, y))
            , getParent = RelLib/Tuple.decons5((_, _, _, _, x) -> x)
            };
        let src1 = src as #{Installation, SubInstallation, ProcessGroup, Process, Plant, PlantItem, 
                                Equipment, ChildFloc, PreorderRow, CommonName | r};
        (query src1 <+> preorderRows() select (x1, x2, x3, x4, x5) from PreorderRow(x1, x2, x3, x4, x5) 
            |> RelLib/UnboundedTree.unboundForest("", extractor)) as & Pure 

    pub def toSaltTree(src: #{Installation, SubInstallation, ProcessGroup, Process, Plant, PlantItem, 
                                Equipment, ChildFloc, CommonName | r}): String =
        let tree1 = match toRoseForest(src) { 
            case t1 :: Nil => t1
            case xs => RoseTree(("Root", ""), xs)
        };
        PlantUml/SaltTree.tree(printLabel = xy -> {let (x1, _) = xy; PlantUml/Creole.text(x1)}, tree1) |> PlantUml/Puml.render


    pub def toSaltTreeTable(src: #{Installation, SubInstallation, ProcessGroup, Process, Plant, PlantItem, 
                                    Equipment, ChildFloc, CommonName | r}): String =
        let tree1 = match toRoseForest(src) { 
            case t1 :: Nil => t1
            case xs => RoseTree(("Root", ""), xs)
        };
        let headers = List.map(PlantUml/Creole.text, "Key" :: "Name" :: Nil);
        PlantUml/SaltTreeTable.treeTable(printCells = xy -> {let (x1, y1) = xy; PlantUml/Creole.text(x1) :: PlantUml/Creole.text(y1) :: Nil}, headers, tree1) |> PlantUml/Puml.render




}
