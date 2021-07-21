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


namespace AssetLib/GenS4/GenFlocs {

    use SheetIO/Reader.{XlsxSource};
    use AssetLib/S4Lite/Datatypes.{UxlSource, SLFunctionalLocation, SLFlocCharacteristic};
    use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
    use AssetLib/GenS4/WorkLists.{FlocWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{FlocCharacteristic};



    pub def emitFlocUxl(workList: XlsxSource, args: UxlOutputArgs): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let* answers    = generateFlocUxl(workList);
        let* _          = AssetLib/S4Lite/EmitUxl.outputUxl(args, answers);
        Ok()


    /// Generate all characteristics 
    pub def generateFlocUxl(workList: XlsxSource): Result[UxlSource, String] & Impure = 
        use Result.{flatMap};
        let* workitemRecs   = AssetLib/GenS4/WorkLists.readFlocWorkList(workList);
        let _               = Console.printLine("flocs: ${List.length(workitemRecs)}");
        let* flocs          = AssetLib/Gens4/Rules/FunctionalLocation.genFlocs(workitemRecs);
        let workitems       = AssetLib/GenS4/WorkLists.makeFlocWorkItems(workitemRecs);
        let c1              = AssetLib/Gens4/Rules/FunctionalLocation.flocCharacteristics1(workitems);
        let c2              = AssetLib/GenS4/Rules/Characteristics/AibReference.flocAibReference(workitems);
        let c3              = AssetLib/GenS4/Rules/Characteristics/EastNorth.flocEastNorth(workitems);
        let c4              = AssetLib/GenS4/Rules/Characteristics/SolutionId.flocSolutionId(workitems);
        let chars           = 
            (solve (c1 <+> c2 <+> c3 <+> c4) project FlocCharacteristic) |> AssetLib/GenS4/S4LiteRelations.toSLFlocCharacteristic;
        Ok( { funclocs = Chain.fromList(flocs)
            , funclocLongTexts = Chain.empty()
            , funclocCharacteristics = chars
            , equipment = Chain.empty()
            , equiLongTexts = Chain.empty()
            , equiCharacteristics = Chain.empty()
            })


}
