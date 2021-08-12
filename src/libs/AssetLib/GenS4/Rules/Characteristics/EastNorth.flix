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
    use AssetLib/AibFacts/Attributes/LocationData.{Osgb36GridRef};
    use AssetLib/S4Lite/Datatypes.{SLFlocCharacteristic, SLEquiCharacteristic};
    use AssetLib/GenS4/WorkLists.{FlocWorkItem, EquiWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{FlocCharacteristic, EquiCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4Int};
    use AssetLib/GenS4/Rules/Characteristics/CommonRelations.{EquiWorkItem3};

    /// # Floc
    
    pub def genFlocEastNorth(worklist: List[FlocWorkItem]): Result[Chain[SLFlocCharacteristic], String] & Impure =
        use Result.{flatMap};
        let make1       = x1 -> #{ FlocEastNorthWorkItem(x1.funcloc, x1.gridRef). };
        let workitems   = List.foldLeft((ac, x) -> ac <+> make1(x), #{}, worklist);
        let ans         = flocEastNorth(workitems);
        Ok(ans) 

    /// Case specific WorkItem...
    pub rel FlocEastNorthWorkItem(floc: String, ngr: String)

    pub def flocEastNorth(workitems: #{FlocEastNorthWorkItem, FlocCharacteristic | r}): Chain[SLFlocCharacteristic] & Impure =
        use AssetLib/Base/Osgb36.{eastingfromOsgb36, northingfromOsgb36};
        let rules = #{
            FlocCharacteristic(funcloc, "EAST_NORTH", "EASTING", 1, S4Int(eastingfromOsgb36(ngr))) :- 
                FlocEastNorthWorkItem(funcloc, ngr).

            FlocCharacteristic(funcloc, "EAST_NORTH", "NORTHING", 1, S4Int(northingfromOsgb36(ngr))) :- 
                FlocEastNorthWorkItem(funcloc, ngr).
        };
        solve (rules <+> workitems) project FlocCharacteristic
            |> AssetLib/GenS4/S4LiteRelations.toSLFlocCharacteristic

    /// # Equi

    pub def genEquiEastNorth(worklist: List[EquiWorkItem], 
                            src: XlsxSource): Result[Chain[SLEquiCharacteristic], String] & Impure =
        use Result.{flatMap};
        let workitems   = AssetLib/GenS4/WorkLists.makeEquiWorkItem3(worklist);
        let* facts      = AssetLib/AibFacts/Attributes/LocationData.readOsgb36GridRefData(src);
        let ans         = equiEastNorth(facts <+> workitems);
        Ok(ans) 
        

    pub def equiEastNorth(input: #{EquiWorkItem3, Osgb36GridRef, EquiCharacteristic | r}): Chain[SLEquiCharacteristic] & Impure =
        use AssetLib/Base/Osgb36.{eastingfromOsgb36, northingfromOsgb36};
        let rules = #{            
            EquiCharacteristic(equiId, "EAST_NORTH", "EASTING", 1, S4Int(eastingfromOsgb36(ngr))) :- 
                EquiWorkItem3(equiId, _, _),
                Osgb36GridRef(equiId, ngr).

            EquiCharacteristic(equiId, "EAST_NORTH", "NORTHING", 1, S4Int(northingfromOsgb36(ngr))) :- 
                EquiWorkItem3(equiId, _, _),
                Osgb36GridRef(equiId, ngr).
        };
        solve (rules <+> input) project EquiCharacteristic
            |> AssetLib/GenS4/S4LiteRelations.toSLEquiCharacteristic

}
