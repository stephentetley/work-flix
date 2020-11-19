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

namespace AssetLib/S4/Simple/EmitUxl {

    use SheetIO.SheetWriter;
    use AssetLib/S4/FileIO/UxlFile/Datatypes.{ChangeRequestDetails => UxlChangeRequestDetails
        , FunctionalLocationData => UxlFunctionalLocationData
        , FlMultilingualText => UxlFlMultilingualText
        , FlClassification => UxlFlClassification
        , EquipmentData => UxlEquipmentData
        , EqMultilingualText => UxlEqMultilingualText
        , EqClassification => UxlEqClassification};

    use AssetLib/S4/Simple/Datatypes.{S4Floc, S4Equipment, FlocAttributes, EquiAttributes, LongText, Classification};

    pub def outputUxl( description: String
                     , flocs: List[S4Floc]
                     , equis: List[S4Equipment]
                     , uxlTemplate: System.FilePath
                     , outpath: System.FilePath): Result[Unit, System.Error] & Impure = 
        SheetIO/SheetWriter.runTemplateXssf(emitUxl(description, flocs, equis), uxlTemplate, outpath)

    pub def emitUxl(description: String, flocs: List[S4Floc], equis: List[S4Equipment]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, return};
        let crDetails   = genChangeRequestDetails(description, flocs, equis);
        let* _          = AssetLib/S4/FileIO/UxlFile/XlsxWriter.writeChangeRequestDetails(crDetails);
        let* _          = outputS4Flocs(flocs);
        let* _          = outputS4Equipment(equis);
        return()
    


    pub def genChangeRequestDetails(description: String, flocs: List[S4Floc], equis: List[S4Equipment]): List[UxlChangeRequestDetails] = 
        let xs  = List.map(x -> genChangeRequestDetails1(x.functionalLocation, ""), flocs);
        let ys  = List.map(x -> genChangeRequestDetails1("", x.equiId), equis);
        updateFront(description, xs ::: ys)

    def genChangeRequestDetails1(floc: String, equiId: String): UxlChangeRequestDetails = 
        { description           = ""
        , changeRequestType     = ""
        , flFunctionalLocation  = floc
        , eqEquipment           = equiId
        , processRequester      = "ASSET DATA"
        }

    def updateFront(description: String, xs: List[UxlChangeRequestDetails]): List[UxlChangeRequestDetails] = 
        match xs { 
            case Nil => Nil
            case x1 :: rest => { 
                {description = description, changeRequestType = "AIWEAM0P" | x1} :: rest
            }
        }

    /// Functional Locations
    
    def outputS4Flocs(xs: List[S4Floc]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, return};
        let flocs       = List.map(x -> genUxlFunctionalLocationData(x.functionalLocation, x.attributes), xs);
        let* _          = AssetLib/S4/FileIO/UxlFile/XlsxWriter.writeFunctionalLocationData(flocs);
        let mltexts     = List.flatMap(x -> genUxlFlMultilingualText(x.functionalLocation, x.longText), xs);        
        let* _          = AssetLib/S4/FileIO/UxlFile/XlsxWriter.writeFlMultilingualText(mltexts);
        let classifs    = List.flatMap(x -> genUxlFlClassifications(x.functionalLocation, x.classifications), xs);        
        let* _          = AssetLib/S4/FileIO/UxlFile/XlsxWriter.writeFlClassification(classifs);
        return()


    def genUxlFunctionalLocationData(floc: String, attrs: FlocAttributes): UxlFunctionalLocationData = 
        { functionalLocation    = floc
        , maskedFuncLoc         = floc
        , description           = attrs.description
        , functLocCat           = Some(attrs.category)
        , strIndicator          = attrs.structureIndicator
        , objectType            = attrs.objectType
        , startupDate           = Some(attrs.startupDate)
        , maintPlant            = Some(2100)
        , companyCode           = Some(2100)
        , coArea                = Some(1000)
        , supFunctLoc           = attrs.superiorFloc
        , equipInstall          = attrs.equipmentInstall
        , statusProfile         = "ZFLOCST"
        , userStatus            = attrs.status 
        } 



