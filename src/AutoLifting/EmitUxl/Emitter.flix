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

namespace AutoLifting/EmitUxl/Emitter {

    use AssetLib/S4/FileIO/UxlFile/Datatypes.{EquipmentData, EqMultilingualText, EqClassification};
    

    pub def genEquipmentData(rec: {equiId: String, 
                                   category: String, 
                                   description: String, 
                                   objectType: String,
                                   startupDate: Time.LocalDate,
                                   manufacturer: String, 
                                   modelNumber: String,
                                   partNumber: String,
                                   serialNumber: String,
                                   startupDate: Time.LocalDate,
                                   s4Floc: String}): EquipmentData = 
        { equiId                = rec.equiId
        , equipCategory         = rec.category
        , description           = rec.description
        , objectType            = rec.objectType
        , grossWeight           = None
        , unitOfWeight          = ""
        , startupDate           = Some(rec.startupDate)
        , manufacturer          = rec.manufacturer
        , modelNumber           = rec.modelNumber
        , manufPartNo           = rec.partNumber
        , manufSerialNo         = rec.serialNumber
        , constructYear         = Time/LocalDate.getYear(rec.startupDate)
        , constructMth          = Time/LocalDate.getMonth(rec.startupDate)
        , maintPlant            = 2100
        , companyCode           = 2100
        , coArea                = 1000
        , planningPlant         = 2100
        , functionalLoc         = rec.s4Floc
        , superordEquip         = ""
        , position              = None
        , techIdentNo           = ""
        , statusProfile         = "ZEQUIPST"
        , statusOfAnObject      = "OPER"
        }

    pub def genEqMultilingualText(rec: {equiId: String, description: String, longText: String}): EqMultilingualText = 
        { equiId            = rec.equiId
        , deleteIndicator   = false
        , language          = "EN"
        , description       = rec.description
        , longText          = rec.longText
        }

    pub def genEqClassification(rec: {equiId: String, className: String, charName: String, charValue: String}): EqClassification = 
        { equiId                = rec.equiId
        , deleteInd             = false
        , classType             = "002"
        , className             = rec.className
        , status                = "1"
        , characteristicName    = rec.charName
        , charValue             = rec.charValue
        , charDeleteInd         = false
        }

}