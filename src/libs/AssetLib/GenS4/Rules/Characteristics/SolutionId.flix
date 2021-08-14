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
    use AssetLib/S4Lite/S4LiteRelations.{FlocCharacteristic, EquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String};
    use AssetLib/GenS4/WorkLists.{FlocWorkItem, EquiWorkItem};


    /// # Floc



    pub def genFlocSolutionId(worklist: List[FlocWorkItem]): Result[Chain[SLFlocCharacteristic], String] & Impure =
        use Result.{flatMap};
        let make1       = x1 -> #{ FlocSolnIdWorkItem(x1.funcloc, x1.solutionId). };
        let workitems   = Relation.foldMap(make1, worklist);
        let ans         = flocSolutionId(workitems);
        Ok(ans)

    /// Case specific WorkItem...
    pub rel FlocSolnIdWorkItem(floc: String, soulutionId: String)


    pub def flocSolutionId(input: #{FlocSolnIdWorkItem, FlocCharacteristic | r}): Chain[SLFlocCharacteristic] & Impure =
        let rules = #{
            FlocCharacteristic(funcloc, "SOLUTION_ID", "SOLUTION_ID", 1, S4String(solutionId)) :- 
                FlocSolnIdWorkItem(funcloc, solutionId), 
                if not String.isEmpty(solutionId).
        };
        solve (rules <+> input) project FlocCharacteristic
            |> AssetLib/S4Lite/S4LiteRelations.toSLFlocCharacteristic

    /// # Equi

    pub def genEquiSolutionId(worklist: List[EquiWorkItem]): Result[Chain[SLEquiCharacteristic], String] & Impure =
        use Result.{flatMap};
        let make1       = x1 -> #{ EquiSolnIdWorkItem(x1.equipmentId, x1.solutionId). };
        let workitems   = Relation.foldMap(make1, worklist);
        let ans         = equiSolutionId(workitems);
        Ok(ans) 

    /// Case specific WorkItem...
    pub rel EquiSolnIdWorkItem(equiId: String, soulutionId: String)


    /// This generates a SOLUTION_ID class and characteristic for every item in the change request list
    /// that has a `Solution ID`.
    ///
    pub def equiSolutionId(input: #{EquiSolnIdWorkItem, EquiCharacteristic | r}): Chain[SLEquiCharacteristic] & Impure =
       let rules =  #{
            EquiCharacteristic(equiId, "SOLUTION_ID", "SOLUTION_ID", 1, S4String(solutionId)) :-  
                EquiSolnIdWorkItem(equiId, solutionId),
                if not String.isEmpty(solutionId).
        };
        solve (input <+> rules) project EquiCharacteristic
            |> AssetLib/S4Lite/S4LiteRelations.toSLEquiCharacteristic
    
}
