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

    use AssetLib/AibFacts/Attributes/AibReference.{ParentRef};
    use AssetLib/S4Lite/Datatypes.{SLFlocCharacteristic, SLEquiCharacteristic};
    use AssetLib/GenS4/WorkLists.{FunclocWorkItem, FlocWorkItem, EquipmentWorkItem, EquiWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{FlocCharacteristic, EquiCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String};
    use AssetLib/GenS4/XlsxSource.{XlsxSource};


    pub def genEquiAibReference(worklist: List[EquipmentWorkItem], src: XlsxSource): Result[Chain[SLEquiCharacteristic], String] & Impure =
        use Result.{flatMap};
        let workitems   = AssetLib/GenS4/WorkLists.makeEquiWorkItems(worklist);
        let* facts      = AssetLib/AibFacts/Attributes/AibReference.readHierarchyRelations(src.sheet, src.file);
        let ans         = equiAibReference(workitems <+> facts) |> AssetLib/GenS4/S4LiteRelations.toSLEquiCharacteristic;
        Ok(ans) 

    /// 
    pub def equiAibReference(input: #{EquiWorkItem, ParentRef, EquiCharacteristic | r}): #{EquiCharacteristic | r} =
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
                ParentRef(equiId, _, parent).
        };
        solve (rules <+> input) project EquiCharacteristic


    pub def genFlocAibReference(worklist: List[FunclocWorkItem]): Result[Chain[SLFlocCharacteristic], String] & Impure =
        use Result.{flatMap};
        let workitems   = AssetLib/GenS4/WorkLists.makeFlocWorkItems(worklist);
        let ans         = flocAibReference(workitems) |> AssetLib/GenS4/S4LiteRelations.toSLFlocCharacteristic;
        Ok(ans) 

    pub def flocAibReference(workitems: #{FlocWorkItem, FlocCharacteristic | r}): #{FlocCharacteristic | r} =
        let rules = #{
            FlocCharacteristic(funcloc, "AIB_REFERENCE", "S4_AIB_REFERENCE", 1, S4String("")) :- 
                FlocWorkItem(funcloc, _, _, _, _, _, _, _, _, _, _).

            FlocCharacteristic(funcloc, "AIB_REFERENCE", "AI2_AIB_REFERENCE", 1, S4String(sainum)) :- 
                FlocWorkItem(funcloc, _, _, sainum, _, _, _, _, _, _, _).                
        };
        solve (rules <+> workitems) project FlocCharacteristic


}
