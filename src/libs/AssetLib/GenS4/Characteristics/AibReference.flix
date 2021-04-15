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


namespace AssetLib/GenS4/Characteristics/AibReference {

    use AssetLib/GenS4/Aib/HierarchicalRelations.{AibEquipment};
    use AssetLib/GenS4/S4Relations.{EquiDatum, EquiCharacteristic};


    pub def equiAibReference(): #{EquiDatum, EquiCharacteristic, AibEquipment | r} =
        #{
            /// AIB_REFERENCE (item)
            EquiCharacteristic(aibref, "AIB_REFERENCE", "AI2_AIB_REFERENCE", aibref) :- 
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _).

            /// AI2_AIB_REFERENCE (parent)
            EquiCharacteristic(aibref, "AIB_REFERENCE", "AI2_AIB_REFERENCE", parent) :- 
                AibEquipment(aibref, _, _,  _, _, _,  _, _, _,  _, _, parent),
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _).

            /// S4_AIB_REFERENCE (blank)
            EquiCharacteristic(aibref, "AIB_REFERENCE", "S4_AIB_REFERENCE", "") :-
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _).
        }




}
