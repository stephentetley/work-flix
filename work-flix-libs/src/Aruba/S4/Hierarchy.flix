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

namespace Aruba/S4/Hierarchy {

    use Data.RoseForest;
    use Data.RoseTree.{Node};
    use Aruba/S4/Base.{S4Floc, S4SubFloc, S4FlocLevel, S4Equi, S4SubEqui, S4EquiLocation};


    /// Note - we want to represent partial hierarchies (i.e. not starting from Site), 
    /// so we still have separate relations for Parent/Child.
    /// Similarly we may not have full type information so types are separate relations.




    pub rel Site(funcloc: String, name: String)

    pub rel Function(funcloc: String, name: String)
    
    pub rel ProcessGroup(funcloc: String, name: String)

    pub rel Process(funcloc: String, name: String)

    pub rel System(funcloc: String, name: String)

    /// Level 6 - e.g "Heating Unit", "Pump Assembly"
    pub rel Subsystem(funcloc: String, name: String)

    /// Level 7 - e.g "Cubicle"
    pub rel MaintainableItem(funcloc: String, name: String)

    /// Level 8 - e.g ???
    pub rel Component(funcloc: String, name: String)

    pub rel Equipment(equiId: String, name: String, funcloc: String)


    /// Floc childOf relation
    pub rel ChildFloc(parentFloc: String, childFloc: String)

    pub rel ChildEqui(parentId: String, childId: String)

    pub rel S4FlocType(funcloc: String, floctype: String)

    
    pub rel FunctionalLocation(funcloc: String, name: String)

    /// S4 Specific
    pub rel FlocCategory(equiId: String, category: String)


    pub rel S4EquiType(equiId: String, equitype: String)

    /// Translation relies on S4 site levels, etc.
    pub def fromS4BaseRelations(input: #{S4Floc, S4SubFloc, S4SubEqui, S4FlocLevel, S4Equi, S4EquiLocation | r}): 
                            #{Site, Function, ProcessGroup, Process, System, Subsystem, MaintainableItem, Component, 
                                Equipment, ChildFloc, ChildEqui, FunctionalLocation | r1} = 
        let rules = #{
            Site(funcloc, name):- 
                S4Floc(funcloc, name),
                S4FlocLevel(funcloc, 1).

            Function(funcloc, name):- 
                S4Floc(funcloc, name),
                S4FlocLevel(funcloc, 2).
        
            ProcessGroup(funcloc, name):- 
                S4Floc(funcloc, name),
                S4FlocLevel(funcloc, 3). 

            Process(funcloc, name):- 
                S4Floc(funcloc, name),
                S4FlocLevel(funcloc, 4). 
            
            System(funcloc, name):- 
                S4Floc(funcloc, name),
                S4FlocLevel(funcloc, 5). 

            Subsystem(funcloc, name):- 
                S4Floc(funcloc, name),
                S4FlocLevel(funcloc, 6).

            MaintainableItem(funcloc, name):- 
                S4Floc(funcloc, name),
                S4FlocLevel(funcloc, 7).

            Component(funcloc, name):- 
                S4Floc(funcloc, name),
                S4FlocLevel(funcloc, 8).


            Equipment(equiId, name, floc) :- 
                S4Equi(equiId, name),
                S4EquiLocation(equiId, floc).

            ChildFloc(parentFloc, childFloc) :- 
                S4SubFloc(parentFloc, childFloc).

            ChildEqui(parentId, childId) :-
                S4SubEqui(parentId, childId).

            FunctionalLocation(funcloc, name) :- Site(funcloc, name).

            FunctionalLocation(funcloc, name) :- Function(funcloc, name).

            FunctionalLocation(funcloc, name) :- ProcessGroup(funcloc, name).

            FunctionalLocation(funcloc, name) :- Process(funcloc, name).

            FunctionalLocation(funcloc, name) :- System(funcloc, name).

