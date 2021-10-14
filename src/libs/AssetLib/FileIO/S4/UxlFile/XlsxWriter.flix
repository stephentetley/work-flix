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
    pub def writeChangeRequestDetailsMocr(xs: List[ChangeRequestDetails]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, getSheetNamed, setCursor!, appendRow, mapX};
        let* s1     = getSheetNamed("Change Request Details");
        let* _      = setCursor!(s1, 6);
        mapX(x -> appendRow(s1, setChangeRequestDetailsMocr!(x)), xs)


    /// Just write fields of interest...
    def setChangeRequestDetailsMocr!(x: ChangeRequestDetails): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!, putInt32At!};
        let* _      = putStringAt!(0, x.description);
        let* _      = putStringAt!(4, x.changeRequestType);
        let* _      = putStringAt!(10, x.flFunctionalLocation);
        let* _      = putStringAt!(11, x.eqEquipment);
        let* _      = putStringAt!(12, x.processRequester);
        return()

    /// Assumes an empty UXL workbook with sheets, headers etc. set up.
    pub def writeChangeRequestDetailsMem(xs: List[ChangeRequestDetails]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, getSheetNamed, setCursor!, appendRow, mapX};
        let* s1     = getSheetNamed("Change Request Details");
        let* _      = setCursor!(s1, 6);
        mapX(x -> appendRow(s1, setChangeRequestDetailsMem!(x)), xs)


    /// Just write fields of interest...
    def setChangeRequestDetailsMem!(x: ChangeRequestDetails): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!, putInt32At!};
        let* _      = putStringAt!(0, x.eqEquipment);
        let* _      = putStringAt!(1, x.description);
        let* _      = putStringAt!(5, x.changeRequestType);
        let* _      = putStringAt!(7, x.processRequester);
        return()


    /// Functional Location Data

    /// Assumes an empty UXL workbook with sheets, headers etc. set up.
    pub def writeFunctionalLocationDataMocr(xs: List[FunctionalLocationData]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, getSheetNamed, setCursor!, appendRow, mapX};      
        let* s1     = getSheetNamed("Functional Location Data");
        let* _      = setCursor!(s1, 6);
        mapX(x -> appendRow(s1, setFunctionalLocationDataMocr!(x)), xs)


    /// Just write fields of interest... (1909)
    def setFunctionalLocationDataMocr!(x: FunctionalLocationData): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!, putInt32At!};
        use AssetLib/Base/S4/SheetIOUtils.{putS4BoolAt!, putS4DateAt!};
        let* _      = putStringAt!(0, x.functionalLocation);
        let* _      = putStringAt!(1, x.maskedFuncLoc);
        let* _      = putStringAt!(2, x.description);
        let* _      = putInt32At!(3, x.functLocCat);
        let* _      = putStringAt!(4, x.strIndicator);
        let* _      = putStringAt!(5, x.objectType);
        let* _      = putS4DateAt!(8, x.startupDate);
        let* _      = putInt32At!(11, x.constructYear);
        let* _      = putStringAt!(12, String.padLeft(2, '0', "${x.constructMth}"));
        let* _      = putInt32At!(13, x.maintPlant);
        let* _      = putInt32At!(14, x.companyCode);
        let* _      = putInt32At!(15, x.coArea);
        let* _      = putInt32At!(16, x.planningPlant);
        let* _      = putStringAt!(17, position4(x.position));
        let* _      = putStringAt!(18, x.supFunctLoc);
        let* _      = putS4BoolAt!(19, x.equipInstall);     /// Do we need to write this?
        let* _      = putStringAt!(20, x.statusOfObject);
        return()


    def position4(x: Option[Int32]): String = match x { 
        case Some(i) => String.padLeft(4, '0', ToString.toString(i))
        case None => ""
    }

    /// FL-Multilingual Text

    /// Assumes an empty UXL workbook with sheets, headers etc. set up.
    pub def writeFlMultilingualTextMocr(xs: List[FlMultilingualText]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, getSheetNamed, setCursor!, appendRow, mapX};      
        let* s1     = getSheetNamed("FL-Multilingual Text");
        let* _      = setCursor!(s1, 6);
        mapX(x -> appendRow(s1, setFlMultilingualTextMocr!(x)), xs)

    /// (1909)
    def setFlMultilingualTextMocr!(x: FlMultilingualText): RowSetter[Unit] = 
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
    pub def writeFlClassificationMocr(xs: List[FlClassification]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, getSheetNamed, setCursor!, appendRow, mapX};      
        let* s1     = getSheetNamed("FL-Classification");
        let* _      = setCursor!(s1, 6);
        mapX(x -> appendRow(s1, setFlClassificationMocr!(x)), xs)

    /// (1909)
    def setFlClassificationMocr!(x: FlClassification): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!};
        use AssetLib/Base/S4/SheetIOUtils.{putS4BoolAt!};
        let* _      = putStringAt!(0, x.functionalLocation);
        let* _      = putS4BoolAt!(1, x.deletionInd);
        let* _      = putStringAt!(2, x.classType);
        let* _      = putStringAt!(3, x.className);
        let* _      = putStringAt!(4, x.characteristicName);
        let* _      = putStringAt!(5, x.charValue);
        let* _      = putS4BoolAt!(6, x.charDeletionInd);
        return()


    /// Equipment Data

    /// Writes to a template (i.e an empty UXL workbook with sheets, headers etc. set up).
    pub def writeEquipmentDataMocr(xs: List[EquipmentData]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, getSheetNamed, setCursor!, appendRow, mapX};      
        let* s1     = getSheetNamed("Equipment Data");
        let* _      = setCursor!(s1, 6);
        mapX(x -> appendRow(s1, setEquipmentDataMocr!(x)), xs)


    /// Not all fields are written... (1909)
    def setEquipmentDataMocr!(x: EquipmentData): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!, putInt32At!, putOptionInt32At!, putOptionFloat64At!};
        use AssetLib/Base/S4/SheetIOUtils.{putS4DateAt!};
        let* _      = putInt32At!(0, x.plantWorkCenter);
        let* _      = putStringAt!(1, x.equiId);
        let* _      = putStringAt!(2, x.equipCategory);
        let* _      = putStringAt!(3, x.description);
        let* _      = putS4DateAt!(4, x.validFrom);
        let* _      = putStringAt!(5, x.objectType);
        let* _      = putOptionFloat64At!(7, x.grossWeight);
        let* _      = putStringAt!(8, x.unitOfWeight);
        let* _      = putS4DateAt!(11, x.startupDate);
        let* _      = putStringAt!(15, x.manufacturer);
        let* _      = putStringAt!(16, x.modelNumber);
        let* _      = putStringAt!(17, x.manufPartNo);
        let* _      = putStringAt!(18, x.manufSerialNo);
        let* _      = putInt32At!(20, x.constructYear);
        let* _      = putStringAt!(21, String.padLeft(2, '0', "${x.constructMth}"));
        let* _      = putInt32At!(22, x.maintPlant);
        let* _      = putStringAt!(27, x.workCenter);
        let* _      = putInt32At!(29, x.companyCode);           /// AD BukrEilo
        let* _      = putInt32At!(34, x.coArea);                /// AI 
        let* _      = putInt32At!(38, x.planningPlant);
        let* _      = putStringAt!(40, x.mainWorkCenter);
        let* _      = putStringAt!(42, x.functionalLoc);
        let* _      = putStringAt!(43, x.superordEquip);
        let* _      = putStringAt!(44, position4(x.position));
        let* _      = putStringAt!(45, x.techIdentNo);
        let* _      = putStringAt!(50, x.statusProfile);
        let* _      = putStringAt!(51, x.statusOfAnObject);
        return()


    /// Writes to a template (i.e an empty UXL workbook with sheets, headers etc. set up).
    /// Equipemnt only
    pub def writeEquipmentDataMem(xs: List[EquipmentData]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, getSheetNamed, setCursor!, appendRow, mapX};      
        let* s1     = getSheetNamed("Equipment Data");
        let* _      = setCursor!(s1, 6);
        mapX(x -> appendRow(s1, setEquipmentDataMem!(x)), xs)

    /// Not all fields are written... (1909)
    /// Equipment only (Mem)
    def setEquipmentDataMem!(x: EquipmentData): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!, putInt32At!, putOptionInt32At!, putOptionFloat64At!};
        use AssetLib/Base/S4/SheetIOUtils.{putS4DateAt!};
        let* _      = putStringAt!(0, x.equiId);
        let* _      = putStringAt!(2, x.equipCategory);
        let* _      = putStringAt!(3, x.description);
        let* _      = putS4DateAt!(4, x.validFrom); 
        let* _      = putStringAt!(5, x.objectType);
        let* _      = putOptionFloat64At!(7, x.grossWeight);
        let* _      = putStringAt!(8, x.unitOfWeight);
        let* _      = putS4DateAt!(11, x.startupDate);
        let* _      = putStringAt!(15, x.manufacturer);
        let* _      = putStringAt!(16, x.modelNumber);
        let* _      = putStringAt!(17, x.manufPartNo);
        let* _      = putStringAt!(18, x.manufSerialNo);
        let* _      = putInt32At!(20, x.constructYear);
        let* _      = putStringAt!(21, String.padLeft(2, '0', "${x.constructMth}"));
        let* _      = putInt32At!(22, x.maintPlant);
        let* _      = putStringAt!(27, x.workCenter);
        let* _      = putInt32At!(29, x.companyCode);           /// AD BukrEilo
        let* _      = putInt32At!(34, x.coArea);                /// AI 
        let* _      = putInt32At!(38, x.planningPlant);
        let* _      = putStringAt!(40, x.mainWorkCenter);
        let* _      = putInt32At!(41, x.plantWorkCenter);
        let* _      = putStringAt!(43, x.functionalLoc);
        let* _      = putStringAt!(44, x.superordEquip);
        let* _      = putStringAt!(45, position4(x.position));
        let* _      = putStringAt!(46, x.techIdentNo);
        let* _      = putStringAt!(51, x.statusProfile);
        let* _      = putStringAt!(52, x.statusOfAnObject);
        return()


    /// EQ-Multilingual Text

    /// Writes to a template (i.e an empty UXL workbook with sheets, headers etc. set up).
    pub def writeEqMultilingualTextMocr(xs: List[EqMultilingualText]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, getSheetNamed, setCursor!, appendRow, mapX};      
        let* s1     = getSheetNamed("EQ-Multilingual Text");
        let* _      = setCursor!(s1, 6);
        mapX(x -> appendRow(s1, setEqMultilingualTextMocr!(x)), xs)

    /// (1909)
    def setEqMultilingualTextMocr!(x: EqMultilingualText): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!};
        use AssetLib/Base/S4/SheetIOUtils.{putS4BoolAt!};
        let* _      = putStringAt!(0, x.equiId);
        let* _      = putS4BoolAt!(1, x.deleteIndicator);
        let* _      = putStringAt!(2, x.language);
        let* _      = putStringAt!(3, x.description);
        let* _      = putStringAt!(4, x.longText);
        return()


    /// EQ-Classification

    /// Writes to a template (i.e an empty UXL workbook with sheets, headers etc. set up).
    pub def writeEqClassificationMocr(xs: List[EqClassification]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, getSheetNamed, setCursor!, appendRow, mapX};      
        let* s1     = getSheetNamed("EQ-Classification");
        let* _      = setCursor!(s1, 6);
        mapX(x -> appendRow(s1, setEqClassificationMocr!(x)), xs)

    /// (1909)
    /// Multiple Object (floc and equi)
    def setEqClassificationMocr!(x: EqClassification): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!};
        use AssetLib/Base/S4/SheetIOUtils.{putS4BoolAt!};
        let* _      = putStringAt!(0, x.equiId);
        let* _      = putS4BoolAt!(1, x.deleteInd);
        let* _      = putStringAt!(2, x.classType);
        let* _      = putStringAt!(3, x.className);
        let* _      = putStringAt!(4, x.characteristicName);
        let* _      = putStringAt!(5, x.charValue);
        let* _      = putS4BoolAt!(6, x.charDeleteInd);
        return()

/// Writes to a template (i.e an empty UXL workbook with sheets, headers etc. set up).
    pub def writeEqClassificationMem(xs: List[EqClassification]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, getSheetNamed, setCursor!, appendRow, mapX};      
        let* s1     = getSheetNamed("Classification");
        let* _      = setCursor!(s1, 6);
        mapX(x -> appendRow(s1, setEqClassificationMem!(x)), xs)


    /// Multiple equipment (equi only)
    def setEqClassificationMem!(x: EqClassification): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!};
        use AssetLib/Base/S4/SheetIOUtils.{putS4BoolAt!};
        let* _      = putStringAt!(0, x.equiId);
        let* _      = putS4BoolAt!(1, x.deleteInd);
        let* _      = putStringAt!(2, x.classType);
        let* _      = putStringAt!(3, x.className);
        let* _      = putS4BoolAt!(4, x.charDeleteInd);
        let* _      = putStringAt!(5, x.characteristicName);
        let* _      = putStringAt!(6, x.charValue);        
        return()


}