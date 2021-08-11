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


namespace AssetLib/GenS4/Rules/Characteristics/SolutionId {

    use AssetLib/S4Lite/Datatypes.{SLFlocCharacteristic, SLEquiCharacteristic};
    use AssetLib/GenS4/WorkLists.{FlocWorkItemRec, FlocWorkItem, EquiWorkItemRec, EquiWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{FlocCharacteristic, EquiCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String};

    pub def genEquiSolutionId(worklist: List[EquiWorkItemRec]): Result[Chain[SLEquiCharacteristic], String] & Impure =
        use Result.{flatMap};
        let workitems   = makeWorkItems(worklist);
        let ans         = equiSolutionId(workitems) |> AssetLib/GenS4/S4LiteRelations.toSLEquiCharacteristic;
        Ok(ans) 

    /// Merits specific WorkItem...
    pub rel SolutionIdWorkItem(equiId: String, soulutionId: String)

    /// SolutionId specific
    def makeWorkItems(xs: List[EquiWorkItemRec]): #{SolutionIdWorkItem | r}  = 
        List.foldLeft((ac, x) -> ac <+> #{ SolutionIdWorkItem(x.equipmentId, x.solutionId). }, #{}, xs)


    /// This generates a SOLUTION_ID class and characteristic for every item in the change request list
    /// that has a `Solution ID`.
    ///
    pub def equiSolutionId(workitems: #{SolutionIdWorkItem, EquiCharacteristic | r}): #{EquiCharacteristic | r1} =
       let rules =  #{
            EquiCharacteristic(equiId, "SOLUTION_ID", "SOLUTION_ID", 1, S4String(solutionId)) :-  
                SolutionIdWorkItem(equiId, solutionId),
                if not String.isEmpty(solutionId).
        };
        solve (rules <+> workitems) project EquiCharacteristic
        
    pub def genFlocSolutionId(worklist: List[FlocWorkItemRec]): Result[Chain[SLFlocCharacteristic], String] & Impure =
        use Result.{flatMap};
        let workitems   = AssetLib/GenS4/WorkLists.makeFlocWorkItems(worklist);
        let ans         = flocSolutionId(workitems) |> AssetLib/GenS4/S4LiteRelations.toSLFlocCharacteristic;
        Ok(ans)

    pub def flocSolutionId(workitems: #{FlocWorkItem, FlocCharacteristic | r}): #{FlocCharacteristic | r} =
        let rules = #{
            FlocCharacteristic(funcloc, "SOLUTION_ID", "SOLUTION_ID", 1, S4String(solutionId)) :- 
                FlocWorkItem(funcloc, _, _, _, _, _, _, _, ngr, solutionId), 
                if not String.isEmpty(solutionId).
        };
        solve (rules <+> workitems) project FlocCharacteristic

}
