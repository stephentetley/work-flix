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

namespace Aruba/S4/Check {

    use Aruba/S4/Hierarchy.{Equipment, FunctionalLocation, ChildFloc};


    pub rel OrphanEquipment(equiId: String, name: String, floc: String)
    
    pub rel OrphanFuncloc(floc: String, name: String)
    
    pub rel FlocExists(floc: String)
    pub rel ParentFlocExists(floc: String)

    pub def orphans(): #{Equipment, FunctionalLocation, OrphanEquipment, OrphanFuncloc | r} = #{
        
        OrphanFuncloc(funcloc, name) :- 
            FunctionalLocation(funcloc, name), 
            not ParentFlocExists(funcloc).

        OrphanEquipment(equiId, name, floc) :- 
            Equipment(equiId, name, floc),
            not FlocExists(floc).


        FlocExists(floc) :- FunctionalLocation(floc, _).

        /// We generate `ChildFloc` links without asserting the parent exists, now we check the parent exists...
        ParentFlocExists(floc) :- 
            ChildFloc(parent, floc),
            FunctionalLocation(parent, _).

    }

}
