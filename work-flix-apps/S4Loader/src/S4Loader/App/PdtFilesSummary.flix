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

namespace S4Loader/App/PdtFilesSummary {

    
    pub def pdtFilesSummary(): Result[Unit, String] & Impure =
        use Result.flatMap;
        let* dbpath     = S4Loader/App/Config.getS4LoaderDirectory() |> Result.map(flip(System/FilePath.snoc, "pdt_files.sqlite"));
        let* outpath    = S4Loader/App/Config.getWorkingDirectory() |> Result.map(flip(System/FilePath.snoc, "pdt_summary.xlsx"));
        let* r1         = PDTKit/Aggregate/Loader.readAll(dbpath);
        let relns       = r1 <+> PDTKit/Aggregate/Rules.makeAggregates();
        let* _          = PDTKit/Aggregate/ExcelOutput.outputExcel(relns, outpath);
        Ok()

}
