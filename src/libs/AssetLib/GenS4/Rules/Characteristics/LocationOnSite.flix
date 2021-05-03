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


namespace AssetLib/GenS4/Rules/Characteristics/LocationOnSite {

    use AssetLib/AibFacts/Relations.{AibStringValue};
    use AssetLib/GenS4/UploadRelations.{ValuaEquiText};
    use AssetLib/GenS4/WorkListRelations.{Phase2EquiItem, Phase1EquiItem};


    /// Common to all equipment - upload characteristics don't need to be linked to a class,
    /// but a class with that characteristic as a member has to exist.
    pub def equiLocationOnSite(): #{ValuaEquiText, Phase2EquiItem, Phase1EquiItem, AibStringValue | r} = 
        #{
            ValuaEquiText(equiId, "002", "LOCATION_ON_SITE", s4Location(location), 1) :- 
                Phase2EquiItem(equiId, name, floc,  _, _),
                Phase1EquiItem(aibref, name, floc,  _, _, _,  _),
                AibStringValue(aibref, "LOCATION_ON_SITE", location).
        }


    def s4Location(s: String): String =
        if (String.length(s) >= 30) "SEE LONG TEXT" else s

}
