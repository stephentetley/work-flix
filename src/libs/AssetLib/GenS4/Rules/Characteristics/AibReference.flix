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
    use AssetLib/GenS4/WorkListRelations.{FlocWorkItem, EquiWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{FlocCharacteristic, EquiCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String};

    /// TODO - parentRef should potentially be a singular fact:
    /// > rel ParentRef(aibref: String, parent: String)
    /// 
    pub def equiAibReference(input: #{EquiWorkItem, AibEquipment, EquiCharacteristic | r}): #{EquiCharacteristic | r} =
        let rules = #{
            /// S4_AIB_REFERENCE (blank)
            EquiCharacteristic(equiId, "AIB_REFERENCE", "S4_AIB_REFERENCE", 1, S4String("")) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, _, _).

            /// AIB_REFERENCE (item)
            EquiCharacteristic(equiId, "AIB_REFERENCE", "AI2_AIB_REFERENCE", 1, S4String(equiId)) :- 
                EquiWorkItem(equiId, _, _,  _, _, _,  _, _, _).

            /// AI2_AIB_REFERENCE (parent)
            EquiCharacteristic(equiId, "AIB_REFERENCE", "AI2_AIB_REFERENCE", 2, S4String(parent)) :- 
                EquiWorkItem(equiId, _, _,  _, _, _,  _, _, _),
                AibEquipment(equiId, _, _,  _, _, _,  _, _, parent).
        };
        solve (rules <+> input) project EquiCharacteristic



    pub def flocAibReference(workitems: #{FlocWorkItem, FlocCharacteristic | r}): #{FlocCharacteristic | r} =
        let rules = #{
            FlocCharacteristic(funcloc, "AIB_REFERENCE", "S4_AIB_REFERENCE", 1, S4String("")) :- 
                FlocWorkItem(funcloc, _, _, _, _, _, _, _, _, _, _).

            FlocCharacteristic(funcloc, "AIB_REFERENCE", "AI2_AIB_REFERENCE", 1, S4String(sainum)) :- 
                FlocWorkItem(funcloc, _, _, sainum, _, _, _, _, _, _, _).                
        };
        solve (rules <+> workitems) project FlocCharacteristic


}
