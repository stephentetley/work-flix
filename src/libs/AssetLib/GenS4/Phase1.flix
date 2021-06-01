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
    use AssetLib/AibFacts/Attributes/MemoLines.{AibMemoLine};
    use AssetLib/AibFacts/Attributes/Equipment.{LocationOnSite, EquipmentAttibutes};
    use AssetLib/S4Lite/EmitUxl.{UxlSource};
    use AssetLib/GenS4/XlsxSource.{XlsxSource};
    use AssetLib/GenS4/WorkListRelations.{EquiWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{Equipment, EquiLongText, EquiCharacteristic};

    type alias Phase1Arguments = 
        { uxlTemplate: System.FilePath
        , aibHierarchyExport: XlsxSource
        , aibEquipmentExport: XlsxSource
        , aibMemosExport: XlsxSource
        , aibValveExport: Option[XlsxSource]
        , aibAgaspExport: Option[XlsxSource]
        , aibElectricalExport: Option[XlsxSource]
        , worklist: XlsxSource
        , changeRequestName: String
        , outpath: System.FilePath
        }


    /// Empty string for no solution id.
    pub def genEqui(args: Phase1Arguments): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let* workitems  = AssetLib/GenS4/WorkListRelations.readEquiWorkList(args.worklist.sheet, args.worklist.file);
        let* baseRelns  = loadBaseRelations(args);
        let today       = Time/LocalDate.now();
        let input       = baseRelns <+> workitems;
        let equis       = AssetLib/GenS4/Rules/Equipment.genEquis(today, input);
        let longText    = AssetLib/GenS4/Rules/LongText.genEquiLongText(input);
        let c1          = AssetLib/GenS4/Rules/Equipment.equiCharacteristics1(input);
        let* c2         = AssetLib/GenS4/Rules/Characteristics/AssetCondition.genAssetCondition(workitems, args.aibAgaspExport);
        let* c3         = AssetLib/GenS4/Rules/Characteristics/Actu.genActu(workitems, args.aibElectricalExport);
        let* c4         = AssetLib/GenS4/Rules/Characteristics/Conp.genConp(workitems, args.aibElectricalExport);
        let* c5         = AssetLib/GenS4/Rules/Characteristics/Emtr.genEmtr(workitems, args.aibElectricalExport);
        let* c6         = AssetLib/GenS4/Rules/Characteristics/Star.genStar(workitems, args.aibElectricalExport);
        query equis select (x1, x2, x3) from Equipment(x1, x2, x3, _, _, _, _, _, _, _, _, _, _, _, _, _) 
            |> Array.length 
            |>  x -> Console.printLine("Generating ${x} equis");
        query c3 select (x1, x2, x3, x4, x5) from EquiCharacteristic(x1, x2, x3, x4, x5) |> Array.foreach(println);
        let answers     = genS4Lite(equis <+> longText <+> c1 <+> c2 <+> c3 <+> c4 <+> c5 <+> c6);
        let* _          = AssetLib/S4Lite/EmitUxl.outputUxl(args.changeRequestName, answers, args.uxlTemplate, args.outpath);
        Ok()


    def loadBaseRelations(args: Phase1Arguments): Result[#{AibRootNode, AibFloc, AibEquipment, 
                                                            EquipmentAttibutes, AibMemoLine, 
                                                            LocationOnSite | r}, String] & Impure = 
        use Result.{flatMap};
        let* hrelns         = AssetLib/AibFacts/HierarchyFacts.readHierarchyRelations(args.aibHierarchyExport.sheet, args.aibHierarchyExport.file);
        let* equiAttrs      = AssetLib/AibFacts/Attributes/Equipment.readEquipmentData(args.aibEquipmentExport.sheet, args.aibEquipmentExport.file);
        let* memos          = AssetLib/AibFacts/Attributes/MemoLines.readMemoLinesData(args.aibMemosExport.sheet, args.aibMemosExport.file);     
        Ok(hrelns <+> equiAttrs <+> memos)

    def genS4Lite(relns: #{Equipment, EquiLongText, EquiCharacteristic | r}): UxlSource & Impure = 
        { funclocs = Nil
        , funclocLongTexts = Nil
        , funclocCharacteristics = Nil
        , equipment = AssetLib/GenS4/S4LiteRelations.toS4LiteEquipment(relns)
        , equiLongTexts = AssetLib/GenS4/S4LiteRelations.toS4LiteEquiLongText(relns)
        , equiCharacteristics = AssetLib/GenS4/S4LiteRelations.toS4LiteEquiCharacteristic(relns)
        }

}
