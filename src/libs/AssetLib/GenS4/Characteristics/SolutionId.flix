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


namespace AssetLib/GenS4/Characteristics/SolutionId {

    use AssetLib/GenS4/S4Relations.{FlocCharacteristic, FlocDatum, EquiDatum, EquiCharacteristic};



    /// `solutionId` is parametric as should be supplied once for a translation
    /// so it is not a candidate for a fact.
    pub def flocSolutionId(solutionId: String): #{FlocDatum, FlocCharacteristic | r} =
        #{
            FlocCharacteristic(funcloc, "SOLUTION_ID", "SOLUTION_ID", solutionId) :- 
                FlocDatum(funcloc, _, _,  _, _, _,  _),
                if String.isEmpty(solutionId) == false.            
        }

    /// `solutionId` is parametric as should be supplied once for a translation
    /// so it is not a candidate for a fact.
    pub def equiSolutionId(solutionId: String): #{EquiDatum, EquiCharacteristic | r} =
        #{
            EquiCharacteristic(aibref, "SOLUTION_ID", "SOLUTION_ID", solutionId) :- 
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _),
                if String.isEmpty(solutionId) == false.            
        }
}
