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

namespace AssetLib/Aruba/S4/Hierarchy {


    use Data.RoseForest;
    use Data.RoseTree.RoseTree;
    use AssetLib/Aruba/S4/Base.{S4Floc, S4SubFloc, S4FlocLevel, S4Equi, S4SubEqui, S4EquiLocation};


    /// Note - we want to represent partial hierarchies (i.e. not starting from Site), 
    /// so we still have separate relations for Parent/Child.
    /// Similarly we may not have full type information so types are separate relations.



    /// pub type alias S4HierarchySchema[r1: SchemaRow] = 
    ///     #{Site, Function, ProcessGroup, Process, System, Subsystem, Equipment | r1}

    pub rel Site(funcloc: String, name: String)

    pub rel Function(funcloc: String, name: String)
    
    pub rel ProcessGroup(funcloc: String, name: String)

    pub rel Process(funcloc: String, name: String)

    pub rel System(funcloc: String, name: String)

    /// Level 6 - e.g "Heating Unit", "Pump Assembly"
    pub rel Subsystem(funcloc: String, name: String)

    pub rel Equipment(equiId: String, name: String, funcloc: String)


    /// Floc childOf relation
    pub rel ChildFloc(parentFloc: String, childFloc: String)

    pub rel ChildEqui(parentId: String, childId: String)

    pub rel S4FlocType(funcloc: String, floctype: String)

    
    pub rel FunctionalLocation(funcloc: String, description: String)

    /// S4 Specific
    pub rel FlocCategory(equiId: String, category: String)


    pub rel S4EquiType(equiId: String, equitype: String)

    /// Translation is input source specific, we rely on S4 specific site levels, etc.
    pub def fromS4BaseRelations(input: #{S4Floc, S4SubFloc, S4SubEqui, S4FlocLevel, S4Equi, S4EquiLocation | r}): 
                            #{Site, Function, ProcessGroup, Process, System, Subsystem, 
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
                                    Site, Function, ProcessGroup, Process, System, Subsystem, Equipment, ChildFloc, ChildEqui, FunctionalLocation | r};
        solve input1 <+> rules project Site, Function, ProcessGroup, Process, System, Subsystem, Equipment, ChildFloc, ChildEqui, FunctionalLocation



    /// toPlantUml / RoseTree

    pub rel PreorderRow(treeKey: String, uid: String, parentKey: String)

    /// Note - can "map" the array of PreorderRows, elaborating the uid to a more descriptive type.
    pub def preorderRows(): #{Site, Function, ProcessGroup, Process, System, Subsystem, Equipment, 
                                ChildFloc, ChildEqui, PreorderRow | r1} = #{


        /// Unbounded tree - including equipment at various levels and subequipment.
        PreorderRow(funcloc, funcloc, "") :- 
            Site(funcloc, _).

        PreorderRow(funcloc, funcloc, siteFloc) :- 
            Function(funcloc, _),
            ChildFloc(siteFloc, funcloc).

        PreorderRow(funcloc, funcloc, functionFloc) :- 
            ProcessGroup(funcloc, _), 
            ChildFloc(functionFloc, funcloc).

        PreorderRow(funcloc, funcloc, pgFloc) :- 
            Process(funcloc, _), 
            ChildFloc(pgFloc, funcloc).

        PreorderRow(funcloc, funcloc, pFloc) :- 
            System(funcloc, _), 
            ChildFloc(pFloc, funcloc).

        PreorderRow(funcloc, funcloc, sysFloc) :- 
            Subsystem(funcloc, _), 
            ChildFloc(sysFloc, funcloc).
        
        PreorderRow(equiKey(floc, equiId), equiId, floc) :-
            Equipment(equiId, _, floc), 
            not IsSubEquipment(equiId).

        /// Subequipment
        PreorderRow(subEquiKey(floc, superEquiId, equiId), equiId, subEquiParentKey(floc, superEquiId)) :-
            Equipment(equiId, _, floc), 
            ChildEqui(superEquiId, equiId).

        IsSubEquipment(equiId) :- 
            Equipment(equiId, _, _), 
            ChildEqui(_, equiId).

    }

    def equiKey(floc: String, equiId: String): String = "${floc}::${equiId}"

    def subEquiKey(floc: String, superEquiId: String, equiId: String): String = "${floc}::${superEquiId}::${equiId}"

    def subEquiParentKey(floc: String, superEquiId: String): String = "${floc}::${superEquiId}"


    pub def toRoseForest(src: #{Site, Function, ProcessGroup, Process, System, Subsystem, Equipment, 
                                ChildFloc, ChildEqui, PreorderRow | r}): RoseForest[String] =                                
        (query src <+> preorderRows() select (x1, x2, x3) from PreorderRow(x1, x2, x3) 
            |> RelLib/UnboundedTree.unboundForest("")) as & Pure 

    pub def toSaltTree(src: #{Site, Function, ProcessGroup, Process, System, Subsystem, Equipment, 
                                ChildFloc, ChildEqui, PreorderRow | r}): String =
        let tree1 = match toRoseForest(src) { 
            case t1 :: Nil => t1
            case xs => RoseTree("Root", xs)
        };
        PlantUml/SaltTree.tree(printLabel = PlantUml/Creole.text, tree1) |> PlantUml/Puml.render

}
