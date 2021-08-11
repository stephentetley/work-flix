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

    use SheetIO/Reader.{XlsxSource};
    use AssetLib/AibFacts/Attributes/AibReference.{ParentRef};
    use AssetLib/S4Lite/Datatypes.{SLFlocCharacteristic, SLEquiCharacteristic};
    use AssetLib/GenS4/WorkLists.{FlocWorkItemRec, FlocWorkItem, EquiWorkItemRec, EquiWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{FlocCharacteristic, EquiCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String};
    use AssetLib/GenS4/Rules/Characteristics/CommonRelations.{EquiWorkItem3};
    

    pub def genEquiAibReference(worklist: List[EquiWorkItemRec], src: XlsxSource): Result[Chain[SLEquiCharacteristic], String] & Impure =
        use Result.{flatMap};
        let workitems   = makeWorkItems(worklist);
        let* facts      = AssetLib/AibFacts/Attributes/AibReference.readHierarchyRelations(src);
        let ans         = equiAibReference(workitems <+> facts) |> AssetLib/GenS4/S4LiteRelations.toSLEquiCharacteristic;
        Ok(ans) 


    /// Where to put this?
    def makeWorkItems(xs: List[EquiWorkItemRec]): #{EquiWorkItem3 | r}  = 
        List.foldLeft((ac, x) -> ac <+> #{ EquiWorkItem3(x.equipmentId, x.s4EquiType, x.s4EquiClass). }, #{}, xs)

    /// 
    def equiAibReference(input: #{EquiWorkItem3, ParentRef, EquiCharacteristic | r}): #{EquiCharacteristic | r} =
        let rules = #{
            /// S4_AIB_REFERENCE (blank)
            EquiCharacteristic(equiId, "AIB_REFERENCE", "S4_AIB_REFERENCE", 1, S4String("")) :-
                EquiWorkItem3(equiId, _, _).

            /// AIB_REFERENCE (item)
            EquiCharacteristic(equiId, "AIB_REFERENCE", "AI2_AIB_REFERENCE", 1, S4String(equiId)) :- 
                EquiWorkItem3(equiId, _, _).

            /// AI2_AIB_REFERENCE (parent)
            EquiCharacteristic(equiId, "AIB_REFERENCE", "AI2_AIB_REFERENCE", 2, S4String(parent)) :- 
                EquiWorkItem3(equiId, _, _),
                ParentRef(equiId, _, parent).
        };
        solve (rules <+> input) project EquiCharacteristic

    pub rel FlocAibRef(funcloc: String, sainum: String)

    def makeFlocAibRef(x: FlocWorkItemRec): #{FlocAibRef | r} = 
        List.foldLeft((ac, sai) -> ac <+> #{ FlocAibRef(x.funcloc, sai). }, #{}, x.sainums)

    pub def genFlocAibReference(worklist: List[FlocWorkItemRec]): Result[Chain[SLFlocCharacteristic], String] & Impure =
        use Result.{flatMap};
        let workitems1  = AssetLib/GenS4/WorkLists.makeFlocWorkItems(worklist);
        let workitems2  = List.foldLeft((ac, x) -> ac <+> makeFlocAibRef(x), #{}, worklist);
        let ans         = flocAibReference(workitems1 <+> workitems2) |> AssetLib/GenS4/S4LiteRelations.toSLFlocCharacteristic;
        Ok(ans) 

    def flocAibReference(workitems: #{FlocAibRef, FlocWorkItem, FlocCharacteristic | r}): #{FlocCharacteristic | r} =
        let rules = #{
            
            /// 1-to-1 to work item
            FlocCharacteristic(funcloc, "AIB_REFERENCE", "S4_AIB_REFERENCE", 1, S4String("")) :- 
                FlocWorkItem(funcloc, _, _, _, _, _, _, _, _, _).

            /// 1-to-1 work item to AI2_AIB_REFERENCE
            FlocCharacteristic(funcloc, "AIB_REFERENCE", "AI2_AIB_REFERENCE", 1, S4String(sainum)) :- 
                FlocAibRef(funcloc, sainum).                
        };
        solve (rules <+> workitems) project FlocCharacteristic


}
