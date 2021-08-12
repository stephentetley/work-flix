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
        let workitems   = makeFlocEastNorthWorkItems(worklist);
        let ans         = flocEastNorth(workitems) |> AssetLib/GenS4/S4LiteRelations.toSLFlocCharacteristic;
        Ok(ans) 

    /// Case specific WorkItem...
    rel FlocEastNorthWorkItem(floc: String, ngr: String)


    def makeFlocEastNorthWorkItems(xs: List[FlocWorkItem]): #{FlocEastNorthWorkItem | r}  = 
        List.foldLeft((ac, x) -> ac <+> #{ FlocEastNorthWorkItem(x.funcloc, x.gridRef). }, #{}, xs)


    pub def flocEastNorth(workitems: #{FlocEastNorthWorkItem, FlocCharacteristic | r}): #{FlocCharacteristic | r} =
        use AssetLib/Base/Osgb36.{eastingfromOsgb36, northingfromOsgb36};
        let rules = #{
            FlocCharacteristic(funcloc, "EAST_NORTH", "EASTING", 1, S4Int(eastingfromOsgb36(ngr))) :- 
                FlocEastNorthWorkItem(funcloc, ngr).

            FlocCharacteristic(funcloc, "EAST_NORTH", "NORTHING", 1, S4Int(northingfromOsgb36(ngr))) :- 
                FlocEastNorthWorkItem(funcloc, ngr).
        };
        solve (rules <+> workitems) project FlocCharacteristic


    /// # Equi

    pub def genEquiEastNorth(worklist: List[EquiWorkItem], 
                            src: XlsxSource): Result[Chain[SLEquiCharacteristic], String] & Impure =
        use Result.{flatMap};
        let* facts      = AssetLib/AibFacts/Attributes/LocationData.readOsgb36GridRefData(src);
        let workitems   = makeWorkItems(worklist);
        let ans         = equiEastNorth(facts <+> workitems) |> AssetLib/GenS4/S4LiteRelations.toSLEquiCharacteristic;
        Ok(ans) 

    /// Where to put this?
    def makeWorkItems(xs: List[EquiWorkItem]): #{EquiWorkItem3 | r}  = 
        List.foldLeft((ac, x) -> ac <+> #{ EquiWorkItem3(x.equipmentId, x.s4EquiType, x.s4EquiClass). }, #{}, xs)

    pub def equiEastNorth(input: #{EquiWorkItem3, Osgb36GridRef, EquiCharacteristic | r}): #{EquiCharacteristic | r} =
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


}
