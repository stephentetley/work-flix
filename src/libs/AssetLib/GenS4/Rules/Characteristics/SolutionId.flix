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
    use AssetLib/GenS4/WorkLists.{FlocWorkItemRec, EquiWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{FlocCharacteristic, EquiCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String};


    /// # Floc



    pub def genFlocSolutionId(worklist: List[FlocWorkItemRec]): Result[Chain[SLFlocCharacteristic], String] & Impure =
        use Result.{flatMap};
        let workitems   = makeFlocSolnIdWorkItems(worklist);
        let ans         = flocSolutionId(workitems) |> AssetLib/GenS4/S4LiteRelations.toSLFlocCharacteristic;
        Ok(ans)

    /// Case specific WorkItem...
    pub rel FlocSolnIdWorkItem(floc: String, soulutionId: String)

    /// SolutionId specific
    def makeFlocSolnIdWorkItems(xs: List[FlocWorkItemRec]): #{FlocSolnIdWorkItem | r}  = 
        List.foldLeft((ac, x) -> ac <+> #{ FlocSolnIdWorkItem(x.funcloc, x.solutionId). }, #{}, xs)

    pub def flocSolutionId(input: #{FlocSolnIdWorkItem, FlocCharacteristic | r}): #{FlocCharacteristic | r} =
        let rules = #{
            FlocCharacteristic(funcloc, "SOLUTION_ID", "SOLUTION_ID", 1, S4String(solutionId)) :- 
                FlocSolnIdWorkItem(funcloc, solutionId), 
                if not String.isEmpty(solutionId).
        };
        solve (rules <+> input) project FlocCharacteristic


    /// # Equi

    pub def genEquiSolutionId(worklist: List[EquiWorkItem]): Result[Chain[SLEquiCharacteristic], String] & Impure =
        use Result.{flatMap};
        let workitems   = makeEquiSolnIdWorkItems(worklist);
        let ans         = equiSolutionId(workitems) |> AssetLib/GenS4/S4LiteRelations.toSLEquiCharacteristic;
        Ok(ans) 

    /// Case specific WorkItem...
    pub rel EquiSolnIdWorkItem(equiId: String, soulutionId: String)

    /// SolutionId specific
    def makeEquiSolnIdWorkItems(xs: List[EquiWorkItem]): #{EquiSolnIdWorkItem | r}  = 
        List.foldLeft((ac, x) -> ac <+> #{ EquiSolnIdWorkItem(x.equipmentId, x.solutionId). }, #{}, xs)


    /// This generates a SOLUTION_ID class and characteristic for every item in the change request list
    /// that has a `Solution ID`.
    ///
    pub def equiSolutionId(input: #{EquiSolnIdWorkItem, EquiCharacteristic | r}): #{EquiCharacteristic | r1} =
       let rules =  #{
            EquiCharacteristic(equiId, "SOLUTION_ID", "SOLUTION_ID", 1, S4String(solutionId)) :-  
                EquiSolnIdWorkItem(equiId, solutionId),
                if not String.isEmpty(solutionId).
        };
        solve (input <+> rules) project EquiCharacteristic
        
    
}
