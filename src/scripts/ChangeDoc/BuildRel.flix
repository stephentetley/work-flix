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


namespace ChangeDoc/BuildRel {
    
    use ChangeDoc/Datatypes.{EntityType};
    use ChangeDoc/Relations.{Funcloc, Equipment, FlocNameChange, EquiNameChange};

    pub def rules(): #{Funcloc, Equipment, FlocNameChange, EquiNameChange | r} = #{

        Funcloc(itemId, "TODO", name) :-
            FlocNameChange(itemId, name).

        Equipment(itemId, name) :- 
            EquiNameChange(itemId, name).
    }

}
