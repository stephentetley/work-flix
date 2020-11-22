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


namespace AutoLifting/Difference {

    use AutoLifting/Base/Datatypes.{LiftingEquipment, LiftingAttributes, LiftingClassifications};

    pub opaque type DiffList[a] = Data/Transient.DList[a]

    pub def equals(x: a, y:a): Bool = x == y

    pub def noDiff(): DiffList[d] = DiffList(Data/Transient/DList.empty())
    
    pub def difference1(delta: d): DiffList[d] = DiffList(Data/Transient/DList.singleton(delta))

    pub def diff(cmp: (a,a) -> Bool, x: a, y: a, delta: d): DiffList[d] = 
        use Data/Transient/DList.{empty, singleton};
        if (cmp(x,y)) 
            noDiff()
        else 
            difference1(delta)

    pub def append(x: DiffList[d], y: DiffList[d]): DiffList[d] = 
        use Data/Transient/DList.{append};
        let DiffList(x1) = x;
        let DiffList(y1) = y;
        DiffList(x1 `append` y1)

    /// Diff types that can use builting equality...
    pub def diffEquals(x: a, y: a, delta: d): DiffList[d] = diff((a,b) -> a == b, x, y, delta)

    pub def diffOption(cmp: (a,a) -> Bool, x: Option[a], y: Option[a], delta: d): DiffList[d] = 
        match (x, y) { 
            case (Some(x1), Some(y1))   => if (cmp(x1, y1)) noDiff() else difference1(delta)
            case (None,     None)       => noDiff()
            case (_, _)                 => difference1(delta)
        }

    pub def diffTuple2(cmp1: (a,a) -> Bool, cmp2: (b,b) -> Bool, x: (a,b), y: (a,b), delta: d): DiffList[d] = 
        let (xa, xb) = x;
        let (ya, yb) = y;
        if (cmp1(xa, ya) && cmp2(xb, yb)) noDiff() else difference1(delta)


    /// pub def difference(x: LiftingEquipment, y: LiftingEquipment): LiftingEquipment = 
    ///     let attributes      = diffAttributes(x.attributes, y.attributes);
    ///     let classifications = diffClassifications(x.classifications, y.classifications);
    ///     { equiId            = y.equiId
    ///     , objectType        = if (x.objectType == y.objectType) "" else y.objectType
    ///     , objectClass       = if (x.objectClass == y.objectClass) "" else y.objectClass
    ///     , attributes        = attributes
    ///     , longText          = if (x.longText == y.longText) "" else y.longText
    ///     , classifications   = classifications
    ///     }

    /// def diffAttributes(x: LiftingAttributes, y: LiftingAttributes): LiftingAttributes = 
    ///     // let startupDate1 = if (Time/LocalDate.equals(x.startUpDate, y.startupDate)) ;
    ///     { category              = if (x.category == y.category) "" else y.category
    ///     , description           = if (x.description == y.description) "" else y.description
    ///     , startupDate           = y.startupDate         /// TODO - should this be an option or not... ?
    ///     , manufacturer          = if (x.manufacturer == y.manufacturer) "" else y.manufacturer
    ///     , model                 = if (x.model == y.model) "" else y.model
    ///     , partNumber            = if (x.partNumber == y.partNumber) "" else y.partNumber
    ///     , serialNumber          = if (x.serialNumber == y.serialNumber) "" else y.serialNumber
    ///     , maintPlant            = if (x.maintPlant == y.maintPlant) "" else y.maintPlant
    ///     , companyCode           = if (x.companyCode == y.companyCode) "" else y.companyCode
    ///     , controllingArea       = if (x.controllingArea == y.controllingArea) "" else y.controllingArea
    ///     , planningPlant         = if (x.planningPlant == y.planningPlant) "" else y.planningPlant
    ///     , functionalLocation    = if (x.functionalLocation == y.functionalLocation) "" else y.functionalLocation
    ///     , superOrdinateEqui     = if (x.superOrdinateEqui == y.superOrdinateEqui) "" else y.superOrdinateEqui
    ///     , status                = if (x.status == y.status) "" else y.status
    ///     }

    /// def diffClassifications(x: LiftingClassifications, y: LiftingClassifications): LiftingClassifications = 
    ///     let easting1        = diffOption((x,y) -> x == y, x.easting, y.easting);
    ///     let northing1       = diffOption((x,y) -> x == y, x.northing, y.northing);
    ///     let workingLoad1    = diffOption((x,y) -> x == y, x.workingLoad, y.workingLoad);
    ///     { pliReference              = if (x.pliReference == y.pliReference) "" else y.pliReference
    ///     , saiParentReference        = if (x.saiParentReference == y.saiParentReference) "" else y.saiParentReference
    ///     , easting                   = easting1
    ///     , northing                  = northing1
    ///     , locationOnSite            = if (x.locationOnSite == y.locationOnSite) "" else y.locationOnSite
    ///     , workingLoadFieldName      = if (x.workingLoadFieldName == y.workingLoadFieldName) "" else y.workingLoadFieldName
    ///     , workingLoad               = workingLoad1
    ///     , workingLoadUnitsFieldName = if (x.workingLoadUnitsFieldName == y.workingLoadUnitsFieldName) "" else y.workingLoadUnitsFieldName
    ///     , workingLoadUnits          = if (x.workingLoadUnits == y.workingLoadUnits) "" else y.workingLoadUnits
    ///     , statutoryReference        = if (x.statutoryReference == y.statutoryReference) "" else y.statutoryReference
    ///     , testCertNumber            = if (x.testCertNumber == y.testCertNumber) "" else y.testCertNumber
    ///     }


