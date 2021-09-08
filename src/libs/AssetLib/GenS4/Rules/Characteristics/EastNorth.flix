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

    use AssetLib/S4Lite/Datatypes.{SLFlocCharacteristic, SLEquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.{FlocCharacteristic, EquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4Int};
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3, NationalGridRef};
    use AssetLib/GenS4/WorkLists.{FlocWorkItem, EquiWorkItem};

    /// # Floc
    
    pub def genFlocEastNorth(worklist: List[FlocWorkItem]): GenMonad[Unit] =
        use AssetLib/GenS4/GenMonad.{flatMap};
        let make1       = x1 -> #{ FlocEastNorthWorkItem(x1.funcloc, x1.gridRef). };
        let workitems   = RelLib/Relation.foldMap(make1, worklist);
        flocEastNorth(workitems)

    /// Case specific WorkItem...
    pub rel FlocEastNorthWorkItem(floc: String, ngr: String)

    pub def flocEastNorth(workitems: #{FlocEastNorthWorkItem, FlocCharacteristic | r}): GenMonad[Unit] =
        use AssetLib/Base/Osgb36.{eastingfromOsgb36, northingfromOsgb36};
        let rules = #{
            FlocCharacteristic(funcloc, "EAST_NORTH", "EASTING", 1, S4Int(eastingfromOsgb36(ngr))) :- 
                FlocEastNorthWorkItem(funcloc, ngr).

            FlocCharacteristic(funcloc, "EAST_NORTH", "NORTHING", 1, S4Int(northingfromOsgb36(ngr))) :- 
                FlocEastNorthWorkItem(funcloc, ngr).
        };
        AssetLib/GenS4/GenMonad.tellFlocCharacteristics(rules <+> workitems)

    /// # Equi

    pub def genEquiEastNorth(worklist: List[EquiWorkItem], src: XlsxSource): GenMonad[Unit] =
        use AssetLib/GenS4/GenMonad.{flatMap};
        let workitems   = AssetLib/GenS4/WorkLists.makeEquiWorkItem3(worklist);
        let* facts      = AssetLib/GenS4/AibFacts/Attributes/LocationData.readNationalGridRefData(src);
        equiEastNorth(facts <+> workitems) 
        

    pub def equiEastNorth(input: #{EquiWorkItem3, NationalGridRef, EquiCharacteristic | r}): GenMonad[Unit] =
        use AssetLib/Base/Osgb36.{eastingfromOsgb36, northingfromOsgb36};
        let rules = #{            
            EquiCharacteristic(equiId, "EAST_NORTH", "EASTING", 1, S4Int(eastingfromOsgb36(ngr))) :- 
                EquiWorkItem3(equiId, _, _),
                NationalGridRef(equiId, ngr).

            EquiCharacteristic(equiId, "EAST_NORTH", "NORTHING", 1, S4Int(northingfromOsgb36(ngr))) :- 
                EquiWorkItem3(equiId, _, _),
                NationalGridRef(equiId, ngr).
        };
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(rules <+> input)

}
