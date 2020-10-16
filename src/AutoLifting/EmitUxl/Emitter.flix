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

    use SheetIO.SheetWriter;
    use AssetLib/S4/FileIO/UxlFile/Datatypes.{ChangeRequestDetails, 
        EquipmentData, EqMultilingualText, EqClassification};
    
    use AutoLifting.ReportMonad;
    use AutoLifting/Datatypes.{Phase2FinalWorkItem};



    /// Ids of form cf "$101214878" ... 101,214,878
    pub def addS4EquiIds[r](xs: List[{| r}]): ReportMonad[List[{s4EquiId: String | r}]] =
        use AutoLifting/ReportMonad.{mapM};
        mapM(addS4EquiId, xs)


    def addS4EquiId[r](rec: {| r}): ReportMonad[{ s4EquiId: String | r}] =
        use AutoLifting/ReportMonad.{return, flatMap, genEquiId};
        let* equiId = genEquiId();
        return({+s4EquiId = equiId | rec})

    pub def writeputUxlFile(description: String, 
                               xs: List[Phase2FinalWorkItem],   /// temp
                               templatePath: System.FilePath,
                               outPath: System.FilePath): ReportMonad[Unit] = 
        use AutoLifting/ReportMonad.{return, flatMap, liftActionResult};
        use SheetIO/SheetWriter.{runTemplateXssf};
        let* xs1        = addS4EquiIds(xs);
        liftActionResult(_ -> runTemplateXssf(outputChangeRequestDetails(description, xs1), templatePath, outPath))


    pub def outputChangeRequestDetails[r](description: String, xs: List[{s4EquiId: String |r}]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, return};
        let crDetails   = genChangeRequestDetails(description, xs);
        let* _          = AssetLib/S4/FileIO/UxlFile/XlsxWriter.writeChangeRequestDetails(crDetails);
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

    pub def genEquipmentData1(rec: {equiId: String, 
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