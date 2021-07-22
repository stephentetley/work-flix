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

    type alias ManufacturerZTables = 
        { ztableObjManu: System.FilePath
        , ztableManuModel: System.FilePath
        }
    
    /// API is a fact loader and a translation function.
    /// It is two functions so we can load facts once, but translate multiple times 
    /// (e.g. if we have batches of SLEquipment)

    pub def loadFacts(src: ManufacturerZTables): Result[#{AllowedManufacturer, AllowedManufacturerModel | r}, String] & Impure = 
        use Result.flatMap;
        let* r1     = AssetLib/FileIO/S4/ZTable/Builtins.loadAllowedManufacturer(src.ztableObjManu);
        let* r2     = AssetLib/FileIO/S4/ZTable/Builtins.loadAllowedManufacturerModel(src.ztableManuModel);
        Ok(r1 <+> r2)


    pub def patchManufacturerModel(facts: #{AllowedManufacturer, AllowedManufacturerModel, 
                                                HasAllowedManufacturer, HasAllowedManufacturerModel, EquiWorkItem, ManufacturerModelPatch | r}, 
                                    xs: List[SLEquipment]): Result[List[SLEquipment], String] & Impure = 
        use Result.flatMap;
        let patches = genManufacturerModelPatches(facts, xs);
        Ok(AssetLib/GenS4/Patch.softPatchEquipment(patches, xs))

        

    pub rel ManufacturerModelPatch(equiId: String, manufacturer: String, model: String, partNumber: String)

    pub rel EquiWorkItem(equiId: String, objtype: String, manufacturer: String, model: String)

    pub rel HasAllowedManufacturer(objType: String)

    pub rel HasAllowedManufacturerModel(manufacturer: String)


    def genManufacturerModelPatches(db: #{AllowedManufacturer, AllowedManufacturerModel, 
                                                HasAllowedManufacturer, HasAllowedManufacturerModel, EquiWorkItem, ManufacturerModelPatch | r}, 
                            xs: List[SLEquipment]): EquipmentPatches & Impure = 
        let rules = #{
            
            HasAllowedManufacturer(objType) :- AllowedManufacturer(objType, "TO BE DETERMINED").
            HasAllowedManufacturerModel(manuf) :- AllowedManufacturerModel(manuf, "TO BE DETERMINED").

            /// model becomes part number...
            ManufacturerModelPatch(equiId, "TO BE DETERMINED", "TO BE DETERMINED", partNumber(model)) :- 
                EquiWorkItem(equiId, objType, "UNKNOWN MANUFACTURER", model),
                AllowedManufacturer(objType, "TO BE DETERMINED").

            /// model becomes part number...
            ManufacturerModelPatch(equiId, "NOT APPLICABLE", "NOT APPLICABLE", partNumber(model)) :- 
                EquiWorkItem(equiId, objType, "UNKNOWN MANUFACTURER", model),
                AllowedManufacturer(objType, "NOT APPLICABLE"), 
                not HasAllowedManufacturer(objType).

            /// Has manufacturer / model unknown
            ManufacturerModelPatch(equiId, manufacturer, "TO BE DETERMINED", "") :- 
                EquiWorkItem(equiId, objType, manufacturer, "UNSPECIFIED"),
                AllowedManufacturerModel(manufacturer, "TO BE DETERMINED").

            ManufacturerModelPatch(equiId, manufacturer, "NOT APPLICABLE", "") :- 
                EquiWorkItem(equiId, objType, manufacturer, "UNSPECIFIED"),
                AllowedManufacturerModel(manufacturer, "NOT APPLICABLE"),
                not HasAllowedManufacturerModel(objType).

        };
        let workitems = makeWorkItems(xs);
        solve (workitems <+> db <+> rules) project ManufacturerModelPatch
            |> makeEquipmentPatches

    def partNumber(s: String): String = if (s == "UNSPECIFIED") "" else s

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

