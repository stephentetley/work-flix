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


namespace AssetLib/GenS4/Phase1 {

    use AssetLib/AibFacts/HierarchyFacts.{AibRootNode, AibFloc, AibEquipment};
    use AssetLib/AibFacts/Relations.{AibStringValue};
    use AssetLib/GenS4/XlsxSource.{XlsxSource};
    use AssetLib/GenS4/WorkListRelations.{Phase1EquiSortOrder, Phase1EquiItem};


    type alias Phase1Arguments = 
        { uxlTemplate: System.FilePath
        , aibHierarchyExport: XlsxSource
        , aibMemosExport: XlsxSource
        , phase1Worklist: XlsxSource
        , solutionId: String
        , changeRequestName: String
        , outpath: System.FilePath
        }


    /// Empty string for no solution id.
    pub def phase1(args: Phase1Arguments): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        use ValveReport/Rules/Equipment.{equipment};
        let* baseRelns  = loadRelations(args);
        let today       = Time/LocalDate.now();
        let answers     = solve equipment(today) <+> baseRelns;
        (project EquiDatum answers) |> unsafeToString |> println;
        (project EquiCharacteristic answers) |> unsafeToString |> println;
        (project EquiLongText answers) |> unsafeToString |> println;
        let* _          = AssetLib/GenS4/EmitUxl.outputUxl(args.changeRequestName, answers, args.uxlTemplate, args.outpath);
        Ok()


    def loadRelations(args: Phase1Arguments): Result[#{Phase1EquiItem, Phase1EquiSortOrder, AibRootNode, AibFloc, AibEquipment, 
                                                        AibStringValue | r}, String] & Impure = 
        use Result.{flatMap};
        let* hrelns         = AssetLib/AibFacts/HierarchyFacts.readHierarchyRelations(args.aibHierarchyExport.sheet, args.aibHierarchyExport.file);
        let* memos          = AssetLib/AibFacts/Attributes/MemoLines.readMemoLinesData(args.aibMemosExport.sheet, args.aibMemosExport.file);
        let* workitems      = AssetLib/GenS4/WorkListRelations.readPhase1EquiWorkList(args.phase1Worklist.sheet, args.phase1Worklist.file);
        /// TODO location on site
        Ok(hrelns <+> memos <+> workitems)


}
