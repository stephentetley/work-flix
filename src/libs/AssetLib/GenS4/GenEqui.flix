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


namespace AssetLib/GenS4/GenEqui {

    use SheetIO/Reader.{XlsxSource};


    use AssetLib/GenS4.{GenMonad};
    use AssetLib/S4Lite/Datatypes.{UxlSource};
    use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};


    type alias GenEquiArguments = 
        { workList: XlsxSource
        , aibEquipmentExport: XlsxSource
        , aibMemosExport: XlsxSource
        , aibGridRefsExport: XlsxSource
        , aibAgaspExport: XlsxSource
        }

    pub def emitEquiUxl(genArgs: GenEquiArguments, outputArgs: UxlOutputArgs): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let* equis  = AssetLib/GenS4/GenMonad.execGenMonad(generateEquiUxl(genArgs));
        let* _      = AssetLib/S4Lite/EmitUxl.outputUxl(true, outputArgs, equis);
        Ok()

    /// Empty string for no solution id.
    pub def generateEquiUxl(args: GenEquiArguments): GenMonad[Unit] = 
        use AssetLib/GenS4/GenMonad.{flatMap, return, liftAction};
        let* workitems  = AssetLib/GenS4/WorkLists.readEquiWorkList(args.workList);
        let* _          = liftAction(_ -> Console.printLine("workitems count: ${List.length(workitems)}"));
        let* equiAttrs  = AssetLib/GenS4/AibFacts/Attributes/Equipment.readEquipmentData(args.aibEquipmentExport);
        let* _          = AssetLib/GenS4/Rules/Equipment.genEquis(equiAttrs, workitems);
        let* _          = AssetLib/GenS4/Rules/LongText.genEquiLongText(workitems, args.aibMemosExport, args.aibEquipmentExport);
        let* _          = AssetLib/GenS4/Rules/Equipment.genCommonCharacteristics(workitems, args.aibEquipmentExport);
        let* _          = AssetLib/GenS4/Rules/Characteristics/AibReference.genEquiAibReference(workitems, args.aibEquipmentExport);
        let* _          = AssetLib/GenS4/Rules/Characteristics/SolutionId.genEquiSolutionId(workitems);
        let* _          = AssetLib/GenS4/Rules/Characteristics/EastNorth.genEquiEastNorth(workitems, args.aibGridRefsExport);
        let* _          = AssetLib/GenS4/Rules/Characteristics/AssetCondition.genAssetCondition(workitems, args.aibAgaspExport);
        return()


}
