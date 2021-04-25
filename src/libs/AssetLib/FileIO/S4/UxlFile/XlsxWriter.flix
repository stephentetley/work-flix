/*
 * Copyright 2020 Stephen Tetley
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
    

namespace AssetLib/FileIO/S4/UxlFile/XlsxWriter {

    use SheetIO.RowSetter;
    use SheetIO.SheetWriter;

    use AssetLib/FileIO/S4/UxlFile/Datatypes.{ChangeRequestDetails,
        FunctionalLocationData, FlMultilingualText, FlClassification, 
        EquipmentData, EqMultilingualText, EqClassification};


    /// Change Request Details

    /// Assumes an empty UXL workbook with sheets, headers etc. set up.
    pub def writeChangeRequestDetails(xs: List[ChangeRequestDetails]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, getSheetNamed, setCursor!, appendRow, mapX};
        let* s1     = getSheetNamed("Change Request Details");
        let* _      = setCursor!(s1, 6);
        mapX(x -> appendRow(s1, setChangeRequestDetails!(x)), xs)


    /// Just write fields of interest...
    def setChangeRequestDetails!(x: ChangeRequestDetails): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!, putInt32At!};
        let* _      = putStringAt!(0, x.description);
        let* _      = putStringAt!(4, x.changeRequestType);
        let* _      = putStringAt!(10, x.flFunctionalLocation);
        let* _      = putStringAt!(11, x.eqEquipment);
        let* _      = putStringAt!(12, x.processRequester);
        return()


    /// Functional Location Data

    /// Assumes an empty UXL workbook with sheets, headers etc. set up.
    pub def writeFunctionalLocationData(xs: List[FunctionalLocationData]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, getSheetNamed, setCursor!, appendRow, mapX};      
        let* s1     = getSheetNamed("Functional Location Data");
        let* _      = setCursor!(s1, 6);
        mapX(x -> appendRow(s1, setFunctionalLocationData!(x)), xs)


    /// Just write fields of interest...
    def setFunctionalLocationData!(x: FunctionalLocationData): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!, putInt32At!};
        use AssetLib/Base/S4/SheetIOUtils.{putS4BoolAt!, putS4DateAt!};
        let* _      = putStringAt!(0, x.functionalLocation);
        let* _      = putStringAt!(1, x.maskedFuncLoc);
        let* _      = putStringAt!(2, x.description);
        let* _      = putInt32At!(3, x.functLocCat);
        let* _      = putStringAt!(4, x.strIndicator);
        let* _      = putStringAt!(5, x.objectType);
        let* _      = putS4DateAt!(11, x.startupDate);
        let* _      = putInt32At!(22, x.maintPlant);
        let* _      = putInt32At!(29, x.companyCode);
        let* _      = putInt32At!(34, x.coArea);
        let* _      = putStringAt!(45, x.supFunctLoc);
        let* _      = putS4BoolAt!(46, x.equipInstall);     /// Do we need to write this?
        let* _      = putStringAt!(48, x.statusProfile);
        let* _      = putStringAt!(49, x.userStatus);
        return()


    /// FL-Multilingual Text

    /// Assumes an empty UXL workbook with sheets, headers etc. set up.
    pub def writeFlMultilingualText(xs: List[FlMultilingualText]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, getSheetNamed, setCursor!, appendRow, mapX};      
        let* s1     = getSheetNamed("FL-Multilingual Text");
        let* _      = setCursor!(s1, 6);
        mapX(x -> appendRow(s1, setFlMultilingualText!(x)), xs)

    def setFlMultilingualText!(x: FlMultilingualText): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!};
        use AssetLib/Base/S4/SheetIOUtils.{putS4BoolAt!};
        let* _      = putStringAt!(0, x.functionalLocation);
        let* _      = putS4BoolAt!(1, x.deleteIndicator);
        let* _      = putStringAt!(2, x.language);
        let* _      = putStringAt!(3, x.description);
        let* _      = putStringAt!(4, x.longText);
        return()


    /// FL-Classification

    /// Assumes an empty UXL workbook with sheets, headers etc. set up.
    pub def writeFlClassification(xs: List[FlClassification]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, getSheetNamed, setCursor!, appendRow, mapX};      
        let* s1     = getSheetNamed("FL-Classification");
        let* _      = setCursor!(s1, 6);
        mapX(x -> appendRow(s1, setFlClassification!(x)), xs)

    def setFlClassification!(x: FlClassification): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!};
        use AssetLib/Base/S4/SheetIOUtils.{putS4BoolAt!};
        let* _      = putStringAt!(0, x.functionalLocation);
        let* _      = putS4BoolAt!(1, x.deletionInd);
        let* _      = putStringAt!(2, x.classType);
        let* _      = putStringAt!(3, x.className);
        let* _      = putStringAt!(4, x.status);
        let* _      = putStringAt!(5, x.characteristicName);
        let* _      = putStringAt!(6, x.charValue);
        let* _      = putS4BoolAt!(7, x.charDeletionInd);
        return()


    /// Equipment Data

    /// Assumes an empty UXL workbook with sheets, headers etc. set up.
    pub def writeEquipmentData(xs: List[EquipmentData]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, getSheetNamed, setCursor!, appendRow, mapX};      
        let* s1     = getSheetNamed("Equipment Data");
        let* _      = setCursor!(s1, 6);
        mapX(x -> appendRow(s1, setEquipmentData!(x)), xs)


    /// Not all fields are written...
    def setEquipmentData!(x: EquipmentData): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!, putInt32At!, putOptionInt32At!, putOptionFloat64At!};
        use AssetLib/Base/S4/SheetIOUtils.{putS4DateAt!, putPaddedInt32At!};
        let* _      = putStringAt!(0, x.equiId);
        let* _      = putStringAt!(1, x.equipCategory);
        let* _      = putStringAt!(2, x.description);
        let* _      = putStringAt!(4, x.objectType);
        let* _      = putOptionFloat64At!(7, x.grossWeight);
        let* _      = putStringAt!(8, x.unitOfWeight);
        let* _      = putS4DateAt!(10, x.startupDate);
        let* _      = putStringAt!(14, x.manufacturer);
        let* _      = putStringAt!(15, x.modelNumber);
        let* _      = putStringAt!(16, x.manufPartNo);
        let* _      = putStringAt!(17, x.manufSerialNo);
        let* _      = putInt32At!(19, x.constructYear);
        let* _      = putPaddedInt32At!(20, 2, '0', x.constructMth);
        let* _      = putInt32At!(21, x.maintPlant);
        let* _      = putInt32At!(28, x.companyCode);           /// AC BukrEilo
        let* _      = putInt32At!(33, x.coArea);                /// AH 
        let* _      = putInt32At!(37, x.planningPlant);
        let* _      = putStringAt!(42, x.functionalLoc);
        let* _      = putStringAt!(43, x.superordEquip);
        let* _      = putOptionInt32At!(44, x.position);
        let* _      = putStringAt!(45, x.techIdentNo);
        let* _      = putStringAt!(50, x.statusProfile);
        let* _      = putStringAt!(51, x.statusOfAnObject);
        return()

    /// EQ-Multilingual Text

    /// Assumes an empty UXL workbook with sheets, headers etc. set up.
    pub def writeEqMultilingualText(xs: List[EqMultilingualText]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, getSheetNamed, setCursor!, appendRow, mapX};      
        let* s1     = getSheetNamed("EQ-Multilingual Text");
        let* _      = setCursor!(s1, 6);
        mapX(x -> appendRow(s1, setEqMultilingualText!(x)), xs)

    def setEqMultilingualText!(x: EqMultilingualText): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!};
        use AssetLib/Base/S4/SheetIOUtils.{putS4BoolAt!};
        let* _      = putStringAt!(0, x.equiId);
        let* _      = putS4BoolAt!(1, x.deleteIndicator);
        let* _      = putStringAt!(2, x.language);
        let* _      = putStringAt!(3, x.description);
        let* _      = putStringAt!(4, x.longText);
        return()


    /// EQ-Classification

    /// Assumes an empty UXL workbook with sheets, headers etc. set up.
    pub def writeEqClassification(xs: List[EqClassification]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, getSheetNamed, setCursor!, appendRow, mapX};      
        let* s1     = getSheetNamed("EQ-Classification");
        let* _      = setCursor!(s1, 6);
        mapX(x -> appendRow(s1, setEqClassification!(x)), xs)

    def setEqClassification!(x: EqClassification): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!};
        use AssetLib/Base/S4/SheetIOUtils.{putS4BoolAt!};
        let* _      = putStringAt!(0, x.equiId);
        let* _      = putS4BoolAt!(1, x.deleteInd);
        let* _      = putStringAt!(2, x.classType);
        let* _      = putStringAt!(3, x.className);
        let* _      = putStringAt!(4, x.status);
        let* _      = putStringAt!(5, x.characteristicName);
        let* _      = putStringAt!(6, x.charValue);
        let* _      = putS4BoolAt!(7, x.charDeleteInd);
        return()


}