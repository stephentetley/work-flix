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


namespace AssetLib/GenS4/Rules/Characteristics/EastNorth {

    use AssetLib/AibFacts/HierarchyFacts.{AibEquipment};
    use AssetLib/GenS4/WorkListRelations.{Phase1Equi, Phase2Equi};
    use AssetLib/GenS4/UploadRelations.{ClassEqui, ValuaEquiText, ValuaEquiInt};
    use AssetLib/GenS4/UxlRelations.{EquiDatum, EquiCharacteristic};

    pub def equiEastNorth(): #{ClassEqui, ValuaEquiText, ValuaEquiInt, Phase1Equi, Phase2Equi, AibEquipment | r} =
        use AssetLib/Base/Osgb36.{eastingfromOsgb36, northingfromOsgb36};
        #{
            
            ClassEqui(equiId, "EAST_NORTH", "002") :- 
                Phase2Equi(equiId, name, description,  _, _),
                Phase1Equi(_, name, description,  _, _, _,  _).


            ValuaEquiInt(equiId, "002", "NORTHING", northingfromOsgb36(ngr), 1) :- 
                Phase2Equi(equiId, name, description,  _, _),
                Phase1Equi(aibref, name, description,  _, _, _,  _),
                AibEquipment(aibref, _, _,  _, _, _,  _, _, ngr,  _, _, _).

            ValuaEquiInt(equiId, "002", "NORTHING", northingfromOsgb36(ngr), 1) :- 
                Phase2Equi(equiId, name, description,  _, _),
                Phase1Equi(aibref, name, description,  _, _, _,  _),
                AibEquipment(aibref, _, _,  _, _, _,  _, _, ngr,  _, _, _).
        }

    pub def uxlEquiEastNorth(): #{EquiDatum, EquiCharacteristic, AibEquipment | r} =
        use AssetLib/Base/Osgb36.{eastingfromOsgb36, northingfromOsgb36};
        #{
            /// EAST_NORTH (generate if we have generated EquiDatum from AibEquipment)
            EquiCharacteristic(aibref, "EAST_NORTH", "EASTING", ToString.toString(eastingfromOsgb36(ngr))) :- 
                AibEquipment(aibref, _, _,  _, _, _,  _, _, ngr,  _, _, _),
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _, _).

            EquiCharacteristic(aibref, "EAST_NORTH", "NORTHING", ToString.toString(northingfromOsgb36(ngr))) :- 
                AibEquipment(aibref, _, _,  _, _, _,  _, _, ngr,  _, _, _),
                EquiDatum(aibref, _, _,  _, _, _,  _, _, _,  _, _, _,  _, _).
        }

}
