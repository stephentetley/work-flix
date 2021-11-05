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

namespace AssetLib/Aruba/Aib/Base {



    /// Distinguish flocId and flocPath so we can handle internalFlocIds

    pub rel Floc(flocId: String, flocPath: String, name: String)

    pub rel Equi(equiId: String, name: String)

    pub rel SubFloc(parentFlocId: String, childFlocId: String)

    pub rel EquiLocation(equiId: String, floc: String)

    pub rel SubEqui(parentId: String, childId: String)

    /// FlocLevel is relative to the hirearchy being represented - 
    /// e.g. a System in one representation may have a different level to a System in another.
    pub rel FlocLevel(flocId: String, level: Int32)

    pub rel EquiType(equiId: String, equitype: String)



}
