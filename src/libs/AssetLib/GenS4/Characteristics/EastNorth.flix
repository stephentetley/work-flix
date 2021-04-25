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


namespace AssetLib/GenS4/Characteristics/EastNorth {

    use AssetLib/GenS4/Aib/HierarchicalRelations.{AibEquipment};
    use AssetLib/GenS4/S4Relations.{EquiDatum, EquiCharacteristic};

    pub def equiEastNorth(): #{EquiDatum, EquiCharacteristic, AibEquipment | r} =
        use AssetLib/Common/Osgb36.{eastingfromOsgb36, northingfromOsgb36};
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
