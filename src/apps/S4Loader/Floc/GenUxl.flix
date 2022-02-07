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

namespace S4Loader/Floc/GenUxl {
    
    use SheetIO/Reader.{XlsxSource};

    use AssetLib/S4Lite/Datatypes.{UxlOutput};
    use AssetLib/S4Lite/S4LiteRelations.{FlocCharacteristic};

    pub def genUxl(worklist: XlsxSource): Result[UxlOutput, String] & Impure =
        use Result.{flatMap};
        let* workitems      = S4Loader/Floc/WorkList.readFlocWorkList(worklist);
        let flocs           = List.map(S4Loader/Floc/WorkList.genSLFunctionalLocation, workitems) |> List.toChain;
        let r1              = S4Loader/Floc/WorkList.genFlocWorkItems(workitems);
        let r2              = S4Loader/Floc/Rules/FlocCharacteristics.deriveProperties(workitems);
        let db              = r1 <+> r2 <+> S4Loader/Floc/Rules/FlocCharacteristics.flocCharacteristics();
        let flocchars       = (solve db project FlocCharacteristic) |> AssetLib/S4Lite/S4LiteRelations.toSLFlocCharacteristics;
        let uxl             = AssetLib/S4Lite/Datatypes.emptyUxlSource();
        Ok({funclocs = flocs, funclocCharacteristics = flocchars | uxl})

        
}
