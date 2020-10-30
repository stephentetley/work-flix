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
        , EquipmentData => UxlEquipmentData
        , EqMultilingualText => UxlEqMultilingualText
        , EqClassification => UxlEqClassification};

    use AssetLib/S4/Simple/Datatypes.{S4Equipment, EquiAttributes, LongText, Classification};


    pub def outputS4Equipment(description: String, xs: List[S4Equipment]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, return};
        let crDetails   = genChangeRequestDetails(description, xs);
        let* _          = AssetLib/S4/FileIO/UxlFile/XlsxWriter.writeChangeRequestDetails(crDetails);
        let equis       = List.map(x -> genEquipmentData(x.equiId, x.attributes), xs);
        let* _          = AssetLib/S4/FileIO/UxlFile/XlsxWriter.writeEquipmentData(equis);
        let mltexts     = List.flatMap(x -> genEqMultilingualText(x.equiId, x.longText), xs);        
        let* _          = AssetLib/S4/FileIO/UxlFile/XlsxWriter.writeEqMultilingualText(mltexts);        
        let classifs    = List.flatMap(x -> genEqClassifications(x.equiId, x.classifications), xs);        
        let* _          = AssetLib/S4/FileIO/UxlFile/XlsxWriter.writeEqClassification(classifs);
        return()
        


    pub def genChangeRequestDetails(description: String, xs: List[S4Equipment]): List[UxlChangeRequestDetails] = 
        let fn = (r1, ix) -> genChangeRequestDetails1(description, r1.equiId, ix < 1);
        List.mapWithIndex(fn, xs)

    def genChangeRequestDetails1(description: String, equiId: String, initial: Bool): UxlChangeRequestDetails = 
        { description           = if (initial) description else ""
        , changeRequestType     = if (initial) "AIWEAM0P" else ""
        , flFunctionalLocation  = ""
        , eqEquipment           = equiId
        , processRequester      = "ASSET DATA"
        }

    def genEquipmentData(equiId: String, attrs: EquiAttributes): UxlEquipmentData = 
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
        , constructYear         = Time/LocalDate.getYear(attrs.startupDate)
        , constructMth          = Time/LocalDate.getMonth(attrs.startupDate)
        , maintPlant            = 2100
        , companyCode           = 2100
        , coArea                = 1000
        , planningPlant         = 2100
        , functionalLoc         = attrs.functionalLocation
        , superordEquip         = ""
        , position              = i32None
        , techIdentNo           = ""
        , statusProfile         = "ZEQUIPST"
        , statusOfAnObject      = "OPER"
        }



    def genEqMultilingualText(equiId: String, oltext: Option[LongText]): List[UxlEqMultilingualText] = 
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
        
    def genEqClassifications(equiId: String, xs: List[Classification]): List[UxlEqClassification] = 
        List.map(genEqClassification1(equiId), xs)

    def genEqClassification1(equiId: String, x: Classification): UxlEqClassification = 
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