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

namespace Aruba/Aib/Hierarchy {

    use Data.RoseForest;
    use Data.RoseTree.{Node};
    use RelLib/Lattice/LongestString.{LongestString};
    use Aruba/Aib/Base.{AibFloc, AibEqui, AibSubFloc, AibFlocLevel, AibEquiType};


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

    /// Equi childOf relation
    pub rel ChildEqui(parentFlocId: String, childEquiId: String)


    pub rel CommonName(refnum: String, commonName: String)

    /// `pub` for testing?
    pub lat CommonNamePrefix(sainum: String, longestCommonName: LongestString)
    
    rel CommonNamePrefixValue(sainum: String, longestCommonName: String)

    rel SingleName(sainum: String, longestCommonName: String)

    def commonNamePrefix(name1: String, name2: String): LongestString = 
        use RelLib/Lattice/LongestString.{longestString};
        if (String.length(name1) <= String.length(name2)) 
            LowerBound.minValue() 
        else {
            /// Can't use String.commonPrefix - must respect "path boundaries"
            let prefix = commonNamePrefixHelper(name1, name2);
            longestString(prefix)
        } 

    def commonNamePrefixHelper(name1: String, name2: String): String = 
        if (String.startsWith(prefix = name2, name1))
            name2
        else 
            ""


    def getSingleName(parent: {parent :: String}, child: String): String = 
        match String.stripPrefix(substr = parent.parent, child) {
            case None => child
            case Some(s) => if (String.startsWith(prefix = "/", s)) String.dropLeft(1, s) else s
        }



    /// Translation is input source specific, we rely on S4 specific site levels, etc.
    pub def fromAibBaseRelations(input: #{AibFloc, AibEqui | r}): 
                            #{Installation, SubInstallation, ProcessGroup, Process, Plant, PlantItem, 
                                Equipment, ChildFloc, ChildEqui, CommonName, CommonNamePrefix | r1} = 
        let rules = #{
            
            CommonName(sainum, commonName) :- AibFloc(sainum, commonName, _).
            CommonName(sainum, commonName) :- AibEqui(sainum, commonName, _).

            Installation(sainum, commonName, commonName):- 
                AibFloc(sainum, commonName, hkey),
                if Aruba/Aib/Base.flocLevel(hkey) == "Installation".

            SubInstallation(sainum, commonName, commonName):- 
                AibFloc(sainum, commonName, hkey),
                if Aruba/Aib/Base.flocLevel(hkey) == "Sub_Installation".

            ProcessGroup(sainum, commonName, itemName):- 
                AibFloc(sainum, commonName, hkey),
                SingleName(sainum, itemName),
                if Aruba/Aib/Base.flocLevel(hkey) == "Process_Group".

            Process(sainum, commonName, itemName):- 
                AibFloc(sainum, commonName, hkey),
                SingleName(sainum, itemName),
                if Aruba/Aib/Base.flocLevel(hkey) == "Process".

            Plant(sainum, commonName, itemName):- 
                AibFloc(sainum, commonName, hkey),
                SingleName(sainum, itemName),
                if Aruba/Aib/Base.flocLevel(hkey) == "Plant".

            PlantItem(sainum, commonName, itemName):- 
                AibFloc(sainum, commonName, hkey),
                SingleName(sainum, itemName),
                if Aruba/Aib/Base.flocLevel(hkey) == "Plant_Item".

            Equipment(equiId, commonName, equiType) :- 
                AibEqui(equiId, commonName, equiType).

            /// TODO have to use commonName again as there is no link between hkey and equipment.
            /// This finds the "parent"...
            CommonNamePrefix(sainum; commonNamePrefix(name1, name2)) :-
                AibFloc(sainum, name1, _),
                AibFloc(_, name2, _).
            
            CommonNamePrefix(plinum; commonNamePrefix(name1, name2)) :-
                AibEqui(plinum, name1, _),
                AibFloc(_, name2, _).

            /// This exposes the value as a String...
            CommonNamePrefixValue(sainum, Option.getWithDefault("", RelLib/Lattice/LongestString.getValue(hkey))) :- 
                fix CommonNamePrefix(sainum; hkey).


            ChildFloc(parent, child) :- 
                AibFloc(child, _, _),
                CommonNamePrefixValue(child, parentCommonName),
                AibFloc(parent, parentCommonName, _).


            ChildEqui(parent, child) :- 
                AibEqui(child, _, _),
                CommonNamePrefixValue(child, parentCommonName),
                AibFloc(parent, parentCommonName, _).

