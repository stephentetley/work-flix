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
    

    type alias Phase2Arguments = 
        { userName: String 
        , aibHierarchyExport: XlsxSource
        , aibEquipmentExport: XlsxSource
        , aibAgaspExport: XlsxSource
        , aibElectricalExport: XlsxSource
        , aibPumpExport: XlsxSource
        , aibRangeSignalExport: XlsxSource
        , aibTankExport: XlsxSource
        , aibValveExport: XlsxSource
        , phase1Worklist: XlsxSource
        , phase2Worklist: System.FilePath       /// Tab is called Data
        , outNameRoot: String
        , outdir: System.FilePath
        }


    /// Empty string for no solution id.
    pub def phase2(_args: Phase2Arguments): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        /// use AssetLib/GenS4/Rules/Characteristics/AssetCondition.{assetCondition};
        /// use AssetLib/GenS4/Rules/Characteristics/AibReference.{equiAibReference};
        /// use AssetLib/GenS4/Rules/Characteristics/EastNorth.{equiEastNorth};
        /// use AssetLib/GenS4/Rules/Equipment.{equipmentPhase2Characteristics};
        /// use AssetLib/GenS4/Rules/Characteristics/SolutionId.{equiSolutionId};
        /// let* baseRelns  = loadRelations(args);
        /// let answers     = 
        ///     solve assetCondition() 
        ///         <+> equiAibReference() 
        ///         <+> equiEastNorth() 
        ///         <+> equiSolutionId() 
        ///         <+> equipmentPhase2Characteristics()
        ///         <+> AssetLib/GenS4/Rules/Characteristics/Actu.actu()
        ///         <+> AssetLib/GenS4/Rules/Characteristics/Conp.conp()
        ///         <+> AssetLib/GenS4/Rules/Characteristics/Emtr.emtr()
        ///         <+> AssetLib/GenS4/Rules/Characteristics/Fstn.fstn()
        ///         <+> AssetLib/GenS4/Rules/Characteristics/Lstn.lstn()
        ///         <+> AssetLib/GenS4/Rules/Characteristics/Pump.pump()
        ///         <+> AssetLib/GenS4/Rules/Characteristics/Star.star()
        ///         <+> AssetLib/GenS4/Rules/Characteristics/Tank.tank()
        ///         <+> AssetLib/GenS4/Rules/Characteristics/Valv.valv()
        ///         <+> baseRelns;
        /// (project AibStringValue answers) |> unsafeToString |> println;
        /// let* _          = AssetLib/GenS4/EmitUpload.outputUploads(args.userName, answers, args.outNameRoot, args.outdir);
        Ok()


    /// def loadRelations(args: Phase2Arguments): Result[#{EquiworkItem, AibRootNode, AibFloc, AibEquipment, 
    ///                                                     AibStringValue, AibIntValue, AibFloatValue | r}, String] & Impure = 
    ///     use Result.{flatMap};
    ///     let* hrelns         = AssetLib/AibFacts/HierarchyFacts.readHierarchyRelations(args.aibHierarchyExport.sheet, args.aibHierarchyExport.file);
    ///     let* locOnSite      = AssetLib/AibFacts/Attributes/Equipment.readLocationOnSiteData(args.aibEquipmentExport.sheet, args.aibEquipmentExport.file);
    ///     let* agasp          = AssetLib/AibFacts/Attributes/AssetCondition.readAgaspData(args.aibAgaspExport.sheet, args.aibAgaspExport.file);
    ///     let* electrical     = AssetLib/AibFacts/Attributes/Electrical.readElectricalData(args.aibElectricalExport.sheet, args.aibElectricalExport.file);
    ///     let* pumps          = AssetLib/AibFacts/Attributes/Pump.readPumpData(args.aibPumpExport.sheet, args.aibPumpExport.file);
    ///     let* rangeSignal    = AssetLib/AibFacts/Attributes/Instrument.readInstrumentData(args.aibRangeSignalExport.sheet, args.aibRangeSignalExport.file);
    ///     let* tanks          = AssetLib/AibFacts/Attributes/Valve.readValveData(args.aibTankExport.sheet, args.aibTankExport.file);
    ///     let* valves         = AssetLib/AibFacts/Attributes/Valve.readValveData(args.aibValveExport.sheet, args.aibValveExport.file);
    ///     let* workitems1     = AssetLib/GenS4/WorkListRelations.readPhase1EquiWorkList(args.phase1Worklist.sheet, args.phase1Worklist.file);
    ///     let* workitems2     = AssetLib/GenS4/WorkListRelations.readPhase2EquiWorkList("Data", args.phase2Worklist);
    ///     Ok(hrelns <+> locOnSite <+> agasp <+> electrical <+> pumps <+> rangeSignal <+> tanks <+> valves <+> workitems1 <+> workitems2)


}
