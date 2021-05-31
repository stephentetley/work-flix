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
    use AssetLib/AibFacts/Relations.{AibStringValue, AibFloatValue};
    use AssetLib/AibFacts/Attributes/Equipment.{EquipmentAttibutes};
    use AssetLib/GenS4/XlsxSource.{XlsxSource};
    use AssetLib/GenS4/WorkListRelations.{Phase1EquiItem};

    type alias Phase1Arguments = 
        { uxlTemplate: System.FilePath
        , aibHierarchyExport: XlsxSource
        , aibEquipmentExport: XlsxSource
        , aibMemosExport: XlsxSource
        , aibValveExport: Option[XlsxSource]
        , phase1Worklist: XlsxSource
        , changeRequestName: String
        , outpath: System.FilePath
        }


    /// Empty string for no solution id.
    pub def phase1(args: Phase1Arguments): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        use AssetLib/GenS4/Rules/Equipment.{genEquis, equiCharacteristics1};
        use AssetLib/GenS4/Rules/LongText.{uxlEquiLongText};
        let* workitems  = AssetLib/GenS4/WorkListRelations.readPhase1EquiWorkList(args.phase1Worklist.sheet, args.phase1Worklist.file);
        let* baseRelns  = loadRelations(args);
        let today       = Time/LocalDate.now();
        let answers     = solve uxlEquiLongText() <+> equiCharacteristics1() <+> genEquis(today) <+> baseRelns <+> workitems;
        /// let answers     = solve uxlEquiLongText() <+> baseRelns;
        /// (project EquiDatum answers) |> unsafeToString |> println;
        /// (project EquiCharacteristic answers) |> unsafeToString |> println;
        query answers select (x1, x2, x3) from AibStringValue(x1, x2, x3) |> Array.foreach(println);
        /// (project EquiLongText answers) |> unsafeToString |> println;
        /// let* _          = AssetLib/GenS4/EmitUxl.outputUxl(args.changeRequestName, answers, args.uxlTemplate, args.outpath);
        Ok()


    def loadRelations(args: Phase1Arguments): Result[#{Phase1EquiItem, AibRootNode, AibFloc, AibEquipment, 
                                                        EquipmentAttibutes, AibStringValue, 
                                                        AibFloatValue | r}, String] & Impure = 
        use Result.{flatMap};
        let* hrelns         = AssetLib/AibFacts/HierarchyFacts.readHierarchyRelations(args.aibHierarchyExport.sheet, args.aibHierarchyExport.file);
        let* equiAttrs      = AssetLib/AibFacts/Attributes/Equipment.readEquipmentData(args.aibEquipmentExport.sheet, args.aibEquipmentExport.file);
        let* memos          = AssetLib/AibFacts/Attributes/MemoLines.readMemoLinesData(args.aibMemosExport.sheet, args.aibMemosExport.file);
        let* valves         = match args.aibValveExport { 
            case Some(xlsx) => AssetLib/AibFacts/Attributes/Valve.readValveData(xlsx.sheet, xlsx.file)
            case None => Ok(#{})
        };
        
        Ok(hrelns <+> equiAttrs <+> memos <+> valves)


}
