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

namespace AssetLib/Aruba/S4/Base {



    /// Distinguish flocId and flocPath so we can handle internalFlocIds

    pub rel S4Floc(funloc: String, name: String)

    pub rel S4Equi(equiId: String, name: String)

    pub rel S4SubFloc(parentFloc: String, childFloc: String)

    pub rel S4EquiLocation(equiId: String, floc: String)

    pub rel S4SubEqui(parentId: String, childId: String)

    pub rel S4FlocLevel(funloc: String, level: Int32)

    
}
