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

namespace ValveReport/Main {

    use AssetLib/Translate/Aib/HierarchicalRelations.{RootNode, AibFloc, AibEquipment};
    use AssetLib/Translate/S4/Relations.{EquiDatum, EquiCharacteristic, EquiLongText};
    use AssetLib/Translate/Characteristics/AssetCondition.{ConditionGrade, ConditionGradeReason, 
        PerformanceGrade, PerformanceGradeReason, LoadingFactor, LoadingFactorReason, SurveyYear};
    use AssetLib/Translate/MemoLines.{MemoText};
    use ValveReport/Relations.{ValveWorkItem, ValveAttribs};

    type alias XlsxSource = 
        { file: System.FilePath
        , sheet: String
        }

    type alias SourceFiles = 
        { uxlTemplate: System.FilePath
        , aibHierarchyExport: XlsxSource
        , aibValveExport: XlsxSource
        , aibAgaspExport: XlsxSource
        , aibMemosExport: XlsxSource
        , worklist: XlsxSource
        }

    /// Empty string for no solution id.
    pub def main1(sourceFiles: SourceFiles, solutionId: String): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        use AssetLib/Translate/Characteristics/AssetCondition.{assetCondition};
        use AssetLib/Translate/MemoLines.{equiLongText};
        use ValveReport/Rules.{eqVALV, equiSolutionId, equiEastNorth, equiAibReference};
        let* baseRelns = ValveReport/Main.loadRelations(sourceFiles);
        let answers = solve equiSolutionId(solutionId) <+> equiLongText() <+>  assetCondition() <+> equiAibReference() <+> equiEastNorth() <+> eqVALV() <+> baseRelns;
        (project EquiDatum answers) |> unsafeToString |> println;
        (project EquiCharacteristic answers) |> unsafeToString |> println;
        (project EquiLongText answers) |> unsafeToString |> println;
        Ok()


    pub def loadRelations(src: SourceFiles): Result[#{ValveAttribs, ValveWorkItem, RootNode, AibFloc, AibEquipment, 
                                                        MemoText, 
                                                        ConditionGrade, ConditionGradeReason, 
                                                        PerformanceGrade, PerformanceGradeReason, 
                                                        LoadingFactor, LoadingFactorReason, SurveyYear | r}, String] & Impure = 
        use Result.{flatMap};
        let* hrelns         = AssetLib/Translate/Aib/HierarchicalRelations.readHierarchyRelations(src.aibHierarchyExport.sheet, src.aibHierarchyExport.file);
        let* valveAttribs   = ValveReport/Relations.readValveAttribsData(src.aibValveExport.sheet, src.aibValveExport.file);
        let* agasp          = AssetLib/Translate/Characteristics/AssetCondition.readAgaspData(src.aibAgaspExport.sheet, src.aibAgaspExport.file);
        let* memos          = AssetLib/Translate/MemoLines.readMemoData(src.aibMemosExport.sheet, src.aibMemosExport.file);
        let* workitems      = ValveReport/Relations.readWorkItemData(src.worklist.sheet, src.worklist.file);
        Ok(hrelns <+> valveAttribs <+> agasp <+> memos <+> workitems)

}
