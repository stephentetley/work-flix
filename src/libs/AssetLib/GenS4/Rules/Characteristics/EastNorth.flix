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

    use SheetIO/Reader.{XlsxSource};
    use AssetLib/AibFacts/Attributes/Equipment.{Osgb36GridRef};
    use AssetLib/S4Lite/Datatypes.{SLFlocCharacteristic, SLEquiCharacteristic};
    use AssetLib/GenS4/WorkLists.{FunclocWorkItem, FlocWorkItem, EquipmentWorkItem, EquiWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{FlocCharacteristic, EquiCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4Int};
    
    pub def genEquiEastNorth(worklist: List[EquipmentWorkItem], 
                            src: XlsxSource): Result[Chain[SLEquiCharacteristic], String] & Impure =
        use Result.{flatMap};
        let* facts      = AssetLib/AibFacts/Attributes/Equipment.readOsgb36GridRefData(src);
        let workitems   = AssetLib/GenS4/WorkLists.makeEquiWorkItems(worklist);
        let ans         = equiEastNorth(facts <+> workitems) |> AssetLib/GenS4/S4LiteRelations.toSLEquiCharacteristic;
        Ok(ans) 

    pub def equiEastNorth(input: #{EquiWorkItem, Osgb36GridRef, EquiCharacteristic | r}): #{EquiCharacteristic | r} =
        use AssetLib/Base/Osgb36.{eastingfromOsgb36, northingfromOsgb36};
        let rules = #{            
            EquiCharacteristic(equiId, "EAST_NORTH", "EASTING", 1, S4Int(eastingfromOsgb36(ngr))) :- 
                EquiWorkItem(equiId, _, _,  _, _, _,  _, _, _),
                Osgb36GridRef(equiId, ngr).

            EquiCharacteristic(equiId, "EAST_NORTH", "NORTHING", 1, S4Int(northingfromOsgb36(ngr))) :- 
                EquiWorkItem(equiId, _, _,  _, _, _,  _, _, _),
                Osgb36GridRef(equiId, ngr).
        };
        solve (rules <+> input) project EquiCharacteristic


    pub def genFlocEastNorth(worklist: List[FunclocWorkItem]): Result[Chain[SLFlocCharacteristic], String] & Impure =
        use Result.{flatMap};
        let workitems   = AssetLib/GenS4/WorkLists.makeFlocWorkItems(worklist);
        let ans         = flocEastNorth(workitems) |> AssetLib/GenS4/S4LiteRelations.toSLFlocCharacteristic;
        Ok(ans) 

    pub def flocEastNorth(workitems: #{FlocWorkItem, FlocCharacteristic | r}): #{FlocCharacteristic | r} =
        use AssetLib/Base/Osgb36.{eastingfromOsgb36, northingfromOsgb36};
        let rules = #{
            FlocCharacteristic(funcloc, "EAST_NORTH", "EASTING", 1, S4Int(eastingfromOsgb36(ngr))) :- 
                FlocWorkItem(funcloc, _, _, _, _, _, _, _, _, ngr, _).

            FlocCharacteristic(funcloc, "EAST_NORTH", "NORTHING", 1, S4Int(northingfromOsgb36(ngr))) :- 
                FlocWorkItem(funcloc, _, _, _, _, _, _, _, _, ngr, _).
        };
        solve (rules <+> workitems) project FlocCharacteristic

}
