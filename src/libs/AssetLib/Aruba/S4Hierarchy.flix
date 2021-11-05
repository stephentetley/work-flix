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

namespace AssetLib/Aruba/S4Hierarchy {


    use AssetLib/Aruba/Base.{Floc, SubFloc, FlocLevel, Equi, SubEqui, EquiLocation};


    /// Note - we want to represent partial hierarchies (i.e. not starting from Site), 
    /// so we still have separate relations for Parent/Child.
    /// Similarly we may not have full type information so types are separate relations.

    /// TODO 
    /// Having flocId (potentially an internal fufloc id) within the main relations
    /// is confusing - might be better to have a join relation:
    /// 
    /// > FlocId(flocPath: String, internalFlocId: String)
    /// 

    pub type alias S4HierarchySchema[r1: SchemaRow] = 
        #{Site, Function, ProcessGroup, Process, System, Subsystem, Equipment | r1}

    pub rel Site(flocId: String, flocPath: String, name: String)

    pub rel Function(flocId: String, flocPath: String, name: String)
    
    pub rel ProcessGroup(flocId: String, flocPath: String, name: String)

    pub rel Process(flocId: String, flocPath: String, name: String)

    pub rel System(flocId: String, flocPath: String, name: String)

    /// Level 6 - e.g "Heating Unit", "Pump Assembly"
    pub rel Subsystem(flocId: String, flocPath: String, name: String)

    pub rel Equipment(equiId: String, name: String, floc: String)


    /// Floc childOf relation
    pub rel ChildFloc(parentFlocId: String, childFlocId: String)

    pub rel ChildEquipment(parentId: String, childId: String)

    pub rel S4FlocType(flocIdId: String, floctype: String)

    
    pub rel FunctionalLocation(floc: String, description: String)

    /// S4 Specific
    pub rel FlocCategory(equiId: String, category: String)


    pub rel S4EquiType(equiId: String, equitype: String)

    /// Translation is input source specific, we rely on S4 specific site levels, etc.
    pub def fromS4BaseRelations(input: #{Floc, SubFloc, FlocLevel, Equi, EquiLocation | r}): 
                            #{Site, Function, ProcessGroup, Process, System, Subsystem, 
                                Equipment, ChildFloc, ChildEquipment, FunctionalLocation | r1} = 
        let rules = #{
            Site(flocId, flocPath, name):- 
                Floc(flocId, flocPath, name),
                FlocLevel(flocId, 1).

            Function(flocId, flocPath, name):- 
                Floc(flocId, flocPath, name),
                FlocLevel(flocId, 2).
        
            ProcessGroup(flocId, flocPath, name):- 
                Floc(flocId, flocPath, name),
                FlocLevel(flocId, 3). 

            Process(flocId, flocPath, name):- 
                Floc(flocId, flocPath, name),
                FlocLevel(flocId, 4). 
            
            System(flocId, flocPath, name):- 
                Floc(flocId, flocPath, name),
                FlocLevel(flocId, 5). 

            Subsystem(flocId, flocPath, name):- 
                Floc(flocId, flocPath, name),
                FlocLevel(flocId, 6).

            Equipment(equiId, name, floc) :- 
                Equi(equiId, name),
                EquiLocation(equiId, floc).

            ChildFloc(parentId, childId) :- 
                SubFloc(parentId, childId).

            ChildEquipment(parentId, childId) :-
                SubEqui(parentId, childId).

            FunctionalLocation(flocId, name) :- Site(flocId, _, name).

            FunctionalLocation(flocId, name) :- Function(flocId, _, name).

            FunctionalLocation(flocId, name) :- ProcessGroup(flocId, _, name).

            FunctionalLocation(flocId, name) :- Process(flocId, _, name).

            FunctionalLocation(flocId, name) :- System(flocId, _, name).

            FunctionalLocation(flocId, name) :- Subsystem(flocId, _, name).
            
        };
        let input1 = input as #{Floc, SubFloc, FlocLevel, Equi, SubEqui, EquiLocation,  
                                    Site, Function, ProcessGroup, Process, System, Subsystem, Equipment, ChildFloc, ChildEquipment, FunctionalLocation | r};
        solve input1 <+> rules project Site, Site, Function, ProcessGroup, Process, System, Subsystem, Equipment, ChildFloc, ChildEquipment, FunctionalLocation



    /// toPlantUml / RoseTree

    pub rel PreorderRow(treeKey: String, uid: String, parentKey: String)

    /// Note - can "map" the array of PreorderRows, elaborating the uid to a more descriptive type.
    pub def preorderRows(): #{Site, Function, ProcessGroup, Process, System, Subsystem, Equipment, 
                                ChildFloc, ChildEquipment, PreorderRow | r1} = #{


        /// Unbounded tree - including equipment at various levels and subequipment.
        PreorderRow(siteFloc, flocId, "") :- 
            Site(flocId, siteFloc, _).

        PreorderRow(funFloc, flocId, siteFloc) :- 
            Function(flocId, funFloc, _),
            ChildFloc(siteFloc, funFloc).

        PreorderRow(pgFloc, flocId, funFloc) :- 
            ProcessGroup(flocId, pgFloc, _), 
            ChildFloc(funFloc, pgFloc).

        PreorderRow(pFloc, flocId, pgFloc) :- 
            Process(flocId, pFloc, _), 
            ChildFloc(pgFloc, pFloc).

        PreorderRow(sysFloc, flocId, pFloc) :- 
            System(flocId, sysFloc, _), 
            ChildFloc(pFloc, sysFloc).

        PreorderRow(ssFloc, flocId, sysFloc) :- 
            Subsystem(flocId, ssFloc, _), 
            ChildFloc(sysFloc, ssFloc).
        
        PreorderRow("${floc}::${equiId}", equiId, floc) :-
            Equipment(equiId, _, floc), 
            not IsSubEquipment(equiId).

        PreorderRow("${floc}::${superId}::${equiId}", equiId, "${floc}::${superId}") :-
            Equipment(equiId, _, floc), 
            ChildEquipment(superId, equiId).

        IsSubEquipment(equiId) :- 
            Equipment(equiId, _, _), 
            ChildEquipment(_, equiId).

    }


}
