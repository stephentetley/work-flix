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

namespace AutoLifting/Base/LiftingEquipmentToSimple {


    use AssetLib/S4/Simple/Datatypes.{S4Equipment, EquiAttributes, LongText, Classification};
    use AssetLib/S4/Simple.{Classifications};
    use AutoLifting/Base/Datatypes.{LiftingEquipment, LiftingAttributes, LiftingClassifications};
    use AutoLifting/Base.ReportMonad;

    pub def translateLiftingEquipment(x: LiftingEquipment): ReportMonad[S4Equipment] = 
        use AutoLifting/Base/ReportMonad.{flatMap, return, liftAction};
        let attributes          = translateLiftingAttributes(x.objectType, x.attributes);
        let longText            = translateLongText(x.attributes.description, x.longText);
        let classifications     = translateLiftingClassifications(x.objectClass, x.classifications);
        return(
            { equiId            = x.equiId
            , attributes        = attributes
            , longText          = longText
            , classifications   = classifications
            })

    def translateLiftingAttributes(objectType: String, x: LiftingAttributes): EquiAttributes = 
        let year    = Time/LocalDate.getYear(x.startupDate);
        let month   = Time/LocalDate.getMonth(x.startupDate);
        { category              = x.category
        , description           = x.description
        , objectType            = objectType
        , startupDate           = x.startupDate
        , manufacturer          = x.manufacturer
        , model                 = x.model
        , partNumber            = x.partNumber
        , serialNumber          = x.serialNumber
        , constructionYear      = year
        , constructionMonth     = month
        , maintPlant            = x.maintPlant
        , companyCode           = x.companyCode
        , controllingArea       = x.controllingArea
        , planningPlant         = x.planningPlant
        , functionalLocation    = x.functionalLocation
        , superOrdinateEqui     = x.superOrdinateEqui
        , status                = x.status
        }

    def translateLongText(description : String, longText: String): Option[LongText] = 
        if(String.isEmpty(longText))
            None
        else
            Some({shortText = description, longText = longText})

    /// TODO if length(locationOnSite) > 30 make it a longtext
    def translateLiftingClassifications(objectClass: String, x: LiftingClassifications): List[Classification] = 
        use AssetLib/S4/Simple/Classifications.{getClassifications, concat, whenTrue, whenSome, ai2AibReference, 
            easting, northing, uniclassCode, uniclassDesc, locationOnSite, decimalClassification,
            stringClassification, statutoryReferenceNumber, testCertNo};
        concat( 
                ai2AibReference(x.pliReference) 
            :: ai2AibReference(x.saiParentReference)
            :: whenSome(x.easting, i-> easting(i))
            :: whenSome(x.northing, i -> northing(i))
            :: uniclassCode(objectClass)
            :: uniclassDesc(objectClass)
            :: whenTrue(not String.isEmpty(x.locationOnSite), locationOnSite(objectClass, x.locationOnSite))
            :: whenSome(x.workingLoad, d -> decimalClassification(objectClass, x.workingLoadFieldName, d))
            :: whenTrue(not String.isEmpty(x.workingLoadUnits), stringClassification(objectClass, x.workingLoadUnitsFieldName, x.workingLoadUnits))
            :: whenTrue(not String.isEmpty(x.statutoryReference), statutoryReferenceNumber(objectClass, x.statutoryReference))
            :: whenTrue(not String.isEmpty(x.testCertNumber), testCertNo(objectClass, x.testCertNumber)) 
            :: Nil
        ) |> getClassifications


}