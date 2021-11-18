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


    use AssetLib/Aruba/Aib/Base.{AibFloc, AibEqui, AibSubFloc, AibEquiLocation, AibSubEqui, AibFlocLevel, AibEquiType};


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

    pub rel Equipment(equiId: String, name: String, floc: String)

    /// Floc childOf relation
    pub rel ChildFloc(parentFlocId: String, childFlocId: String)

    
    pub rel EquiType(equiId: String, equitype: String)

    /// Translation is input source specific, we rely on S4 specific site levels, etc.
    pub def fromAibBaseRelations(input: #{AibFloc, AibEqui, AibSubFloc, AibEquiLocation, AibSubEqui, AibFlocLevel, AibEquiType | r}): 
                            #{Installation, SubInstallation, ProcessGroup, Process, Plant, PlantItem, 
                                Equipment, ChildFloc, EquiType | r1} = 
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

            Equipment(equiId, name, floc) :- 
                AibEqui(equiId, name), 
                AibEquiLocation(equiId, floc).

            EquiType(equiId, tyname) :- 
                AibEquiType(equiId, tyname).

        };
        let input1 = input as #{AibFloc, AibEqui, AibSubFloc, AibEquiLocation, AibSubEqui, AibFlocLevel, AibEquiType,  
                                    Installation, SubInstallation, ProcessGroup, Process, Plant, PlantItem, Equipment, ChildFloc, EquiType | r};
        solve input1 <+> rules project Installation, SubInstallation, ProcessGroup, Process, Plant, PlantItem, Equipment, ChildFloc, EquiType


}
