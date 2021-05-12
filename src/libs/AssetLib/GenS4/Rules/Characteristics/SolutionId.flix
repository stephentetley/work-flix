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

    use AssetLib/AibFacts/Relations.{AibStringValue};
    use AssetLib/GenS4/UploadRelations.{ClassEqui, ValuaEquiText};
    use AssetLib/GenS4/UxlRelations.{FlocCharacteristic, FlocDatum, EquiDatum, EquiCharacteristic};

    use AssetLib/GenS4/WorkListRelations.{Phase1EquiItem, Phase2EquiItem};



    /// This generates a SOLUTION_ID class and characteristic for every item in the change request list (pahase 1)
    /// that has a `Solution ID`.
    ///
    pub def equiSolutionId(): #{ClassEqui, ValuaEquiText, Phase1EquiItem, Phase2EquiItem | r} = 
        #{
            ClassEqui(equiId, "SOLUTION_ID", "002") :- 
                Phase2EquiItem(equiId, name, floc,  _, _),
                Phase1EquiItem(aibref, name, floc,  _, solutionId, _,  _, _, _),
                if not String.isEmpty(solutionId).

            ValuaEquiText(equiId, "002", "SOLUTION_ID", solutionId, 1) :-
                Phase2EquiItem(equiId, name, floc,  _, _),
                Phase1EquiItem(aibref, name, floc,  _, solutionId, _,  _, _, _),
                if not String.isEmpty(solutionId).
        }
        
    /// /// `solutionId` is parametric as should be supplied once for a translation
    /// /// so it is not a candidate for a fact.
    /// pub def uxlFlocSolutionId(soultionId: String): #{FlocDatum, FlocCharacteristic | r} =
    ///     #{
    ///         FlocCharacteristic(funcloc, "SOLUTION_ID", "SOLUTION_ID", solutionId) :- 
    ///             FlocDatum(funcloc, _, _,  _, _, _,  _),
    ///             if String.isEmpty(solutionId) == false.            
    ///     }

    /// /// `solutionId` is parametric as should be supplied once for a translation
    /// /// so it is not a candidate for a fact.
    /// pub def uxlEquiSolutionId(solutionId: String): #{EquiDatum, EquiCharacteristic | r} =
    ///     #{
    ///         EquiCharacteristic(aibref, "SOLUTION_ID", "SOLUTION_ID", solutionId) :- 
    ///             EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _, _, _),
    ///             if String.isEmpty(solutionId) == false.            
    ///     }

}
