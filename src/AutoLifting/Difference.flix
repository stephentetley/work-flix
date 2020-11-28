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

    use Data/Transient.DList;
    use Data/Transient/DList.{append};

    
    pub def equals(x: a, y:a): Bool = x == y

    pub def noDiff(): DList[d] = Data/Transient/DList.empty()
    
    pub def difference1(delta: d): DList[d] = Data/Transient/DList.singleton(delta)

    pub def diff(cmp: (a,a) -> Bool, x: a, y: a, delta: d): DList[d] = 
        use Data/Transient/DList.{empty, singleton};
        if (cmp(x,y)) 
            noDiff()
        else 
            difference1(delta)

    
    /// Diff types that can use builting equality...
    pub def diffEquals(x: a, y: a, delta: d): DList[d] = diff((a,b) -> a == b, x, y, delta)

    pub def diffOption(cmp: (a,a) -> Bool, x: Option[a], y: Option[a], delta: d): DList[d] = 
        match (x, y) { 
            case (Some(x1), Some(y1))   => if (cmp(x1, y1)) noDiff() else difference1(delta)
            case (None,     None)       => noDiff()
            case (_, _)                 => difference1(delta)
        }

    pub def diffTuple2(cmp1: (a,a) -> Bool, cmp2: (b,b) -> Bool, x: (a,b), y: (a,b), delta: d): DList[d] = 
        let (xa, xb) = x;
        let (ya, yb) = y;
        if (cmp1(xa, ya) and cmp2(xb, yb)) noDiff() else difference1(delta)


    def collectDiffs(xs: List[a], wrap: List[a] -> d): DList[d] = match xs { 
        case Nil    => noDiff()
        case _      => difference1(wrap(xs))
    }

    /// equiId is immutable
    pub enum LiftingEquipmentUpdate {
        case SetObjectType(String)
        case SetObjectClass(String)
        case SetAttributes(List[LiftingAttributesUpdate])
        case SetLongText(String)
        case SetClassifications(List[LiftingClassificationsUpdate])
    }

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

    pub def diffLiftingEquipment(x: LiftingEquipment, y: LiftingEquipment): List[LiftingEquipmentUpdate] = 
        let attributes1 = diffAttributes(x.attributes, y.attributes);
        let classifications1 = diffClassifications(x.classifications, y.classifications);
        Data/Transient/DList.toList(
                        diffEquals(x.objectType, y.objectType, SetObjectType(y.objectType))
            `append`    diffEquals(x.objectClass, y.objectClass, SetObjectClass(y.objectClass))
            `append`    collectDiffs(attributes1, a1 -> SetAttributes(a1))
            `append`    diffEquals(x.longText, y.longText, SetLongText(y.longText))
            `append`    collectDiffs(classifications1, a1 -> SetClassifications(a1))
        )

    def diffAttributes(x: LiftingAttributes, y: LiftingAttributes): List[LiftingAttributesUpdate] =    
        Data/Transient/DList.toList(
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
        )

    def diffClassifications(x: LiftingClassifications, y: LiftingClassifications): List[LiftingClassificationsUpdate] = 
        Data/Transient/DList.toList(
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
        )


}