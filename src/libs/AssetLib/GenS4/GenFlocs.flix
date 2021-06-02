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

    use AssetLib/S4Lite/Datatypes.{UxlSource};
    use AssetLib/GenS4/XlsxSource.{XlsxSource};
    use AssetLib/GenS4/WorkListRelations.{FlocWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{FunctionalLocation, FlocCharacteristic};

    type alias GenFlocsArguments = 
        { uxlTemplate: System.FilePath
        , flocWorkList: XlsxSource
        , changeRequestName: String
        , outpath: System.FilePath
        }


    pub def emitFlocUxl(args: GenFlocsArguments): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let* answers    = generateFlocUxl(args.flocWorkList);
        let* _          = AssetLib/S4Lite/EmitUxl.outputUxl(args.changeRequestName, answers, args.uxlTemplate, args.outpath);
        Ok()


    pub def generateFlocUxl(workList: XlsxSource): Result[UxlSource, String] & Impure = 
        use Result.{flatMap};
        let* workitems      = AssetLib/GenS4/WorkListRelations.readFlocWorkList(workList.sheet, workList.file);
        let flocs           = AssetLib/Gens4/FlocGen/Rules.genFlocs(workitems);
        let c1              = AssetLib/Gens4/FlocGen/Rules.flocCharacteristics1(workitems);
        let c2              = AssetLib/GenS4/Rules/Characteristics/EastNorth.flocEastNorth(workitems);
        let c3              = AssetLib/GenS4/Rules/Characteristics/SolutionId.flocSolutionId(workitems);
        let c4              = AssetLib/GenS4/Rules/Characteristics/AibReference.flocAibReference(workitems);
        let answers         = genS4Lite(flocs <+> c1 <+> c2 <+> c3 <+> c4);
        Ok(answers)


    def genS4Lite(relns: #{FunctionalLocation, FlocCharacteristic | r}): UxlSource & Impure = 
        { funclocs = AssetLib/GenS4/S4LiteRelations.toS4LiteFunctionalLocation(relns)
        , funclocLongTexts = Nil
        , funclocCharacteristics = AssetLib/GenS4/S4LiteRelations.toS4LiteFlocCharacteristic(relns)
        , equipment = Nil
        , equiLongTexts = Nil
        , equiCharacteristics = Nil
        }


}
