/*
 * Copyright 2020 Stephen Tetley
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


namespace AssetLib/FileIO/S4/ZTable/Builtins {

    use Functor.{<$>};
    use Applicative.{<*>};

    use FlixSandbox/System.FilePath;

    use AssetLib/FileIO/S4/ZTable/Datatypes.{EquiObject, 
        FlocObject, FlocDescription, ObjTypeManufacturer, ManufacturerModel};
    use AssetLib/FileIO/S4/ZTable/Parser.{importRows};
    use AssetLib/FileIO/S4/ZTable/Relations.{SuperSubEquipObject, 
        SuperSubFlocObject, FlocObjectDescription, AllowedManufacturer, 
        AllowedManufacturerModel};
    use AssetLib/FileIO/S4/ZTable.RowEvaluator;

    // EquipObject

    pub def loadSuperSubEquiObject(path: FilePath): Result[#{SuperSubEquipObject | rln}, String] & Impure = 
        let build = RelLib/Relation.foldMap(x1 -> #{ SuperSubEquipObject(x1.parent, x1.child, x1.category). });
        loadEquiObject(path)
            |> Result.map(build)

    pub def loadEquiObject(path: FilePath): Result[List[EquiObject], String] & Impure =        
        importRows(evalEquiObject(), path)  

    def evalEquiObject(): RowEvaluator[r, EquiObject] = 
        use AssetLib/FileIO/S4/ZTable/RowEvaluator.{getStringAt};
        ((x1, x2, x3) -> {parent = x1, child = x2, category = x3})
            <$> getStringAt(0)
            <*> getStringAt(1)
            <*> getStringAt(2)
        

    // FlocObject

    pub def loadSuperSubFlocObject(path: FilePath): Result[#{SuperSubFlocObject | rln}, String] & Impure = 
        let build = RelLib/Relation.foldMap(x1 -> #{ SuperSubFlocObject(x1.parent, x1.child, x1.structure). });
        loadFlocObject(path)
            |> Result.map(build)

    pub def loadFlocObject(path: FilePath): Result[List[FlocObject], String] & Impure =
        importRows(evalFlocObject(), path)  

    def evalFlocObject(): RowEvaluator[r, FlocObject] = 
        use AssetLib/FileIO/S4/ZTable/RowEvaluator.{getStringAt};
        ((x1, x2, x3) -> {structure = x1, parent = x2, child = x3})
            <$> getStringAt(0)
            <*> getStringAt(1)
            <*> getStringAt(2)
        

    // FlocDescription
    
    pub def loadFlocObjectDescription(path: FilePath): Result[#{FlocObjectDescription | rln}, String] & Impure = 
        let build = RelLib/Relation.foldMap(x1 -> #{ FlocObjectDescription(x1.objectType, x1.description). });
        loadFlocDescription(path)
            |> Result.map(build)

    pub def loadFlocDescription(path: FilePath): Result[List[FlocDescription], String] & Impure =
        importRows(evalFlocDescription(), path)           

    def evalFlocDescription(): RowEvaluator[r, FlocDescription] = 
        use AssetLib/FileIO/S4/ZTable/RowEvaluator.{flatMap, point, getStringAt};
        let* objtype    = getStringAt(0);
        let* desc       = getStringAt(1);
        point({objectType = objtype, description = desc})

    // ObjTypeManufacturer
    
    pub def loadAllowedManufacturer(path: FilePath): Result[#{AllowedManufacturer | rln}, String] & Impure = 
        let build = RelLib/Relation.foldMap(x1 -> #{ AllowedManufacturer(x1.objectType, x1.manufacturer). });
        loadObjTypeManufacturer(path)
            |> Result.map(build)

    pub def loadObjTypeManufacturer(path: FilePath): Result[List[ObjTypeManufacturer], String] & Impure =
        importRows(evalObjTypeManufacturer(), path)  

    def evalObjTypeManufacturer(): RowEvaluator[r, ObjTypeManufacturer] = 
        use AssetLib/FileIO/S4/ZTable/RowEvaluator.{flatMap, point, getStringAt};
        let* objectty   = getStringAt(0);
        let* manuf      = getStringAt(1);
        point({objectType = objectty, manufacturer = manuf})

    // ManufacturerModel
    
    pub def loadAllowedManufacturerModel(path: FilePath): Result[#{AllowedManufacturerModel | rln}, String] & Impure = 
        let build = RelLib/Relation.foldMap(x1 -> #{ AllowedManufacturerModel(x1.manufacturer, x1.model). });
        loadManufacturerModel(path)
            |> Result.map(build)

    pub def loadManufacturerModel(path: FilePath): Result[List[ManufacturerModel], String] & Impure =
        importRows(evalManufacturerModel(), path)   

    def evalManufacturerModel(): RowEvaluator[r, ManufacturerModel] = 
        use AssetLib/FileIO/S4/ZTable/RowEvaluator.{flatMap, point, getStringAt};
        let* manuf      = getStringAt(0);
        let* modl       = getStringAt(1);
        point({manufacturer = manuf, model = modl})

}
