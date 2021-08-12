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
    use AssetLib/GenS4/S4LiteRelations.{FlocCharacteristic};



    pub def emitFlocUxl(workList: XlsxSource, args: UxlOutputArgs): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let* answers    = generateFlocUxl(workList);
        let* _          = AssetLib/S4Lite/EmitUxl.outputUxl(true, args, answers);
        Ok()


    /// Generate all characteristics 
    pub def generateFlocUxl(workList: XlsxSource): Result[UxlSource, String] & Impure = 
        use Result.{flatMap};
        let* workitems  = AssetLib/GenS4/WorkLists.readFlocWorkList(workList);
        let _           = Console.printLine("flocs: ${List.length(workitems)}");
        let* flocs      = AssetLib/Gens4/Rules/FunctionalLocation.genFlocs(workitems);
        let* ch1        = AssetLib/Gens4/Rules/FunctionalLocation.genFlocCharacteristics1(workitems);
        let* ch2        = AssetLib/GenS4/Rules/Characteristics/AibReference.genFlocAibReference(workitems);
        let* ch3        = AssetLib/GenS4/Rules/Characteristics/EastNorth.genFlocEastNorth(workitems);
        let* ch4        = AssetLib/GenS4/Rules/Characteristics/SolutionId.genFlocSolutionId(workitems);
        Ok( { funclocs = Chain.fromList(flocs)
            , funclocLongTexts = Chain.empty()
            , funclocCharacteristics = Monoid.combineAll(ch1 :: ch2 :: ch3 :: ch4 :: Nil)
            , equipment = Chain.empty()
            , equiLongTexts = Chain.empty()
            , equiCharacteristics = Chain.empty()
            })


}
