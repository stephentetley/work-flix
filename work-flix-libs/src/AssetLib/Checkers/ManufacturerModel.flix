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


namespace AssetLib/Checkers/ManufacturerModel {

    
    pub rel ManufacturerModel(manufacturer: String, model: String)

    pub rel ObjectTypeManufacturer(objtype: String, manufacturer: String)

    pub rel Failure(rowId: Int32, description: String)
    pub rel Row(rowId: Int32, objtype: String, manufacturer: String, model: String)

    // We are checking for failures - not successes...
    pub def checkManufacturerModel(): #{ObjectTypeManufacturer, ManufacturerModel, Row, Failure | r} = #{

        Failure(rowId, "Manufacturer '${manufacturer}' not recognized for object type ${objtype}") :- 
            Row(rowId, objtype, manufacturer, _), 
            not ObjectTypeManufacturer(objtype, manufacturer).

       Failure(rowId, "Model '${model}' not recognized for manufacturer ${manufacturer}") :- 
            Row(rowId, _, manufacturer, model), 
            not ManufacturerModel(manufacturer, model).

    }
}