            FunctionalLocation(funcloc, name) :- Subsystem(funcloc, name).
            
        };
        let input1 = input as #{S4Floc, S4SubFloc, S4FlocLevel, S4Equi, S4SubEqui, S4EquiLocation,  
                                    Site, Function, ProcessGroup, Process, System, Subsystem, MaintainableItem, Component, Equipment, ChildFloc, ChildEqui, FunctionalLocation | r};
        solve input1 <+> rules project Site, Function, ProcessGroup, Process, System, Subsystem, MaintainableItem, Component, Equipment, ChildFloc, ChildEqui, FunctionalLocation



    /// toPlantUml / RoseTree

    pub rel PreorderRow(treeKey: String, flocOrEqui: String, uid: String, descr: String, parentKey: String)

    /// Note - can "map" the array of PreorderRows, elaborating the uid to a more descriptive type.
    pub def preorderRows(): #{Site, Function, ProcessGroup, Process, System, Subsystem, MaintainableItem, Component, 
                                Equipment, ChildFloc, ChildEqui, PreorderRow | r1} = #{


        /// Unbounded tree - including equipment at various levels and subequipment.
        PreorderRow(funcloc, "FLOC", funcloc, name, "") :- 
            Site(funcloc, name).

        PreorderRow(funcloc, "FLOC",funcloc, name, siteFloc) :- 
            Function(funcloc, name),
            ChildFloc(siteFloc, funcloc).

        PreorderRow(funcloc, "FLOC", funcloc, name, functionFloc) :- 
            ProcessGroup(funcloc, name), 
            ChildFloc(functionFloc, funcloc).

        PreorderRow(funcloc, "FLOC", funcloc, name, pgFloc) :- 
            Process(funcloc, name), 
            ChildFloc(pgFloc, funcloc).

        PreorderRow(funcloc, "FLOC", funcloc, name, pFloc) :- 
            System(funcloc, name), 
            ChildFloc(pFloc, funcloc).

        PreorderRow(funcloc, "FLOC", funcloc, name, sysFloc) :- 
            Subsystem(funcloc, name), 
            ChildFloc(sysFloc, funcloc).
        
        PreorderRow(funcloc, "FLOC", funcloc, name, sysFloc) :- 
            MaintainableItem(funcloc, name), 
            ChildFloc(sysFloc, funcloc).

        PreorderRow(funcloc, "FLOC", funcloc, name, sysFloc) :- 
            Component(funcloc, name), 
            ChildFloc(sysFloc, funcloc).

        PreorderRow(equiKey(floc, equiId), "EQUI", equiId, name, floc) :-
            Equipment(equiId, name, floc), 
            not IsSubEquipment(equiId).

        /// Subequipment
        PreorderRow(subEquiKey(floc, superEquiId, equiId), "EQUI", equiId, name, subEquiParentKey(floc, superEquiId)) :-
            Equipment(equiId, name, floc), 
            ChildEqui(superEquiId, equiId).

        IsSubEquipment(equiId) :- 
            Equipment(equiId, _, _), 
            ChildEqui(_, equiId).

    }

    def equiKey(floc: String, equiId: String): String = "${floc}::${equiId}"

    def subEquiKey(floc: String, superEquiId: String, equiId: String): String = "${floc}::${superEquiId}::${equiId}"

    def subEquiParentKey(floc: String, superEquiId: String): String = "${floc}::${superEquiId}"


    pub def toRoseForest(src: #{Site, Function, ProcessGroup, Process, System, Subsystem, MaintainableItem, Component,
                                Equipment, ChildFloc, ChildEqui | r}): RoseForest[(String, String)] =                                
        
        let extractor = 
            { getKey    = RelLib/Tuple.decons5((x, _, _, _, _) -> x)
            , getValue  = RelLib/Tuple.decons5((_, _, x, y, _) -> (x, y))
            , getParent = RelLib/Tuple.decons5((_, _, _, _, x) -> x)
            };
        let src1 = src as #{Site, Function, ProcessGroup, Process, System, Subsystem, 
                                MaintainableItem, Component, Equipment, ChildFloc, ChildEqui, PreorderRow | r};
        (query src1 <+> preorderRows() select (x1, x2, x3, x4, x5) from PreorderRow(x1, x2, x3, x4, x5) 
            |> RelLib/UnboundedTree.unboundForest("", extractor)) as & Pure 

    pub def toSaltTree(src: #{Site, Function, ProcessGroup, Process, System, Subsystem, 
                                MaintainableItem, Component, Equipment, ChildFloc, ChildEqui | r}): String =
        let tree1 = match toRoseForest(src) { 
            case t1 :: Nil => t1
            case xs => Node(("Root", ""), xs)
        };
        PlantUml/SaltTree.printTree(printLabel = xy -> {let (x1, _) = xy; PlantUml/Creole.text(x1)}, tree1) |> PlantUml/Puml.render


    pub def toSaltTreeTable(src: #{Site, Function, ProcessGroup, Process, System, Subsystem, 
                                    MaintainableItem, Component, Equipment, ChildFloc, ChildEqui | r}): String =
        let tree1 = match toRoseForest(src) { 
            case t1 :: Nil => t1
            case xs => Node(("Root", ""), xs)
        };
        let headers = List.map(PlantUml/Creole.text, "Key" :: "Name" :: Nil);
        PlantUml/SaltTreeTable.printTreeTable(printCells = xy -> {let (x1, y1) = xy; PlantUml/Creole.text(x1) :: PlantUml/Creole.text(y1) :: Nil}, headers, tree1) |> PlantUml/Puml.render




}
