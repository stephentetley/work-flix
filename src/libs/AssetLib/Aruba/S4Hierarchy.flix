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


    use AssetLib/Aruba/Base.{Floc, SubFloc, FlocLevel, Equi, EquiLocation};


    /// Note - we want to represent partial hierarchies (i.e. not starting from Site), 
    /// so we still have separate relations for Parent/Child.
    /// Similarly we may not have full type information so types are separate relations.


    pub rel Site(flocId: String, flocPath: String, name: String)

    pub rel Function(flocId: String, flocPath: String, name: String)
    
    pub rel ProcessGroup(flocId: String, flocPath: String, name: String)

    pub rel Process(flocId: String, flocPath: String, name: String)

    pub rel System(flocId: String, flocPath: String, name: String)

    /// Level 6 - e.g "Heating Unit", "Pump Assembly"
    pub rel Subsystem(flocId: String, flocPath: String, name: String)

    /// Floc childOf relation
    pub rel ChildFloc(parentFlocId: String, childFlocId: String)

    pub rel Equipment(equiId: String, name: String, floc: String)

    pub rel ChildEquipment(parentId: String, childId: String)

    pub rel S4FlocType(equiId: String, floctype: String)

    /// S4 Specific
    pub rel FlocCategory(equiId: String, category: String)


    pub rel S4EquiType(equiId: String, equitype: String)

    /// Translation is input source specific, we rely on S4 specific site levels, etc.
    pub def fromS4BaseRelations(input: #{Floc, SubFloc, FlocLevel, Equi, EquiLocation | r}): 
                            #{Site, Function, ProcessGroup, Process, System, Subsystem, 
                                Equipment, ChildFloc | r1} = 
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
        };
        let input1 = input as #{Floc, SubFloc, FlocLevel, Equi, EquiLocation,  
                                    Site, Function, ProcessGroup, Process, System, Subsystem, Equipment, ChildFloc | r};
        solve input1 <+> rules project Site, Site, Function, ProcessGroup, Process, System, Subsystem, Equipment, ChildFloc


}
