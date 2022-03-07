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

namespace PDTKit/Lint/Base/Schema {


    pub rel Warning(sourceFile : String, row: Int32, column: Int32, message: String)

    pub rel PdtValueRow(sourceFile: String, row: Int32, column: Int32, assetName: String, fieldName: String, fieldValue: String)
                
    pub rel MetaPdtAssetType(pdtAssetName: String, s4Category: String, s4ObjType: String, s4Class: String)
    
    pub rel ZObjTypeManufacturer(objType: String, manu: String)

    pub rel ZManufModel(manu: String, model: String)


}
