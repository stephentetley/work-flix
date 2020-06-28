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

use FactIO/FlatFile.RowEvaluator;

use AssetLib/S4/FileReaders/ZTable/Relations.{ManufacturerModel, ObjectTypeManufacturer};

namespace AssetLib/S4/FileReaders/ZTable/BuiltinLoaders {


    def manufacturerModelEval[r](): RowEvaluator[#{ ManufacturerModel | r }] = 
        use FactIO/FlatFile/RowEvaluator.{flatMap, return, getString};
        let* manuf      = getString(0);
        let* model      = getString(1);
        return( ManufacturerModel(manuf, model). )


    pub def loadManufacturerModel[r](path: String): Result[#{ ManufacturerModel | r }, System.Error] & Impure =
        use AssetLib/S4/FileReaders/ZTable/FactParser.{importRows};
        importRows(manufacturerModelEval(), path)   

    def objectTypeManufacturerEval[r](): RowEvaluator[#{ ObjectTypeManufacturer | r }] = 
        use FactIO/FlatFile/RowEvaluator.{flatMap, return, getString};
        let* objtype    = getString(0);
        let* manuf      = getString(1);       
        return( ObjectTypeManufacturer(objtype, manuf). )

    pub def loadObjectTypeManufacturer[r](path: String): Result[#{ ObjectTypeManufacturer | r }, System.Error] & Impure =
        use AssetLib/S4/FileReaders/ZTable/FactParser.{importRows};
        importRows(objectTypeManufacturerEval(), path)  

}