    pub enum LiftingAttributesUpdate {
        case SetCategory(String)
        case SetDescription(String)
        case SetStartupDate(Time.LocalDate)
        case SetManufacturer(String)
        case SetModel(String)
        case SetPartNumber(String)
        case SetSerialNumber(String)
        case SetMaintPlant(Int32)
        case SetCompanyCode(Int32)
        case SetControllingArea(Int32)
        case SetPlanningPlant(Int32)
        case SetFunctionalLocation(String)
        case SetSuperOrdinateEqui(String)
        case SetStatus(String)
    }

    pub def diffAttributes(x: LiftingAttributes, y: LiftingAttributes): DiffList[LiftingAttributesUpdate] = 
                    diffEquals(x.category, y.category, SetCategory(y.category))
        `append`    diffEquals(x.description, y.description, SetDescription(y.description))
        `append`    diff(Time/LocalDate.equals, x.startupDate, y.startupDate, SetStartupDate(y.startupDate))
        `append`    diffEquals(x.manufacturer, y.manufacturer, SetManufacturer(y.manufacturer))
        `append`    diffEquals(x.model, y.model, SetModel(y.model))
        `append`    diffEquals(x.partNumber, y.partNumber, SetPartNumber(y.partNumber))
        `append`    diffEquals(x.serialNumber, y.serialNumber, SetSerialNumber(y.serialNumber))
        `append`    diffEquals(x.maintPlant, y.maintPlant, SetMaintPlant(y.maintPlant))
        `append`    diffEquals(x.companyCode, y.companyCode, SetCompanyCode(y.companyCode))
        `append`    diffEquals(x.controllingArea, y.controllingArea, SetControllingArea(y.controllingArea))
        `append`    diffEquals(x.planningPlant, y.planningPlant, SetPlanningPlant(y.planningPlant))
        `append`    diffEquals(x.functionalLocation, y.functionalLocation, SetFunctionalLocation(y.functionalLocation))
        `append`    diffEquals(x.superOrdinateEqui, y.superOrdinateEqui, SetSuperOrdinateEqui(y.superOrdinateEqui))
        `append`    diffEquals(x.status, y.status, SetStatus(y.status))

    /// A case for each record field
    pub enum LiftingClassificationsUpdate { 
        case SetPliReference(String)
        case SetSaiParentReference(String)
        case SetEasting(Option[Int32])
        case SetNorthing(Option[Int32])
        case SetLocationOnSite(String)
        case SetWorkingLoadFieldName(String)
        case SetWorkingLoad(Option[Float64])
        case SetWorkingLoadUnitsFieldName(String)
        case SetWorkingLoadUnits(String)
        case SetStatutoryReference(String)
        case SetTestCertNumber(String)
    }

    pub def diffClassifications(x: LiftingClassifications, y: LiftingClassifications): DiffList[LiftingClassificationsUpdate] = 
                    diffEquals(x.pliReference, y.pliReference, SetPliReference(y.pliReference))
        `append`    diffEquals(x.saiParentReference, y.saiParentReference, SetSaiParentReference(y.saiParentReference))
        `append`    diffOption(equals, x.easting, y.easting, SetEasting(y.easting))
        `append`    diffOption(equals, x.northing, y.northing, SetNorthing(y.northing))
        `append`    diffEquals(x.locationOnSite, y.locationOnSite, SetLocationOnSite(y.locationOnSite))
        `append`    diffEquals(x.workingLoadFieldName, y.workingLoadFieldName, SetWorkingLoadFieldName(y.workingLoadFieldName))
        `append`    diffOption(equals, x.workingLoad, y.workingLoad, SetWorkingLoad(y.workingLoad))
        `append`    diffEquals(x.workingLoadUnitsFieldName, y.workingLoadUnitsFieldName, SetWorkingLoadUnitsFieldName(y.workingLoadUnitsFieldName))
        `append`    diffEquals(x.workingLoadUnits, y.workingLoadUnits, SetWorkingLoadUnits(y.workingLoadUnits))
        `append`    diffEquals(x.statutoryReference, y.statutoryReference, SetStatutoryReference(y.statutoryReference))
        `append`    diffEquals(x.testCertNumber, y.testCertNumber, SetTestCertNumber(y.testCertNumber))



}