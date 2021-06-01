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
    use AssetLib/S4Lite/EmitUxl.{UxlSource};
    use AssetLib/GenS4/XlsxSource.{XlsxSource};
    use AssetLib/GenS4/WorkListRelations.{Phase1EquiItem};
    use AssetLib/GenS4/S4LiteRelations.{Equipment, EquiCharacteristic};

    type alias Phase1Arguments = 
        { uxlTemplate: System.FilePath
        , aibHierarchyExport: XlsxSource
        , aibEquipmentExport: XlsxSource
        , aibMemosExport: XlsxSource
        , aibValveExport: Option[XlsxSource]
        , worklist: XlsxSource
        , changeRequestName: String
        , outpath: System.FilePath
        }


    /// Empty string for no solution id.
    pub def phase1(args: Phase1Arguments): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        use AssetLib/GenS4/Rules/Equipment.{genEquis, equiCharacteristics1};
        use AssetLib/GenS4/Rules/LongText.{uxlEquiLongText};
        let* workitems  = AssetLib/GenS4/WorkListRelations.readEquiWorkList(args.worklist.sheet, args.worklist.file);
        let* baseRelns  = loadRelations(args);
        let today       = Time/LocalDate.now();
        let input       = baseRelns <+> workitems;
        let equis       = genEquis(today, input);
        let c1          = equiCharacteristics1(input);
        query equis select (x1, x2, x3) from Equipment(x1, x2, x3, _, _, _, _, _, _, _, _, _, _, _, _, _) |> Array.foreach(println);
        query c1 select (x1, x2, x3, x4, x5) from EquiCharacteristic(x1, x2, x3, x4, x5) |> Array.foreach(println);
        let answers     = genS4Lite(equis <+> c1);
        let* _          = AssetLib/S4Lite/EmitUxl.outputUxl(args.changeRequestName, answers, args.uxlTemplate, args.outpath);
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

    def genS4Lite(relns: #{Equipment, EquiCharacteristic | r}): UxlSource & Impure = 
        { funclocs = Nil
        , funclocLongTexts = Nil
        , funclocCharacteristics = Nil
        , equipment = AssetLib/GenS4/S4LiteRelations.toS4LiteEquipment(relns)
        , equiLongTexts = Nil
        , equiCharacteristics = AssetLib/GenS4/S4LiteRelations.toS4LiteEquiCharacteristic(relns)
        }

}
