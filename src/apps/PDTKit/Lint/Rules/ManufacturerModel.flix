/*
 * Copyright 2022 Stephen Tetley
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

namespace PDTKit/Lint/Rules/ManufacturerModel {

    use PDTKit/Lint/Base/Schema.{Warning, PdtValueRow, MetaPdtAssetType};

    pub type alias InvalidManufacturer[r1: SchemaRow] = 
        #{Warning, PdtValueRow, MetaPdtAssetType, ZTableObjTypeManufacturer, ZTableManufModel | r1}

    pub rel ZTableObjTypeManufacturer(objType: String, manu: String)

    pub rel ZTableManufModel(manu: String, model: String)

    pub def invalidManufacturerModel(): InvalidManufacturer[r1] = 
        
        #{
            
            
            ///
            Warning(sourceFile, row, column, invalidManufacturerMsg(manu, assetName, objType)) :- 
                PdtValueRow(sourceFile, row, column, assetName, "Manufacturer", manu),
                PdtValueRow(sourceFile, _, column, assetName, "Asset Type", assetType),
                MetaPdtAssetType(assetType, _, objType, _),
                not ZTableObjTypeManufacturer(objType, manu).

            Warning(sourceFile, row, column, invalidModelMsg(manu, assetName, model)) :- 
                PdtValueRow(sourceFile, _, column, assetName, "Manufacturer", manu),
                PdtValueRow(sourceFile, row, column, assetName, "Product range", model),
                PdtValueRow(sourceFile, _, column, assetName, "Asset Type", assetType),
                MetaPdtAssetType(assetType, _, objType, _),
                ZTableObjTypeManufacturer(objType, manu),
                not ZTableManufModel(manu, model).

        }

    def invalidManufacturerMsg(manu: String, assetName: String, objType: String): String = 
        "Invalid manufacturer '${manu}' for asset '${assetName}' (object type: ${objType})"

    def invalidModelMsg(manu: String, assetName: String, model: String): String = 
        "Invalid model '${model}' for asset '${assetName}' (manufacturer: '${manu}')"


}
