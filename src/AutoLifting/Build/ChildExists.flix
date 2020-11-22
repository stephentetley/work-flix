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

namespace AutoLifting/Build/ChildExists {
    
    use AssetLib/S4/Simple/Datatypes.{S4Equipment, EquiAttributes, LongText, Classification};
    use AutoLifting/Base/Datatypes.{LiftingEquipment};

    pub def translateS4Equipment(x: S4Equipment): LiftingEquipment = 
        { equiId            = x.equiId
        , objectType        = x.attributes.objectType
        , objectClass       = getObjectClass(x)
        , attributes        =
            { category              = x.attributes.category
            , description           = x.attributes.description
            , startupDate           = x.attributes.startupDate
            , manufacturer          = x.attributes.manufacturer
            , model                 = x.attributes.model
            , partNumber            = x.attributes.partNumber
            , serialNumber          = x.attributes.serialNumber
            , maintPlant            = x.attributes.maintPlant
            , companyCode           = x.attributes.companyCode
            , controllingArea       = x.attributes.controllingArea
            , planningPlant         = x.attributes.planningPlant
            , functionalLocation    = x.attributes.functionalLocation
            , superOrdinateEqui     = x.attributes.superOrdinateEqui
            , status                = x.attributes.status   
            }
        , longText          = getLongText(x)
        , classifications   = 
            { pliReference                  = getPliNumber(x)
            , saiParentReference            = getSaiNumber(x)
            , easting                       = getEasting(x)
            , northing                      = getNorthing(x)
            , locationOnSite                = getLocationOnSite(x)
            , workingLoadFieldName          = getWorkLoadField(x)
            , workingLoad                   = getWorkLoad(x)
            , workingLoadUnitsFieldName     = getWorkLoadUnitsField(x)
            , workingLoadUnits              = getWorkLoadUnits(x)
            , statutoryReference            = getStatutoryReferenceNumber(x)
            , testCertNumber                = getTestCertNo(x)
            }
        }


    def getLongText(x: S4Equipment): String = match x.longText {
        case Some(x1) => x1.longText
        case None => ""
    }


    def getObjectClass(x: S4Equipment): String = 
        let fn = c -> String.startsWith(c.className, x.attributes.objectType);
        match List.find(fn, x.classifications) {
            case Some(x1) => x1.className
            case None => ""
        }

    def getPliNumber(x: S4Equipment): String = 
        let fn = c -> String.startsWith(c.value, "PLI") && c.charName == "AI2_AIB_REFERENCE";
        match List.find(fn, x.classifications) {
            case Some(x1) => x1.value
            case None => ""
        }

    def getSaiNumber(x: S4Equipment): String = 
        let fn = c -> !String.startsWith(c.value, "PLI") && c.charName == "AI2_AIB_REFERENCE";
        match List.find(fn, x.classifications) {
            case Some(x1) => x1.value
            case None => ""
        }

    def getEasting(x: S4Equipment): Option[Int32] = 
        let fn = c -> c.className == "EAST_NORTH" && c.charName == "EASTING";
        match List.find(fn, x.classifications) {
            case Some(x1) => Result.toOption(Int32.fromString(x1.value))
            case None => None
        }

    def getNorthing(x: S4Equipment): Option[Int32] = 
        let fn = c -> c.className == "EAST_NORTH" && c.charName == "NORTHING";
        match List.find(fn, x.classifications) {
            case Some(x1) => Result.toOption(Int32.fromString(x1.value))
            case None => None
        }

    def getLocationOnSite(x: S4Equipment): String = 
        let fn = c -> String.startsWith(c.className, x.attributes.objectType) && c.charName == "LOCATION_ON_SITE";
        match List.find(fn, x.classifications) {
            case Some(x1) => x1.value
            case None => ""
        }
    
    def getWorkLoadField(x: S4Equipment): String = 
        let fn = c -> String.startsWith(c.className, x.attributes.objectType) && (String.endsWith(c.charName, "_LOAD") || String.endsWith(c.charName, "_RATING"));
        match List.find(fn, x.classifications) {
            case Some(x1) => x1.charName
            case None => ""
        }

    def getWorkLoad(x: S4Equipment): Option[Float64] = 
        let fn = c -> String.startsWith(c.className, x.attributes.objectType) && (String.endsWith(c.charName, "_LOAD") || String.endsWith(c.charName, "_RATING"));
        match List.find(fn, x.classifications) {
            case Some(x1) => Result.toOption(Float64.fromString(x1.value))
            case None => None
        }

    def getWorkLoadUnitsField(x: S4Equipment): String = 
        let fn = c -> String.startsWith(c.className, x.attributes.objectType) && String.endsWith(c.charName, "_UNITS");
        match List.find(fn, x.classifications) {
            case Some(x1) => x1.charName
            case None => ""
        }

    def getWorkLoadUnits(x: S4Equipment): String = 
        let fn = c -> String.startsWith(c.className, x.attributes.objectType) && String.endsWith(c.charName, "_UNITS");
        match List.find(fn, x.classifications) {
            case Some(x1) => x1.value
            case None => ""
        }

    def getStatutoryReferenceNumber(x: S4Equipment): String = 
        let fn = c -> String.startsWith(c.className, x.attributes.objectType) && c.charName == "STATUTORY_REFERENCE_NUMBER";
        match List.find(fn, x.classifications) {
            case Some(x1) => x1.value
            case None => ""
        }

    def getTestCertNo(x: S4Equipment): String = 
        let fn = c -> String.startsWith(c.className, x.attributes.objectType) && c.charName == "TEST_CERT_NO";
        match List.find(fn, x.classifications) {
            case Some(x1) => x1.value
            case None => ""
        }

}