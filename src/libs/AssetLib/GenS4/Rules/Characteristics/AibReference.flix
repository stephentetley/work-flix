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


namespace AssetLib/GenS4/Rules/Characteristics/AibReference {

    use AssetLib/AibFacts/HierarchyFacts.{AibEquipment};
    use AssetLib/GenS4/WorkListRelations.{Phase1EquiItem, Phase2EquiItem};
    use AssetLib/GenS4/UploadRelations.{ClassEqui, ValuaEquiString, ValuaEquiInt};
    use AssetLib/GenS4/UxlRelations.{EquiDatum, EquiCharacteristic};


    pub def equiAibReference(): #{ClassEqui, ValuaEquiString, Phase1EquiItem, Phase2EquiItem, AibEquipment | r} =
        #{
            ClassEqui(equiId, "AIB_REFERENCE", "002") :- 
                Phase2EquiItem(equiId, _, _,  _, _).

            /// AIB_REFERENCE (item)
            ValuaEquiString(equiId, "002", "AI2_AIB_REFERENCE", aibref, 1) :- 
                Phase2EquiItem(equiId, name, floc,  _, _),
                Phase1EquiItem(aibref, name, floc,  _, _, _,  _, _, _).

            /// AI2_AIB_REFERENCE (parent)
            ValuaEquiString(equiId, "002", "AI2_AIB_REFERENCE", parent, 2) :- 
                Phase2EquiItem(equiId, name, floc,  _, _),
                Phase1EquiItem(aibref, name, floc,  _, _, _,  _, _, _),
                AibEquipment(aibref, _, _,  _, _, _,  _, _, parent).

            /// S4_AIB_REFERENCE (blank)
            ValuaEquiString(equiId, "002", "S4_AIB_REFERENCE", "", 1) :-
                Phase2EquiItem(equiId, _, _,  _, _).
        }

    /// For the UXL backend
    pub def uxlEquiAibReference(): #{EquiDatum, EquiCharacteristic, AibEquipment | r} =
        #{
            /// AIB_REFERENCE (item)
            EquiCharacteristic(aibref, "AIB_REFERENCE", "AI2_AIB_REFERENCE", aibref) :- 
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _, _, _,  _).

            /// AI2_AIB_REFERENCE (parent)
            EquiCharacteristic(aibref, "AIB_REFERENCE", "AI2_AIB_REFERENCE", parent) :- 
                AibEquipment(aibref, _, _,  _, _, _,  _, _, parent),
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _, _, _,  _).

            /// S4_AIB_REFERENCE (blank)
            EquiCharacteristic(aibref, "AIB_REFERENCE", "S4_AIB_REFERENCE", "") :-
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _, _, _,  _).
        }

}
