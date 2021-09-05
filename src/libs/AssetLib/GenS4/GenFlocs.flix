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
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/S4Lite/Datatypes.{UxlSource, SLFunctionalLocation, SLFlocCharacteristic};
    use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
    use AssetLib/S4Lite/S4LiteRelations.{FlocCharacteristic};
    


    pub def emitFlocUxl(workList: XlsxSource, args: UxlOutputArgs): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let* answers    = AssetLib/GenS4/GenMonad.execGenMonad(generateFlocUxl(workList));
        let* _          = AssetLib/S4Lite/EmitUxl.outputUxl(true, args, answers);
        Ok()

    /// Generate all characteristics 
    pub def generateFlocUxl(workList: XlsxSource): GenMonad[Unit] = 
        use  AssetLib/GenS4/GenMonad.{flatMap, return};
        let* workitems  = AssetLib/GenS4/WorkLists.readFlocWorkList(workList);
        let* _  = AssetLib/Gens4/Rules/FunctionalLocation.genFlocs(workitems);
        let* _  = AssetLib/Gens4/Rules/FunctionalLocation.genFlocCharacteristics(workitems);
        let* _  = AssetLib/GenS4/Rules/Characteristics/AibReference.genFlocAibReference(workitems);
        let* _  = AssetLib/GenS4/Rules/Characteristics/EastNorth.genFlocEastNorth(workitems);
        let* _  = AssetLib/GenS4/Rules/Characteristics/SolutionId.genFlocSolutionId(workitems);
        return()


}
