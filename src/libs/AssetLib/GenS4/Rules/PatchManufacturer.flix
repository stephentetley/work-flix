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

/// Improvement patch for manufacturer and model.

namespace AssetLib/GenS4/Rules/PatchManufacturer {

    use AssetLib/FileIO/S4/ZTable/Relations.{AllowedManufacturer, AllowedManufacturerModel};
    use AssetLib/S4Lite/Datatypes.{SLEquipment};
    use AssetLib/GenS4/Patch.{EquipmentPatches};

    pub rel ManufacturerModelPatch(equiId: String, manufacturer: String, model: String, partNumber: String)

    pub rel EquiWorkItem(equiId: String, objtype: String, manufacturer: String, model: String)

    pub rel HasAllowedManufacturer(objType: String)
    
    pub def genManufacturerModelPatches(db: #{AllowedManufacturer, AllowedManufacturerModel, 
                                                HasAllowedManufacturer, EquiWorkItem, ManufacturerModelPatch | r}, 
                            xs: List[SLEquipment]) : EquipmentPatches & Impure = 
        let rules = #{
            
            HasAllowedManufacturer(objType) :- AllowedManufacturer(objType, _).

            /// model becomes part number...
            ManufacturerModelPatch(equiId, "TO BE DETERMINED", "TO BE DETERMINED", model) :- 
                EquiWorkItem(equiId, objType, "UNKNOWN MANUFACTURER", model),
                AllowedManufacturer(objType, "TO BE DETERMINED").


        };
        let workitems = makeWorkItems(xs);
        solve (workitems <+> db <+> rules) project ManufacturerModelPatch
            |> makeEquipmentPatches


    def makeWorkItems(xs: List[SLEquipment]): #{EquiWorkItem | r} = 
        let mkWorkItem1 = x1 -> #{ 
            EquiWorkItem(x1.equiId, x1.objectType, x1.manufacturer, x1.model). 
        };
        List.foldLeft((ac, x1) -> ac <+> mkWorkItem1(x1), #{}, xs)


    def makeEquipmentPatches(relns: #{ManufacturerModelPatch | r}): EquipmentPatches & Impure = 
        let mm = MutMap.empty();
        let insert1 = row -> { 
            let (equiId, manufacturer, model, partNumber) = row;
            let update: SLEquipment -> SLEquipment = makePatch1(manufacturer, model, partNumber);
            MutMap.put!(equiId, update, mm)            
        }; 
        query relns select (w,x,y,z) from ManufacturerModelPatch(w,x,y,z) 
            |> Array.foreach(insert1);
        mm


    def makePatch1(manufacturer: String, model: String, partNumber: String, r1: SLEquipment): SLEquipment =
        {manufacturer = manufacturer, model = model, partNumber = partNumber | r1}

}