            SingleName(sainum, getSingleName(parent = parentName, childName)) :- 
                AibFloc(sainum, childName, _),
                ChildFloc(parentRef, sainum), 
                AibFloc(parentRef, parentName, _).
        

        };
        let input1 = input as #{AibFloc, AibEqui,
                                Installation, SubInstallation, ProcessGroup, Process, Plant, PlantItem, Equipment, 
                                ChildFloc, ChildEqui, CommonName, CommonNamePrefix, CommonNamePrefixValue, SingleName | r};
        solve input1 <+> rules project Installation, SubInstallation, ProcessGroup, Process, Plant, PlantItem, 
                                        Equipment, ChildFloc, ChildEqui, CommonName, CommonNamePrefix




    /// toPlantUml / RoseTree

    pub rel PreorderRow(treeKey: String, flocOrEqui: String, uid: String, descr: String, parentKey: String)

    pub rel HasParent(commonName: String)
    
    pub rel EquiParentKey(plinum: String, parentKey: String)


    /// WARNING - have to rely commonNames to make a hierarchy even though they are not reliable.
    /// (Potentially we drop equipment...)
    /// No other like between Equi and Floc.
    pub def preorderRows(): #{Installation, SubInstallation, ProcessGroup, Process, Plant, PlantItem, 
                                Equipment, ChildFloc, CommonName, HasParent, EquiParentKey, PreorderRow | r1} = #{


        HasParent(refnum) :- ChildFloc(_, refnum).

        /// Unbounded tree - including equipment at various levels and subequipment.
        
        /// Installation is root
        PreorderRow(commonName, "FLOC", refnum, name, "") :- 
            Installation(refnum, commonName, name).

        
        /// SubInstallation is root
        PreorderRow(commonName, "FLOC", refnum, name, "") :- 
            SubInstallation(refnum, commonName, name),
            not HasParent(refnum).


        /// SubInstallation is not root
        PreorderRow(commonName, "FLOC", refnum, name, parentKey) :- 
            SubInstallation(refnum, commonName, name),
            ChildFloc(parentRef, refnum),
            CommonName(parentRef, parentKey).

  
        /// ProcessGroup is root
        PreorderRow(commonName, "FLOC", refnum, name, "") :- 
            ProcessGroup(refnum, commonName, name),
            not HasParent(refnum).

        /// ProcessGroup is not root
        PreorderRow(commonName, "FLOC", refnum, name, parentKey) :- 
            ProcessGroup(refnum, commonName, name),
            ChildFloc(parentRef, refnum),
            CommonName(parentRef, parentKey).

      
        /// Process is root
        PreorderRow(commonName, "FLOC", refnum, name, "") :- 
            Process(refnum, commonName, name),
            not HasParent(refnum).

        /// Process is not root
        PreorderRow(commonName, "FLOC", refnum, name, parentKey) :- 
            Process(refnum, commonName, name),
            ChildFloc(parentRef, refnum),
            CommonName(parentRef, parentKey).

        
        /// Plant is root
        PreorderRow(commonName, "FLOC", refnum, name, "") :- 
            Plant(refnum, commonName, name),
            not HasParent(refnum).

        /// Plant is not root
        PreorderRow(commonName, "FLOC", refnum, name, parentKey) :- 
            Plant(refnum, commonName, name),
            ChildFloc(parentRef, refnum),
            CommonName(parentRef, parentKey).
        
        /// PlantItem is root
        PreorderRow(commonName, "FLOC", refnum, name, "") :- 
            PlantItem(refnum, commonName, name),
            not HasParent(refnum).

        /// PlantItem is not root
        PreorderRow(commonName, "FLOC", refnum, name, parentKey) :- 
            PlantItem(refnum, commonName, name),
            ChildFloc(parentRef, refnum),
            CommonName(parentRef, parentKey).

        /// Equipment (only generate if parentKey exists...)
        PreorderRow(commonName, "EQUI", refnum, typeName, parentKey) :- 
            Equipment(refnum, commonName, typeName),            
            EquiParentKey(refnum, parentKey),
            CommonName(_, parentKey).

        EquiParentKey(refnum, equiParentKey(commonName)) :- 
            Equipment(refnum, commonName, _).
            
    }

    def equiParentKey(name: String): String = 
        let (s1, s2) = String.breakOnLeft(substr = "/EQUIPMENT:", name);
        if (not String.isEmpty(s2))
            s1
        else
            String.breakOnLeft(substr = "/EQPT:", name) |> fst
            

    pub def toRoseForest(src: #{Installation, SubInstallation, ProcessGroup, Process, Plant, PlantItem, 
                                Equipment, ChildFloc, CommonName | r}): RoseForest[(String, String)] =                                
        
        let extractor = 
            { getKey    = RelLib/Tuple.decons5((x, _, _, _, _) -> x)
            , getValue  = RelLib/Tuple.decons5((_, _, x, y, _) -> (x, y))
            , getParent = RelLib/Tuple.decons5((_, _, _, _, x) -> x)
            };
        let src1 = src as #{Installation, SubInstallation, ProcessGroup, Process, Plant, PlantItem, 
                                Equipment, ChildFloc, CommonName, HasParent, EquiParentKey, PreorderRow | r};
        (query src1 <+> preorderRows() select (x1, x2, x3, x4, x5) from PreorderRow(x1, x2, x3, x4, x5) 
            |> RelLib/UnboundedTree.unboundForest("", extractor)) as & Pure 

    pub def toSaltTree(src: #{Installation, SubInstallation, ProcessGroup, Process, Plant, PlantItem, 
                                Equipment, ChildFloc, CommonName | r}): String =
        let tree1 = match toRoseForest(src) { 
            case t1 :: Nil => t1
            case xs => Node(("Root", ""), xs)
        };
        PlantUml/SaltTree.printTree(printLabel = xy -> {let (x1, _) = xy; PlantUml/Creole.text(x1)}, tree1) |> PlantUml/Puml.render


    pub def toSaltTreeTable(src: #{Installation, SubInstallation, ProcessGroup, Process, Plant, PlantItem, 
                                    Equipment, ChildFloc, CommonName | r}): String =
        let tree1 = match toRoseForest(src) { 
            case t1 :: Nil => t1
            case xs => Node(("Root", ""), xs)
        };
        let headers = List.map(PlantUml/Creole.text, "Key" :: "Name" :: Nil);
        PlantUml/SaltTreeTable.printTreeTable(printCells = xy -> {let (x1, y1) = xy; PlantUml/Creole.text(x1) :: PlantUml/Creole.text(y1) :: Nil}, headers, tree1) |> PlantUml/Puml.render


}
