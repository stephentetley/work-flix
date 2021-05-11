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


namespace AssetLib/GenS4/Rules/Characteristics/Emtr {

    use AssetLib/AibFacts/Relations.{AibStringValue};
    use AssetLib/GenS4/UploadRelations.{ValuaEquiFloat};
    use AssetLib/GenS4/WorkListRelations.{Phase2EquiItem, Phase1EquiItem};


    /// IP_RATING should be generated on per type (per class?)
    pub def emtr(): #{ValuaEquiFloat, Phase2EquiItem, Phase1EquiItem, AibStringValue | r} = 
        #{
            ValuaEquiText(equiId, "002", "IP_RATING", rating, 1) :- 
                Phase2EquiItem(equiId, name, floc,  "EMTR", _),
                Phase1EquiItem(aibref, name, floc,  _, _, _,  _),
                AibFloatValue(aibref, "IP_RATING", rating).
        }


}
