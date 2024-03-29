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


namespace AssetDS/ZTable/Builtins {

    use Functor.{<$>};
    use Applicative.{<*>};

    use Basis/NIO/File.Path;

    use AssetDS/ZTable/Datatypes.{EquiObject, 
        FlocObject, FlocDescription, ObjTypeManufacturer, ManufacturerModel};
    use AssetDS/ZTable/Parser.{importRows};
    use AssetDS/ZTable.RowEvaluator;

    // EquipObject
    pub def loadEquiObject(path: Path): Result[List[EquiObject], String] \ IO =        
        region r1 {
            importRows(r1, evalEquiObject(), path)
        }

    def evalEquiObject(): RowEvaluator[r, EquiObject, EquiObject] \ Read(r) = 
        use AssetDS/ZTable/RowEvaluator.{getStringAt};
        ((x1, x2, x3) -> {parent = x1, child = x2, category = x3})
            <$> getStringAt(0)
            <*> getStringAt(1)
            <*> getStringAt(2)
        

    // FlocObject
    pub def loadFlocObject(path: Path): Result[List[FlocObject], String] \ IO =
        region r1 {
            importRows(r1, evalFlocObject(), path)
        }

    def evalFlocObject(): RowEvaluator[r, FlocObject, FlocObject] \ Read(r) = 
        use AssetDS/ZTable/RowEvaluator.{getStringAt};
        ((x1, x2, x3) -> {structure = x1, parent = x2, child = x3})
            <$> getStringAt(0)
            <*> getStringAt(1)
            <*> getStringAt(2)
        

    // FlocDescription
    pub def loadFlocDescription(path: Path): Result[List[FlocDescription], String] \ IO =
        region r1 {
            importRows(r1, evalFlocDescription(), path)
        }

    def evalFlocDescription(): RowEvaluator[r, FlocDescription, FlocDescription] \ Read(r) = 
        use AssetDS/ZTable/RowEvaluator.{flatMap, point, getStringAt};
        let* objtype    = getStringAt(0);
        let* desc       = getStringAt(1);
        point({objectType = objtype, description = desc})

    // ObjTypeManufacturer
    pub def loadObjTypeManufacturer(path: Path): Result[List[ObjTypeManufacturer], String] \ IO =
        region r1 {
            importRows(r1, evalObjTypeManufacturer(), path)
        }

    def evalObjTypeManufacturer(): RowEvaluator[r, ObjTypeManufacturer, ObjTypeManufacturer] \ Read(r) = 
        use AssetDS/ZTable/RowEvaluator.{flatMap, point, getStringAt};
        let* objectty   = getStringAt(0);
        let* manuf      = getStringAt(1);
        point({objectType = objectty, manufacturer = manuf})

    // ManufacturerModel
    pub def loadManufacturerModel(path: Path): Result[List[ManufacturerModel], String] \ IO =
        region r1 {
            importRows(r1, evalManufacturerModel(), path)
        }

    def evalManufacturerModel(): RowEvaluator[r, ManufacturerModel, ManufacturerModel] \ Read(r) = 
        use AssetDS/ZTable/RowEvaluator.{flatMap, point, getStringAt};
        let* manuf      = getStringAt(0);
        let* modl       = getStringAt(1);
        point({manufacturer = manuf, model = modl})

}
