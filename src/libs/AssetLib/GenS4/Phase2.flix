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


namespace AssetLib/GenS4/Phase2 {

    use AssetLib/AibFacts/HierarchyFacts.{AibRootNode, AibFloc, AibEquipment};
    use AssetLib/AibFacts/Relations.{AibStringValue, AibIntValue, AibFloatValue};
    use AssetLib/AibFacts/Attributes/Equipment.{EquipmentAttibutes};
    use AssetLib/GenS4/XlsxSource.{XlsxSource};
    use AssetLib/GenS4/WorkListRelations.{Phase1EquiSortOrder, Phase1EquiItem, Phase2EquiItem};
    

    type alias Phase2Arguments = 
        { userName: String 
        , aibHierarchyExport: XlsxSource
        , aibEquipmentExport: XlsxSource
        , aibValveExport: XlsxSource
        , solutionId: Option[String]
        , phase1Worklist: XlsxSource
        , phase2Worklist: System.FilePath       /// Tab is called Data
        , outnameRoot: String
        , outdir: System.FilePath
        }


    /// Empty string for no solution id.
    pub def phase2(args: Phase2Arguments): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        use AssetLib/GenS4/Rules/Characteristics/AssetCondition.{assetCondition};
        use AssetLib/GenS4/Rules/Characteristics/AibReference.{equiAibReference};
        use AssetLib/GenS4/Rules/Characteristics/EastNorth.{equiEastNorth};
        use AssetLib/GenS4/Rules/Characteristics/SolutionId.{equiSolutionId};
        let* baseRelns  = loadRelations(args);
        let solutionId  = Option.getWithDefault(args.solutionId, "");
        let answers     = solve assetCondition() <+> equiAibReference() <+> equiEastNorth() 
                                    <+> equiSolutionId(solutionId) <+>  baseRelns;
        let* _          = AssetLib/GenS4/EmitUpload.outputUploads(args.userName, answers, args.outnameRoot, args.outdir);
        Ok()


    def loadRelations(args: Phase2Arguments): Result[#{Phase1EquiSortOrder, Phase1EquiItem, Phase2EquiItem, 
                                                        AibRootNode, AibFloc, AibEquipment, 
                                                        AibStringValue, AibIntValue, AibFloatValue | r}, String] & Impure = 
        use Result.{flatMap};
        let* hrelns         = AssetLib/AibFacts/HierarchyFacts.readHierarchyRelations(args.aibHierarchyExport.sheet, args.aibHierarchyExport.file);
        let* locOnSite      = AssetLib/AibFacts/Attributes/Equipment.readLocationOnSiteData(args.aibEquipmentExport.sheet, args.aibEquipmentExport.file);
        let* valves         = AssetLib/AibFacts/Attributes/Valve.readValveData(args.aibValveExport.sheet, args.aibValveExport.file);
        let* workitems1     = AssetLib/GenS4/WorkListRelations.readPhase1EquiWorkList(args.phase1Worklist.sheet, args.phase1Worklist.file);
        let* workitems2     = AssetLib/GenS4/WorkListRelations.readPhase2EquiWorkList("Data", args.phase2Worklist);
        Ok(hrelns <+> locOnSite <+> valves <+> workitems1 <+> workitems2)


}
