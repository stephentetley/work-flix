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

namespace S4Loader/App/PdtLint {

    /// TODO - output to xlsx file

    use PDTKit/Lint/Base/Schema.{Warning};


    pub def pdtLint(): Result[Unit, String] & Impure = 
        use Result.flatMap;
        let* pdtDB              = S4Loader/App/Config.getS4LoaderDirectory() |> Result.map(flip(System/FilePath.snoc, "pdt_files.sqlite"));
        let* assetTypesCsv      = S4Loader/App/Config.getAppConfigPath() |> Result.map(flip(System/FilePath.snoc, "pdt_asset_types.csv"));
        let* ztableObjTypeManuf = S4Loader/App/Config.getAppConfigPath() |> Result.map(flip(System/FilePath.snoc, "ztable-objtype-manuf.txt"));
        let* ztableManuModel    = S4Loader/App/Config.getAppConfigPath() |> Result.map(flip(System/FilePath.snoc, "ztable-manuf-model.txt"));
        let srcs    = 
            { pdtDB = pdtDB
            , assetTypesCsv = assetTypesCsv
            , ztableManuModel = ztableManuModel
            , ztableObjTypeManuf = ztableObjTypeManuf
            };
        // No output file yet...
        // let _dst     = System/FilePath.new("G:/work/assets/capital_schemes/sca05/sca05-pdt-lint.xlsx");
        let* relns  = PDTKit/Lint/Base/Loader.readAll(srcs);
        let ans     = 
            relns <+> PDTKit/Lint/Rules/ManufacturerModel.invalidManufacturerModel()
                <+> PDTKit/Lint/Rules/AssetName.invalidAssetName();
        query ans select (x1, x2, x3, x4) from Warning(x1, x2, x3, x4) |> Array.foreach(println);
        Ok()

}