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

namespace AssetLib/Aruba/Hierarchy {

    /// Note - we want to represent partial hierarchies (i.e. not starting from Site), 
    /// so we still have separate relations for Parent/Child.
    /// Similarly we may not have full type information so types are separate relations.


    pub rel Site(floc: String, name: String)

    pub rel Function(floc: String, name: String)
    
    pub rel ProcessGroup(floc: String, name: String)

    pub rel Process(floc: String, name: String)

    pub rel System(floc: String, name: String)

    /// Level 6 - e.g "Heating Unit", "Pump Assembly"
    pub rel Subsystem(floc: String, name: String)

    pub rel Equipment(equiId: String, name: String, floc: String)

    pub rel SubEquipment(parentId: String, childId: String)

    pub rel FlocType(equiId: String, floctype: String)

    /// S4 Specific
    pub rel FlocCategory(equiId: String, category: String)


    pub rel EquiType(equiId: String, equitype: String)


}
