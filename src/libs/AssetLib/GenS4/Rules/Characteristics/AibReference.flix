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
    use AssetLib/GenS4/AibFacts/Attributes/AibReference.{ParentRef};
    use AssetLib/S4Lite/Datatypes.{SLFlocCharacteristic, SLEquiCharacteristic};
    use AssetLib/GenS4/WorkLists.{FlocWorkItem, EquiWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{FlocCharacteristic, EquiCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String};
    use AssetLib/GenS4/Rules/Characteristics/CommonRelations.{EquiWorkItem3};
    
    /// # Floc




    pub def genFlocAibReference(worklist: List[FlocWorkItem]): Result[Chain[SLFlocCharacteristic], String] & Impure =
        use Result.{flatMap};
        let workitems   = makeFlocAibRefWorkItems(worklist);
        let aibrefs     = List.foldLeft((ac, x) -> ac <+> makeFlocAibRef(x), #{}, worklist);
        let ans         = flocAibReference(workitems <+> aibrefs) |> AssetLib/GenS4/S4LiteRelations.toSLFlocCharacteristic;
        Ok(ans) 

    /// Case specific WorkItem...
    pub rel FlocAibRefWorkItem(floc: String)
    
    /// Local relation as a floc may have many sainums
    rel FlocAibRef(funcloc: String, sainum: String)

    def makeFlocAibRefWorkItems(xs: List[FlocWorkItem]): #{FlocAibRefWorkItem | r}  = 
        List.foldLeft((ac, x) -> ac <+> #{ FlocAibRefWorkItem(x.funcloc). }, #{}, xs)

    def makeFlocAibRef(x: FlocWorkItem): #{FlocAibRef | r} = 
        List.foldLeft((ac, sai) -> ac <+> #{ FlocAibRef(x.funcloc, sai). }, #{}, x.sainums)


    def flocAibReference(workitems: #{FlocAibRefWorkItem, FlocAibRef, FlocCharacteristic | r}): #{FlocCharacteristic | r} =
        let rules = #{
            
            /// 1-to-1 to work item
            FlocCharacteristic(funcloc, "AIB_REFERENCE", "S4_AIB_REFERENCE", 1, S4String("")) :- 
                FlocAibRefWorkItem(funcloc).

            /// 1-to-1 work item to AI2_AIB_REFERENCE
            FlocCharacteristic(funcloc, "AIB_REFERENCE", "AI2_AIB_REFERENCE", 1, S4String(sainum)) :- 
                FlocAibRef(funcloc, sainum).                
        };
        solve (rules <+> workitems) project FlocCharacteristic

    /// # Equi

    pub def genEquiAibReference(worklist: List[EquiWorkItem], src: XlsxSource): Result[Chain[SLEquiCharacteristic], String] & Impure =
        use Result.{flatMap};
        let workitems   = AssetLib/GenS4/WorkLists.makeEquiWorkItem3(worklist);
        let* facts      = AssetLib/GenS4/AibFacts/Attributes/AibReference.readHierarchyRelations(src);
        let ans         = equiAibReference(workitems <+> facts);
        Ok(ans) 


    /// 
    def equiAibReference(input: #{EquiWorkItem3, ParentRef, EquiCharacteristic | r}): Chain[SLEquiCharacteristic] & Impure =
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
            |> AssetLib/GenS4/S4LiteRelations.toSLEquiCharacteristic


}
