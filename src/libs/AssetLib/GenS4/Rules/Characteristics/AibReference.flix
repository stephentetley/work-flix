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

    use AssetLib/S4Lite/Datatypes.{SLFlocCharacteristic, SLEquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.{FlocCharacteristic, EquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String};
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3, AibPliNum, AibParentRef};
    use AssetLib/GenS4/WorkLists.{FlocWorkItem, EquiWorkItem};

    
    /// # Floc

    pub def genFlocAibReference(worklist: List[FlocWorkItem]): Result[Chain[SLFlocCharacteristic], String] & Impure =
        use Result.{flatMap};
        let workitems   = makeFlocAibRefWorkItems(worklist);
        let aibrefs     = Relation.foldMap(makeFlocAibRef, worklist);
        let ans         = flocAibReference(workitems <+> aibrefs);
        Ok(ans) 

    /// Case specific WorkItem...
    pub rel FlocAibRefWorkItem(floc: String)
    
    /// Local relation as a floc may have many sainums
    rel FlocAibRef(funcloc: String, sainum: String)

    def makeFlocAibRefWorkItems(xs: List[FlocWorkItem]): #{FlocAibRefWorkItem | r}  = 
        Relation.foldMap(x1 -> #{ FlocAibRefWorkItem(x1.funcloc). }, xs)

    def makeFlocAibRef(x: FlocWorkItem): #{FlocAibRef | r} = 
        Relation.foldMap(x1 -> #{ FlocAibRef(x.funcloc, x1). }, x.sainums)


    pub def flocAibReference(input: #{FlocAibRefWorkItem, 
                                    FlocAibRef, FlocCharacteristic | r}): Chain[SLFlocCharacteristic] & Impure =
        let rules = #{
            
            /// 1-to-1 - 1 work item to 1 blank "S4_AIB_REFERENCE"
            FlocCharacteristic(funcloc, "AIB_REFERENCE", "S4_AIB_REFERENCE", 1, S4String("")) :- 
                FlocAibRefWorkItem(funcloc).

            /// 1-to-many - 1 funcloc to many "AI2_AIB_REFERENCE"
            FlocCharacteristic(funcloc, "AIB_REFERENCE", "AI2_AIB_REFERENCE", 1, S4String(sainum)) :- 
                FlocAibRef(funcloc, sainum).                
        };
        solve (rules <+> input) project FlocCharacteristic
            |> AssetLib/S4Lite/S4LiteRelations.toSLFlocCharacteristic


    /// # Equi

    pub def genEquiAibReference(worklist: List[EquiWorkItem], src: XlsxSource): Result[Chain[SLEquiCharacteristic], String] & Impure =
        use Result.{flatMap};
        let workitems   = AssetLib/GenS4/WorkLists.makeEquiWorkItem3(worklist);
        let* facts      = AssetLib/GenS4/AibFacts/Attributes/AibReference.readHierarchyRelations(src);
        let ans         = equiAibReference(workitems <+> facts);
        Ok(ans) 


    


    /// Use AibPliNum...
    pub def equiAibReference(input: #{EquiWorkItem3, AibPliNum, AibParentRef, 
                                        EquiCharacteristic | r}): Chain[SLEquiCharacteristic] & Impure =
        let rules = #{
            /// S4_AIB_REFERENCE (blank)
            EquiCharacteristic(equiId, "AIB_REFERENCE", "S4_AIB_REFERENCE", 1, S4String("")) :-
                EquiWorkItem3(equiId, _, _).

            /// AIB_REFERENCE (item)
            EquiCharacteristic(equiId, "AIB_REFERENCE", "AI2_AIB_REFERENCE", 1, S4String(pliNum)) :- 
                EquiWorkItem3(equiId, _, _),
                AibPliNum(equiId, pliNum).

            /// AI2_AIB_REFERENCE (parent)
            EquiCharacteristic(equiId, "AIB_REFERENCE", "AI2_AIB_REFERENCE", 2, S4String(parentSaiNum)) :- 
                EquiWorkItem3(equiId, _, _),
                AibParentRef(equiId, parentSaiNum), 
                if not String.isEmpty(parentSaiNum).
        };
        solve (rules <+> input) project EquiCharacteristic
            |> AssetLib/S4Lite/S4LiteRelations.toSLEquiCharacteristic


}