    def genUxlFlMultilingualText(floc: String, oltext: Option[LongText]): List[UxlFlMultilingualText] = 
        match oltext {
            case Some(mltext) => {
                let v1 = { functionalLocation   = floc
                         , deleteIndicator      = false
                         , language             = "EN"
                         , description          = mltext.shortText
                         , longText             = mltext.longText
                         };
                v1 :: Nil
            }
            case None => Nil
        }
        
    def genUxlFlClassifications(floc: String, xs: List[Classification]): List[UxlFlClassification] =
        List.map(genUxlFlClassification1(floc), xs)

    def genUxlFlClassification1(floc: String, x: Classification): UxlFlClassification = 
        { functionalLocation    = floc
        , deletionInd           = false
        , classType             = "003"
        , className             = x.className
        , status                = "1"
        , characteristicName    = x.charName
        , charValue             = x.value
        , charDeletionInd       = false
        }


    /// Equipment
    
    def outputS4Equipment(xs: List[S4Equipment]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, return};
        let equis       = List.map(x -> genUxlEquipmentData(x.equiId, x.attributes), xs);
        let* _          = AssetLib/S4/FileIO/UxlFile/XlsxWriter.writeEquipmentData(equis);
        let mltexts     = List.flatMap(x -> genUxlEqMultilingualText(x.equiId, x.longText), xs);        
        let* _          = AssetLib/S4/FileIO/UxlFile/XlsxWriter.writeEqMultilingualText(mltexts);        
        let classifs    = List.flatMap(x -> genUxlEqClassifications(x.equiId, x.classifications), xs);        
        let* _          = AssetLib/S4/FileIO/UxlFile/XlsxWriter.writeEqClassification(classifs);
        return()

    def genUxlEquipmentData(equiId: String, attrs: EquiAttributes): UxlEquipmentData = 
        let f64None : Option[Float64] = None;       /// TODO this should be unnecessary, but it currently fixes a runtime cast error
        let i32None : Option[Int32] = None;       /// TODO this should be unnecessary, but it currently fixes a runtime cast error
        { equiId                = equiId
        , equipCategory         = attrs.category
        , description           = attrs.description
        , objectType            = attrs.objectType
        , grossWeight           = f64None
        , unitOfWeight          = ""
        , startupDate           = Some(attrs.startupDate)
        , manufacturer          = attrs.manufacturer
        , modelNumber           = attrs.model
        , manufPartNo           = attrs.partNumber
        , manufSerialNo         = attrs.serialNumber
        , constructYear         = Some(Time/LocalDate.getYear(attrs.startupDate))
        , constructMth          = Some(Time/LocalDate.getMonth(attrs.startupDate))
        , maintPlant            = Some(2100)
        , companyCode           = Some(2100)
        , coArea                = Some(1000)
        , planningPlant         = Some(2100)
        , functionalLoc         = attrs.functionalLocation
        , superordEquip         = ""
        , position              = i32None
        , techIdentNo           = ""
        , statusProfile         = "ZEQUIPST"
        , statusOfAnObject      = "OPER"
        }



    def genUxlEqMultilingualText(equiId: String, oltext: Option[LongText]): List[UxlEqMultilingualText] = 
        match oltext {
            case Some(mltext) => {
                let v1 = { equiId            = equiId
                         , deleteIndicator   = false
                         , language          = "EN"
                         , description       = mltext.shortText
                         , longText          = mltext.longText
                         };
                v1 :: Nil
            }
            case None => Nil
        }
        
    def genUxlEqClassifications(equiId: String, xs: List[Classification]): List[UxlEqClassification] = 
        List.map(genUxlEqClassification1(equiId), xs)

    def genUxlEqClassification1(equiId: String, x: Classification): UxlEqClassification = 
        { equiId                = equiId
        , deleteInd             = false
        , classType             = "002"
        , className             = x.className
        , status                = "1"
        , characteristicName    = x.charName
        , charValue             = x.value
        , charDeleteInd         = false
        }

}