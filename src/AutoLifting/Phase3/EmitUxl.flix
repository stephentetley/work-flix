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

namespace AutoLifting/Phase3/EmitUxl {

    use SheetIO.SheetWriter;
    use AssetLib/S4/FileIO/UxlFile/Datatypes.{ChangeRequestDetails, 
        EquipmentData => UxlEquipmentData, EqMultilingualText, EqClassification};
    
    use AutoLifting.ReportMonad;
    use AutoLifting/Datatypes.{Phase3FinalWorkItem, EquipmentData, EquiMultilingualText, EquiClassification};


    pub def writeputUxlFile(description: String, 
                            xs: List[Phase3FinalWorkItem],
                            templatePath: System.FilePath,
                            outPath: System.FilePath): ReportMonad[Unit] = 
        use AutoLifting/ReportMonad.{liftActionResult};
        use SheetIO/SheetWriter.{runTemplateXssf};
        liftActionResult(_ -> runTemplateXssf(outputChangeRequestDetails(description, xs), templatePath, outPath))


    pub def outputChangeRequestDetails(description: String, xs: List[Phase3FinalWorkItem]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, return};
        let crDetails   = genChangeRequestDetails(description, xs);
        let* _          = AssetLib/S4/FileIO/UxlFile/XlsxWriter.writeChangeRequestDetails(crDetails);
        let equis       = List.map(genEquipmentData1, xs);
        let* _          = AssetLib/S4/FileIO/UxlFile/XlsxWriter.writeEquipmentData(equis);
        return()
        


    pub def genChangeRequestDetails[r](description: String, xs: List[{s4EquiId: String |r}]): List[ChangeRequestDetails] = 
        let fn = (r1, ix) -> genChangeRequestDetails1({description = description, equiId = r1.s4EquiId}, ix < 1);
        List.mapWithIndex(fn, xs)

    def genChangeRequestDetails1(rec: {description: String, 
                                          equiId: String}, initial: Bool): ChangeRequestDetails = 
        { description           = if (initial) rec.description else ""
        , changeRequestType     = if (initial) "AIWEAM0P" else ""
        , flFunctionalLocation  = ""
        , eqEquipment           = rec.equiId
        , processRequester      = "ASSET DATA"
        }

    def genEquipmentData1(x: Phase3FinalWorkItem): UxlEquipmentData = 
        { equiId                = x.s4EquiId
        , equipCategory         = x.equipmentData.category
        , description           = x.equipmentData.description
        , objectType            = x.equipmentData.objectType
        , grossWeight           = None
        , unitOfWeight          = ""
        , startupDate           = Some(x.equipmentData.startupDate)
        , manufacturer          = x.equipmentData.manufacturer
        , modelNumber           = x.equipmentData.model
        , manufPartNo           = x.equipmentData.partNumber
        , manufSerialNo         = x.equipmentData.serialNumber
        , constructYear         = Time/LocalDate.getYear(x.equipmentData.startupDate)
        , constructMth          = Time/LocalDate.getMonth(x.equipmentData.startupDate)
        , maintPlant            = 2100
        , companyCode           = 2100
        , coArea                = 1000
        , planningPlant         = 2100
        , functionalLoc         = x.equipmentData.functionalLocation
        , superordEquip         = ""
        , position              = None
        , techIdentNo           = ""
        , statusProfile         = "ZEQUIPST"
        , statusOfAnObject      = "OPER"
        }

    pub def genEqMultilingualText[r](xs: List[{equiId: String, s4EquiName: String, longText: Option[String]|r}]): List[EqMultilingualText] = 
        let fn = r1 -> match r1.longText { 
            case Some(s) if !(String.isEmpty(s)) => 
                Some(genEqMultilingualText1({{equiId = r1.equiId, description = r1.s4EquiName, longText = s}}))
            case None => None
        };
        List.filterMap(fn, xs)

    def genEqMultilingualText1(rec: {equiId: String, description: String, longText: String}): EqMultilingualText = 
        { equiId            = rec.equiId
        , deleteIndicator   = false
        , language          = "EN"
        , description       = rec.description
        , longText          = rec.longText
        }

    pub def genEqClassification1(rec: {equiId: String, className: String, charName: String, charValue: String}): EqClassification = 
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