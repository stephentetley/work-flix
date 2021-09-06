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


    use AssetLib/S4Lite/Datatypes.{UxlSource};
    use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};

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

    /// Phase 2

    type alias Phase2GenEquiArguments = 
        { workList: XlsxSource
        , s4ChangeRequestEquiTab: System.FilePath       /// Sheet always called Data
        , aibElectricalExport: XlsxSource
        }

    type alias FileUploadOutputArgs = 
        { outputDirectory: System.FilePath
        , userName: String
        , filePrefix: String
        }    

    pub def emitPhase2EquiUxl(genArgs: Phase2GenEquiArguments, outputArgs: FileUploadOutputArgs): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let* (uxl, workitems) = AssetLib/GenS4/GenMonad.runGenMonad(generatePhase2Equi(genArgs));
        let chars       = uxl.equiCharacteristics;
        let renamings   = AssetLib/GenS4/WorkLists.getEquipmentWorkItemKeyMap(workitems);
        let* cs1        = AssetLib/S4Lite/EmitUpload.renumberSLEquiCharacteristics(renamings, {path = genArgs.s4ChangeRequestEquiTab, sheet = "Data"}, chars);
        let filter      = AssetLib/S4Lite/EmitUpload.allClassFilter();
        let* _          = AssetLib/S4Lite/EmitUpload.outputEquiUploads(outputArgs.userName, cs1, outputArgs.filePrefix, filter, outputArgs.outputDirectory);
        Ok()


    pub def generatePhase2Equi(args: Phase2GenEquiArguments): GenMonad[List[EquiWorkItem]] = 
        use AssetLib/GenS4/GenMonad.{flatMap, return, liftAction};
        let* workitems  = AssetLib/GenS4/WorkLists.readEquiWorkList(args.workList);
        let* _          = AssetLib/GenS4/Rules/Characteristics/Actu.genActu(workitems, args.aibElectricalExport);
        return(workitems)

}
