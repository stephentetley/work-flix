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


namespace AssetLib/GenS4/GenUxl {

    use SheetIO/Reader.{XlsxSource};
    use AssetLib/S4Lite/Datatypes.{UxlSource, SLFunctionalLocation, SLFlocCharacteristic};
    use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
    use AssetLib/S4Lite/S4LiteRelations.{FlocCharacteristic};
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};
    

    type alias GenUxlSource = 
        { flocWorkList :: Option[XlsxSource]
        , equiWorkList :: Option[XlsxSource]
        , facts :: FactExports
        }

    type alias FactExports =         
        { aibEquipmentExport :: XlsxSource
        , aibMemosExport :: XlsxSource
        , aibAgaspExport :: XlsxSource
        }

    /// Must work with batching...
    pub def generateUxl(src: GenUxlSource, outputArgs: UxlOutputArgs): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        use AssetLib/GenS4/GenMonad.{execGenMonad, return};
        let* flocs  = match src.flocWorkList { 
            case Some(x1) => execGenMonad(genFlocUxl(x1))
            case None => execGenMonad(return())
        };
        let* equis  = match src.equiWorkList { 
            case Some(x1) => execGenMonad(genEquiUxl(src.facts, x1))
            case None => execGenMonad(return())
        };
        let* _      = AssetLib/S4Lite/EmitUxl.outputUxl(true, outputArgs, AssetLib/S4Lite/Datatypes.combineUxlSource(flocs, equis));
        Ok()

    pub def generateFlocUxl(workList: XlsxSource, outputArgs: UxlOutputArgs): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let* flocs  = AssetLib/GenS4/GenMonad.execGenMonad(genFlocUxl(workList));
        let* _      = AssetLib/S4Lite/EmitUxl.outputUxl(true, outputArgs, flocs);
        Ok()

    /// Generate all characteristics 
    pub def genFlocUxl(workList: XlsxSource): GenMonad[Unit] = 
        use  AssetLib/GenS4/GenMonad.{flatMap, return};
        let* workitems  = AssetLib/GenS4/WorkLists.readFlocWorkList(workList);
        let* _  = AssetLib/Gens4/Rules/FunctionalLocation.genFlocs(workitems);
        let* _  = AssetLib/Gens4/Rules/FunctionalLocation.genFlocCharacteristics(workitems);
        let* _  = AssetLib/GenS4/Rules/Characteristics/AibReference.genFlocAibReference(workitems);
        let* _  = AssetLib/GenS4/Rules/Characteristics/EastNorth.genFlocEastNorth(workitems);
        let* _  = AssetLib/GenS4/Rules/Characteristics/SolutionId.genFlocSolutionId(workitems);
        return()


    pub def generateEquiUxl(genEquiArgs: FactExports, workList: XlsxSource, outputArgs: UxlOutputArgs): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let* equis  = AssetLib/GenS4/GenMonad.execGenMonad(genEquiUxl(genEquiArgs, workList));
        let* _      = AssetLib/S4Lite/EmitUxl.outputUxl(true, outputArgs, equis);
        Ok()

    /// Empty string for no solution id.
    pub def genEquiUxl(args: FactExports, workList: XlsxSource): GenMonad[Unit] = 
        use AssetLib/GenS4/GenMonad.{flatMap, return, liftAction};
        let* workitems  = AssetLib/GenS4/WorkLists.readEquiWorkList(workList);
        let* _          = liftAction(_ -> Console.printLine("workitems count: ${List.length(workitems)}"));
        let* equiAttrs  = AssetLib/GenS4/AibFacts/Attributes/Equipment.readEquipmentData(args.aibEquipmentExport);
        let* _          = AssetLib/GenS4/Rules/Equipment.genEquis(equiAttrs, workitems);
        let* _          = AssetLib/GenS4/Rules/LongText.genEquiLongText(workitems, args.aibMemosExport, args.aibEquipmentExport);
        let* _          = AssetLib/GenS4/Rules/Equipment.genCommonCharacteristics(workitems, args.aibEquipmentExport);
        let* _          = AssetLib/GenS4/Rules/Characteristics/AibReference.genEquiAibReference(workitems, args.aibEquipmentExport);
        let* _          = AssetLib/GenS4/Rules/Characteristics/SolutionId.genEquiSolutionId(workitems);
        let* _          = AssetLib/GenS4/Rules/Characteristics/EastNorth.genEquiEastNorth(workitems, args.aibEquipmentExport);
        let* _          = AssetLib/GenS4/Rules/Characteristics/AssetCondition.genAssetCondition(workitems, args.aibAgaspExport);
        return()

}
