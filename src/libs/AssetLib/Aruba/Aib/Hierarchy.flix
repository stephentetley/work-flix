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


    use AssetLib/Aruba/Aib/Base.{Floc, SubFloc, FlocLevel, Equi, EquiLocation};


    /// Note - we want to represent partial hierarchies (i.e. not starting from Installation), 
    /// so we still have separate relations for Parent/Child.
    /// Similarly we may not have full type information so types are separate relations.


    pub rel Installation(flocId: String, flocPath: String, name: String)
    
    pub rel SubInstallation(flocId: String, flocPath: String, name: String)

    pub rel ProcessGroup(flocId: String, flocPath: String, name: String)

    pub rel Process(flocId: String, flocPath: String, name: String)

    pub rel Plant(flocId: String, flocPath: String, name: String)

    /// Level 6 - e.g "Heating Unit", "Pump Assembly"
    pub rel PlantItem(flocId: String, flocPath: String, name: String)

    /// Floc childOf relation
    pub rel ChildFuncloc(parentFlocId: String, childFlocId: String)

    pub rel Equipment(equiId: String, name: String, floc: String)

    pub rel ChildEquipment(parentId: String, childId: String)




}
