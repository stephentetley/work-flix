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
        EquipmentData, EqMultilingualText, EqClassification};
    
    use AutoLifting.ReportMonad;
    use AutoLifting/Datatypes.{Phase3FinalWorkItem, EquiData, EquiClassification};


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
        let equis       = List.map(genEquipmentData, xs);
        let* _          = AssetLib/S4/FileIO/UxlFile/XlsxWriter.writeEquipmentData(equis);
        let mltexts     = List.flatMap(genEqMultilingualText, xs);        
        let* _          = AssetLib/S4/FileIO/UxlFile/XlsxWriter.writeEqMultilingualText(mltexts);        
        let classifs    = List.flatMap(genEqClassifications, xs);        
        let* _          = AssetLib/S4/FileIO/UxlFile/XlsxWriter.writeEqClassification(classifs);
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

    def genEquipmentData(x: Phase3FinalWorkItem): EquipmentData = 
        let f64None : Option[Float64] = None;       /// TODO this should be unnecessary, but it currently fixes a runtime cast error
        let i32None : Option[Int32] = None;       /// TODO this should be unnecessary, but it currently fixes a runtime cast error
        { equiId                = x.s4EquiId
        , equipCategory         = x.equiData.category
        , description           = x.equiData.description
        , objectType            = x.equiData.objectType
        , grossWeight           = f64None
        , unitOfWeight          = ""
        , startupDate           = Some(x.equiData.startupDate)
        , manufacturer          = x.equiData.manufacturer
        , modelNumber           = x.equiData.model
        , manufPartNo           = x.equiData.partNumber
        , manufSerialNo         = x.equiData.serialNumber
        , constructYear         = Time/LocalDate.getYear(x.equiData.startupDate)
        , constructMth          = Time/LocalDate.getMonth(x.equiData.startupDate)
        , maintPlant            = 2100
        , companyCode           = 2100
        , coArea                = 1000
        , planningPlant         = 2100
        , functionalLoc         = x.equiData.functionalLocation
        , superordEquip         = ""
        , position              = i32None
        , techIdentNo           = ""
        , statusProfile         = "ZEQUIPST"
        , statusOfAnObject      = "OPER"
        }



    def genEqMultilingualText(x: Phase3FinalWorkItem): List[EqMultilingualText] = 
        match x.multilingualText {
            case Some(mltext) => {
                let v1 = { equiId            = x.s4EquiId
                         , deleteIndicator   = false
                         , language          = "EN"
                         , description       = mltext.description
                         , longText          = mltext.longText
                         };
                v1 :: Nil
            }
            case None => Nil
        }
        
    def genEqClassifications(x: Phase3FinalWorkItem): List[EqClassification] = 
        List.map(genEqClassification1(x.s4EquiId), x.classifications)

    def genEqClassification1(equiId: String, x: EquiClassification): EqClassification = 
        { equiId                = equiId
        , deleteInd             = false
        , classType             = "002"
        , className             = x.equiClass
        , status                = "1"
        , characteristicName    = x.characteristicName
        , charValue             = x.value
        , charDeleteInd         = false
        }

}