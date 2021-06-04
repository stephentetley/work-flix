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

    use AssetLib/GenS4/WorkLists.{FlocWorkItem, EquiWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{FlocCharacteristic, EquiCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String};



    /// This generates a SOLUTION_ID class and characteristic for every item in the change request list
    /// that has a `Solution ID`.
    ///
    pub def equiSolutionId(workitems: #{EquiWorkItem, EquiCharacteristic | r}): #{EquiCharacteristic | r} =
       let rules =  #{
            EquiCharacteristic(equiId, "SOLUTION_ID", "SOLUTION_ID", 1, S4String(solutionId)) :-  
                EquiWorkItem(equiId, _, _,  _, solutionId, _,  _, _, _),
                if not String.isEmpty(solutionId).
        };
        solve (rules <+> workitems) project EquiCharacteristic
        

    pub def flocSolutionId(workitems: #{FlocWorkItem, FlocCharacteristic | r}): #{FlocCharacteristic | r} =
        let rules = #{
            FlocCharacteristic(funcloc, "SOLUTION_ID", "SOLUTION_ID", 1, S4String(solutionId)) :- 
                FlocWorkItem(funcloc, _, _, _, _, _, _, _, _, ngr, solutionId), 
                if not String.isEmpty(solutionId).
        };
        solve (rules <+> workitems) project FlocCharacteristic

}
