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
    

namespace AssetLib/S4/FileIO/UxlFile/XlsxWriter {

    use SheetIO.RowSetter;
    use SheetIO.SheetWriter;

    use AssetLib/S4/FileIO/UxlFile/Datatypes.{ChangeRequestDetails,
        CreateFunctionalLocationData, UpdateFunctionalLocationData, FlDataUpdate1, 
        FlMultilingualText, FlClassification, 
        CreateEquipmentData, UpdateEquipmentData, EqDataUpdate1, 
        EqMultilingualText, EqClassification};


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
    pub def writeCreateFunctionalLocationData(xs: List[CreateFunctionalLocationData]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, getSheetNamed, setCursor!, appendRow, mapX};      
        let* s1     = getSheetNamed("Functional Location Data");
        let* _      = setCursor!(s1, 6);
        mapX(x -> appendRow(s1, setCreateFunctionalLocationData!(x)), xs)


    /// Just write fields of interest...
    def setCreateFunctionalLocationData!(x: CreateFunctionalLocationData): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!, putInt32At!};
        use AssetLib/S4/Base/SheetIOUtils.{putS4BoolAt!, putS4DateAt!};
        let* _      = putStringAt!(0, x.functionalLocation);
        let* _      = putStringAt!(1, x.maskedFuncLoc);
        let* _      = putStringAt!(2, x.description);
        let* _      = putInt32At!(3, x.functLocCat);
        let* _      = putStringAt!(4, x.strIndicator);
        let* _      = putStringAt!(5, x.objectType);
        let* _      = putS4DateAt!(12, x.startupDate);
        let* _      = putInt32At!(23, x.maintPlant);
        let* _      = putInt32At!(30, x.companyCode);
        let* _      = putInt32At!(35, x.coArea);
        let* _      = putStringAt!(46, x.supFunctLoc);
        let* _      = putS4BoolAt!(47, x.equipInstall);
        let* _      = putStringAt!(49, x.statusProfile);
        let* _      = putStringAt!(50, x.userStatus);
        return()

    pub def writeUpdateFunctionalLocationData(xs: List[UpdateFunctionalLocationData]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, getSheetNamed, setCursor!, appendRow, mapX};      
        let* s1     = getSheetNamed("Functional Location Data");
        let* _      = setCursor!(s1, 6);
        mapX(x -> appendRow(s1, setUpdateFunctionalLocationData!(x)), xs)


    def setUpdateFunctionalLocationData!(x: UpdateFunctionalLocationData): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!, mapX};
        let* _      = putStringAt!(0, x.functionalLocation);
        mapX(setFlDataUpdate1!, x.updates)

    def setFlDataUpdate1!(x: FlDataUpdate1): RowSetter[Unit] = 
        use SheetIO/RowSetter.{putStringAt!, putInt32At!};
        use AssetLib/S4/Base/SheetIOUtils.{putS4DateAt!, putS4BoolAt!};
        use AssetLib/S4/FileIO/UxlFile/Datatypes.FlDataUpdate1.{Description, FunctLocCat, StrIndicator, 
            ObjectType, StartupDate, MaintPlant, CompanyCode, CoArea, SupFunctLoc, EquipInstall, 
            StatusProfile, UserStatus};
        match x {
            case Description(s)     => putStringAt!(2, s)
            case FunctLocCat(i)     => putInt32At!(3, i)
            case StrIndicator(s)    => putStringAt!(4, s)
            case ObjectType(s)      => putStringAt!(5, s)
            case StartupDate(dt)    => putS4DateAt!(12, dt)
            case MaintPlant(i)      => putInt32At!(23, i)
            case CompanyCode(i)     => putInt32At!(30, i)
            case CoArea(i)          => putInt32At!(35, i)
            case SupFunctLoc(s)     => putStringAt!(46, s)
            case EquipInstall(b)    => putS4BoolAt!(47, b)
            case StatusProfile(s)   => putStringAt!(49, s)
            case UserStatus(s)      => putStringAt!(50, s)
        }

    /// FL-Multilingual Text

    /// Assumes an empty UXL workbook with sheets, headers etc. set up.
    pub def writeFlMultilingualText(xs: List[FlMultilingualText]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, getSheetNamed, setCursor!, appendRow, mapX};      
        let* s1     = getSheetNamed("FL-Multilingual Text");
        let* _      = setCursor!(s1, 6);
        mapX(x -> appendRow(s1, setFlMultilingualText!(x)), xs)

    def setFlMultilingualText!(x: FlMultilingualText): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!};
        use AssetLib/S4/Base/SheetIOUtils.{putS4BoolAt!};
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
        use AssetLib/S4/Base/SheetIOUtils.{putS4BoolAt!};
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
    pub def writeCreateEquipmentData(xs: List[CreateEquipmentData]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, getSheetNamed, setCursor!, appendRow, mapX};      
        let* s1     = getSheetNamed("Equipment Data");
        let* _      = setCursor!(s1, 6);
        mapX(x -> appendRow(s1, setCreateEquipmentData!(x)), xs)


    /// Not all fields are written...
    def setCreateEquipmentData!(x: CreateEquipmentData): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!, putInt32At!, putOptionInt32At!, putOptionFloat64At!};
        use AssetLib/S4/Base/SheetIOUtils.{putS4DateAt!, putPaddedInt32At!};
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

    /// Assumes an empty UXL workbook with sheets, headers etc. set up.
    pub def writeUpdateEquipmentData(xs: List[UpdateEquipmentData]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, getSheetNamed, setCursor!, appendRow, mapX};      
        let* s1     = getSheetNamed("Equipment Data");
        let* _      = setCursor!(s1, 6);
        mapX(x -> appendRow(s1, setUpdateEquipmentData!(x)), xs)


    def setUpdateEquipmentData!(x: UpdateEquipmentData): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!, mapX};
        let* _      = putStringAt!(0, x.equiId);
        mapX(setEqDataUpdate1!, x.updates)

    def setEqDataUpdate1!(x: EqDataUpdate1): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!, putInt32At!, putFloat64At!};
        use AssetLib/S4/Base/SheetIOUtils.{putS4DateAt!, putPaddedInt32At!};
        use AssetLib/S4/FileIO/UxlFile/Datatypes.EqDataUpdate1.{EquipCategory, Description, ObjectType,
            GrossWeight, UnitOfWeight, StartupDate, Manufacturer, ModelNumber, ManufPartNo, ManufSerialNo,
            ConstructYear, ConstructMth, MaintPlant, CompanyCode, CoArea, PlanningPlant,  FunctionalLoc, 
            SuperordEquip, Position, TechIdentNo, StatusProfile, StatusOfAnObject};
        match x {
            case EquipCategory(s)       => putStringAt!(1, s)
            case Description(s)         => putStringAt!(2, s)
            case ObjectType(s)          => putStringAt!(4, s)
            case GrossWeight(d)         => putFloat64At!(7, d)
            case UnitOfWeight(s)        => putStringAt!(8, s)
            case StartupDate(dt)        => putS4DateAt!(10, dt)
            case Manufacturer(s)        => putStringAt!(14, s)
            case ModelNumber(s)         => putStringAt!(15, s)
            case ManufPartNo(s)         => putStringAt!(16, s)
            case ManufSerialNo(s)       => putStringAt!(17, s)
            case ConstructYear(i)       => putInt32At!(19, i)
            case ConstructMth(i)        => putPaddedInt32At!(20, 2, '0', i)
            case MaintPlant(i)          => putInt32At!(21, i)
            case CompanyCode(i)         => putInt32At!(28, i)
            case CoArea(i)              => putInt32At!(33, i)
            case PlanningPlant(i)       => putInt32At!(37, i)
            case FunctionalLoc(s)        => putStringAt!(42, s)
            case SuperordEquip(s)       => putStringAt!(43, s)
            case Position(i)            => putInt32At!(44, i)
            case TechIdentNo(s)         => putStringAt!(45, s)
            case StatusProfile(s)       => putStringAt!(50, s)
            case StatusOfAnObject(s)    => putStringAt!(51, s)
        }


    /// EQ-Multilingual Text

    /// Assumes an empty UXL workbook with sheets, headers etc. set up.
    pub def writeEqMultilingualText(xs: List[EqMultilingualText]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, getSheetNamed, setCursor!, appendRow, mapX};      
        let* s1     = getSheetNamed("EQ-Multilingual Text");
        let* _      = setCursor!(s1, 6);
        mapX(x -> appendRow(s1, setEqMultilingualText!(x)), xs)

    def setEqMultilingualText!(x: EqMultilingualText): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!};
        use AssetLib/S4/Base/SheetIOUtils.{putS4BoolAt!};
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
        use AssetLib/S4/Base/SheetIOUtils.{putS4BoolAt!};
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