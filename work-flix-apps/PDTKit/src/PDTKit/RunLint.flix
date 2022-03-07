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

namespace PDTKit/RunLint {

    /// TODO make this a proper `main` with GetOpt or JSON params etc.

    use PDTKit/Lint/Base/Schema.{Warning, PdtValueRow, MetaPdtAssetType};


    pub def runLint(): Result[Unit, String] & Impure = 
        use Result.flatMap;
        let srcs    = 
            { pdtDB = System/FilePath.new("G:/work/assets/capital_schemes/sca05/sca05-pdt.sqlite")
            , assetTypesCsv = System/FilePath.new("E:/coding/work/work-flix/data/S4Loader_configs/pdt_asset_types.csv")
            , ztableManuModel = System/FilePath.new("G:/work/assets/facts/ztables/ztable-manuf-model.txt")
            , ztableObjTypeManuf = System/FilePath.new("G:/work/assets/facts/ztables/ztable-objtype-manuf.txt")
            };
        // Lint - no output yet...        
        let _dst     = System/FilePath.new("G:/work/assets/capital_schemes/sca05/sca05-pdt-lint.xlsx");
        let* relns  = PDTKit/Lint/Base/Loader.readAll(srcs);
        let ans     = 
            relns <+> PDTKit/Lint/Rules/ManufacturerModel.invalidManufacturerModel()
                <+> PDTKit/Lint/Rules/AssetName.invalidAssetName();
        query ans select (x1, x2, x3, x4) from Warning(x1, x2, x3, x4) |> Array.foreach(println);
        /// query ans select (x1, x2, x3, x4) from MetaPdtAssetType(x1, x2, x3, x4) |> Array.foreach(println);
        Ok()

}