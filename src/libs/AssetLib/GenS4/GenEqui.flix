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

    use AssetLib/AibFacts/HierarchyFacts.{AibRootNode, AibFloc, AibEquipment};
    use AssetLib/AibFacts/Attributes/MemoLines.{AibMemoLine};
    use AssetLib/AibFacts/Attributes/Equipment.{LocationOnSite, EquipmentAttibutes};
    use AssetLib/S4Lite/Datatypes.{UxlSource};
    use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};
    use AssetLib/GenS4/XlsxSource.{XlsxSource};
    use AssetLib/GenS4/WorkListRelations.{EquiWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{Equipment, EquiLongText, EquiCharacteristic};


    /// TODO - need to be able to generate EquiCharacteristics from a Worklist and an XlsxSource
    /// and aggregate them 
    type alias GenEquiArguments = 
        { uxlArgs: UxlOutputArgs
        , worklist: XlsxSource
        , aibHierarchyExport: XlsxSource
        , aibEquipmentExport: XlsxSource
        , aibMemosExport: XlsxSource
        }

    pub def emitEquiUxl(args: GenEquiArguments): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let* answers    = generateEquiUxl(args);
        let* _          = AssetLib/S4Lite/EmitUxl.outputUxl(answers, args.uxlArgs);
        Ok()

    /// Empty string for no solution id.
    pub def generateEquiUxl(args: GenEquiArguments): Result[UxlSource, String] & Impure = 
        use Result.{flatMap};
        let* workitems  = AssetLib/GenS4/WorkListRelations.readEquiWorkList(args.worklist.sheet, args.worklist.file);
        let* baseRelns  = loadBaseRelations(args);
        let today       = Time/LocalDate.now();
        let input       = baseRelns <+> workitems;
        let equis       = AssetLib/GenS4/Rules/Equipment.genEquis(today, input);
        let longText    = AssetLib/GenS4/Rules/LongText.genEquiLongText(input);
        let c1          = AssetLib/GenS4/Rules/Equipment.equiCharacteristics1(input);
        let answers     = genS4Lite(equis <+> longText <+> c1);
        Ok(answers)

        /// TODO these need accommodating somehow... (plugins?)
        /// let* c2         = AssetLib/GenS4/Rules/Characteristics/AssetCondition.genAssetCondition(workitems, args.aibAgaspExport);
        /// let* c3         = AssetLib/GenS4/Rules/Characteristics/Actu.genActu(workitems, args.aibElectricalExport);
        /// let* c4         = AssetLib/GenS4/Rules/Characteristics/Conp.genConp(workitems, args.aibElectricalExport);
        /// let* c5         = AssetLib/GenS4/Rules/Characteristics/Emtr.genEmtr(workitems, args.aibElectricalExport);
        /// let* c6         = AssetLib/GenS4/Rules/Characteristics/Star.genStar(workitems, args.aibElectricalExport);

    def loadBaseRelations(args: GenEquiArguments): Result[#{AibRootNode, AibFloc, AibEquipment, 
                                                            EquipmentAttibutes, AibMemoLine, 
                                                            LocationOnSite | r}, String] & Impure = 
        use Result.{flatMap};
        let* hrelns     = AssetLib/AibFacts/HierarchyFacts.readHierarchyRelations(args.aibHierarchyExport.sheet, args.aibHierarchyExport.file);
        let* equiAttrs  = AssetLib/AibFacts/Attributes/Equipment.readEquipmentData(args.aibEquipmentExport.sheet, args.aibEquipmentExport.file);
        let* memos      = AssetLib/AibFacts/Attributes/MemoLines.readMemoLinesData(args.aibMemosExport.sheet, args.aibMemosExport.file);     
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
