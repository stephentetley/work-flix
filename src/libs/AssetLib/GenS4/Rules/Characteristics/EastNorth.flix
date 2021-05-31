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
    use AssetLib/GenS4/WorkListRelations.{FlocWorkItem, Phase1EquiItem, Phase2EquiItem};
    use AssetLib/GenS4/UploadRelations.{ClassEqui, ValuaEquiString, ValuaEquiInt};
    use AssetLib/GenS4/UxlRelations.{EquiDatum, EquiCharacteristic};

    use AssetLib/GenS4/S4LiteRelations.{FlocCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4Int};


    pub def equiEastNorth(): #{ClassEqui, ValuaEquiString, ValuaEquiInt, Phase1EquiItem, Phase2EquiItem, AibEquipment | r} =
        use AssetLib/Base/Osgb36.{eastingfromOsgb36, northingfromOsgb36};
        #{
            
            ClassEqui(equiId, "EAST_NORTH", "002") :- 
                Phase2EquiItem(equiId, name, floc,  _, _),
                Phase1EquiItem(_, name, floc,  _, _, _,  _, _, _).


            ValuaEquiInt(equiId, "002", "EASTING", eastingfromOsgb36(ngr), 1) :- 
                Phase2EquiItem(equiId, name, floc,  _, _),
                Phase1EquiItem(aibref, name, floc,  _, _, _,  _, _, _),
                AibEquipment(aibref, _, _,  _, _, _,  ngr, _, _).

            ValuaEquiInt(equiId, "002", "NORTHING", northingfromOsgb36(ngr), 1) :- 
                Phase2EquiItem(equiId, name, floc,  _, _),
                Phase1EquiItem(aibref, name, floc,  _, _, _,  _, _, _),
                AibEquipment(aibref, _, _,  _, _, _,  ngr, _, _).
        }

    pub def flocEastNorth(workitems: #{FlocWorkItem, FlocCharacteristic | r}): #{FlocCharacteristic | r} =
        use AssetLib/Base/Osgb36.{eastingfromOsgb36, northingfromOsgb36};
        let rules = #{
            FlocCharacteristic(funcloc, "EAST_NORTH", "EASTING", S4Int(eastingfromOsgb36(ngr))) :- 
                FlocWorkItem(funcloc, _, _, _, _, _, _, _, _, ngr, _).

            FlocCharacteristic(funcloc, "EAST_NORTH", "NORTHING", S4Int(northingfromOsgb36(ngr))) :- 
                FlocWorkItem(funcloc, _, _, _, _, _, _, _, _, ngr, _).
        };
        solve (rules <+> workitems) project FlocCharacteristic

}
