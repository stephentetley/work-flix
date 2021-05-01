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


namespace AssetLib/GenS4/WorkListRelations {

    /// Phase 1
    pub rel Phase1Equi(aibref: String,
                        s4Name: String,  
                        s4Floc: String,
                        superEqui: String, 
                        s4Category: String, 
                        s4EquiType: String, 
                        s4EquiClass: String)
    
    /// Phase 2
    /// Object Class e.g. VALVNR is available directly, we don't have to 
    /// worry about calculating it.
    pub rel Phase2Equi(equipmentId: String,  
                        description: String,    /// aka name
                        functionalLocation: String,
                        objectType: String,
                        objectClass: String)

}
