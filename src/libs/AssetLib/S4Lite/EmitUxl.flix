/*
 * Copyright 2021 Stephen Tetley
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


namespace AssetLib/S4Lite/EmitUxl {

    use SheetIO.SheetWriter;

    use AssetLib/FileIO/S4/UxlFile/Datatypes.{ChangeRequestDetails, 
        FunctionalLocationData, FlMultilingualText, FlClassification, 
        EquipmentData, EqMultilingualText, EqClassification};
        
    use AssetLib/S4Lite/Datatypes.{UxlSource, SLFunctionalLocation, SLFlocLongText, SLFlocCharacteristic, 
        SLEquipment, SLEquiLongText, SLEquiCharacteristic};

    type alias UxlOutputArgs = 
        { uxlTemplate :: System.FilePath
        , changeRequestName :: String
        , outpath :: System.FilePath
        }

    pub def outputMocrUxl(args: UxlOutputArgs,
                        src: UxlSource): Result[Unit, String] & Impure = 
        SheetIO/SheetWriter.runTemplateXssf(writeMocrUxl(args.changeRequestName, src), args.uxlTemplate, args.outpath)


    def writeMocrUxl(changeRequestName: String, input: UxlSource): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, return, liftAction};
        let* src        = liftAction(_ -> AssetLib/S4Lite/Internal/FreshRenumber.equiRenumber(input));
        let flocs       = toFunctionalLocationData(src.funclocs);
        let flmltxts    = toFlMultilingualText(src.funclocLongTexts);
        let flchars     = toFlClassifications(src.funclocCharacteristics);
        let equis       = toEquipmentData(src.equipment);
        let* _          = liftAction(_ -> Console.printLine("**** flocs count: ${List.length(flocs)}, equi count: ${List.length(equis)}"));
        let eqmltxts    = toEqMultilingualText(src.equiLongTexts);
        let eqchars     = toEqClassifications(src.equiCharacteristics);
        let flocNames   = List.map(x -> x.functionalLocation, flocs);
        let equiNames   = List.map(x -> x.equiId, equis);
        let crInfo      = makeChangeRequestDetails(changeRequestName, flocNames, equiNames);
        let* _          = AssetLib/FileIO/S4/UxlFile/XlsxWriter.writeChangeRequestDetailsMocr(crInfo);
        let* _          = AssetLib/FileIO/S4/UxlFile/XlsxWriter.writeFunctionalLocationDataMocr(flocs);
        let* _          = AssetLib/FileIO/S4/UxlFile/XlsxWriter.writeFlMultilingualTextMocr(flmltxts);
        let* _          = AssetLib/FileIO/S4/UxlFile/XlsxWriter.writeFlClassificationMocr(flchars);
        let* _          = AssetLib/FileIO/S4/UxlFile/XlsxWriter.writeEquipmentDataMocr(equis);
        let* _          = AssetLib/FileIO/S4/UxlFile/XlsxWriter.writeEqMultilingualTextMocr(eqmltxts);
        let* _          = AssetLib/FileIO/S4/UxlFile/XlsxWriter.writeEqClassificationMocr(eqchars);
        return()


    def toFunctionalLocationData(xs: Chain[SLFunctionalLocation]): List[FunctionalLocationData] = 
        let sortStep = (x, y) -> Order.compare(x.functionalLocation, y.functionalLocation);
        xs 
            |> Chain.toList
            |> List.map(functionalLocationToUxl)
            |> List.sortWith(sortStep)


    def functionalLocationToUxl(x: SLFunctionalLocation): FunctionalLocationData = 
        let floc1 = x.funcloc;
        let floc = AssetLib/Base/S4/Floc.new(floc1) |> Result.toOption;
        let flocCategory = Option.getWithDefault(Option.map(AssetLib/Base/S4/Floc.level, floc), 0);
        let superiorFloc = Option.getWithDefault(Option.map(AssetLib/Base/S4/Floc.pop >> ToString.toString, floc), "");
        { functionalLocation    = floc1
        , maskedFuncLoc         = floc1
        , description           = x.description
        , functLocCat           = flocCategory
        , strIndicator          = x.structureIndicator
        , objectType            = x.objectType
        , startupDate           = x.startupDate
        , constructYear         = Time/LocalDate.getYear(x.startupDate)
        , constructMth          = Time/LocalDate.getMonthValue(x.startupDate)
        , maintPlant            = 2100
        , companyCode           = 2100
        , coArea                = 1000
        , planningPlant         = 2100          /// default: 2100
        , position              = x.position
        , supFunctLoc           = superiorFloc
        , equipInstall          = x.equipmentInstall
        , statusOfObject        = x.status
        }


    def toFlMultilingualText(xs: Chain[SLFlocLongText]): List[FlMultilingualText] = 
        let sortStep = (x, y) -> Order.compare(x.functionalLocation, y.functionalLocation);
        xs 
            |> Chain.toList
            |> List.map(funclocLongTextToUxl)
            |> List.sortWith(sortStep)

    def funclocLongTextToUxl(x: SLFlocLongText): FlMultilingualText = 
        { functionalLocation    = x.funcloc
        , deleteIndicator       = false
        , language              = "EN"
        , description           = x.description
        , longText              = x.longText
        }

    def toFlClassifications(xs: Chain[SLFlocCharacteristic]): List[FlClassification] = 
        let sortStep = (x, y) -> match Order.compare(x.functionalLocation, y.functionalLocation) { 
            case EqualTo => Order.compare(x.className, y.className)
            case ans => ans
        };
        xs 
            |> Chain.toList
            |> List.map(funclocCharacteristicToUxl)
            |> List.sortWith(sortStep)


    def funclocCharacteristicToUxl(x: SLFlocCharacteristic): FlClassification = 
        { functionalLocation    = x.funcloc
        , deletionInd           = false
        , classType             = "003"
        , className             = x.className
        , characteristicName    = x.charName
        , charValue             = x.charValue
        , charDeletionInd       = false
        }

    /// Basically emit superequi in order seen, then subequi. (This can be improved)
    def toEquipmentData(xs: Chain[SLEquipment]): List[EquipmentData] = 
        let isSuperEqui = x -> String.isEmpty(x.superOrdinateEqui);
        let (ys, zs) =   xs |> Chain.toList  |> List.partition(isSuperEqui);
        List.map(equipmentToUxl, ys ::: zs)

    def equipmentToUxl(x: SLEquipment): EquipmentData = 
        let unitOfWeight = match x.weightKg { 
            case Some(_) => "KG"
            case None => ""
        };
        { equiId            = x.equiId
        , equipCategory     = x.category
        , description       = x.description
        , validFrom         = x.validFrom
        , objectType        = x.objectType
        , grossWeight       = x.weightKg
        , unitOfWeight      = unitOfWeight
        , startupDate       = x.startupDate
        , manufacturer      = x.manufacturer
        , modelNumber       = x.model
        , manufPartNo       = x.partNumber
        , manufSerialNo     = x.serialNumber
        , constructYear     = Time/LocalDate.getYear(x.startupDate)
        , constructMth      = Time/LocalDate.getMonthValue(x.startupDate)
        , maintPlant        = 2100
        , workCenter        = "DEFAULT"
        , companyCode       = 2100
        , coArea            = 1000
        , planningPlant     = 2100
        , mainWorkCenter    = "DEFAULT"
        , plantWorkCenter   = 2100
        , functionalLoc     = x.functionalLocation
        , superordEquip     = x.superOrdinateEqui
        , position          = x.position
        , techIdentNo       = x.techIdentNo
        , statusProfile     = "ZEQUIPST"
        , statusOfAnObject  = x.status
        }


    def toEqMultilingualText(xs: Chain[SLEquiLongText]): List[EqMultilingualText] = 
        let sortStep = (x, y) -> Order.compare(x.equiId, y.equiId);
        xs 
            |> Chain.toList
            |> List.map(equiLongTextToUxl)
            |> List.sortWith(sortStep)

    def equiLongTextToUxl(x: SLEquiLongText): EqMultilingualText = 
        { equiId                = x.equiId
        , deleteIndicator       = false
        , language              = "EN"
        , description           = x.description
        , longText              = x.longText
        }


    def toEqClassifications(xs: Chain[SLEquiCharacteristic]): List[EqClassification] = 
        let sortStep = (x, y) -> match Order.compare(x.equiId, y.equiId) { 
            case EqualTo => Order.compare(x.className, y.className)
            case ans => ans
        };
        xs 
            |> Chain.toList
            |> List.map(equiCharacteristicToUxl)
            |> List.sortWith(sortStep)

    def equiCharacteristicToUxl(x: SLEquiCharacteristic): EqClassification = 
        { equiId                = x.equiId 
        , deleteInd             = false
        , classType             = "002"
        , className             = x.className
        , characteristicName    = x.charName
        , charValue             = x.charValue
        , charDeleteInd         = false
        }


    /// Front page "Change Request Details"

    def makeChangeRequestDetails(description: String, flocs: List[String], equiIds: List[String]): List[ChangeRequestDetails] = 
        let sorter = (x, y) -> Order.compare(x, y);
        let xs = flocs |> List.sortWith(sorter) |> List.map(makeFlocCR(description)); 
        let ys = equiIds |> List.sortWith(sorter) |> List.map(makeEquiCR(description)); 
        (xs ::: ys) |> coalesceCRDetails

    def makeFlocCR(description: String, floc: String): ChangeRequestDetails =         
        { description           = description
        , changeRequestType     = "AIWEAM0P"
        , flFunctionalLocation  = floc
        , eqEquipment           = ""
        , processRequester      = "ASSET DATA"
        }

    def makeEquiCR(description: String, equiId: String): ChangeRequestDetails =         
        { description           = description
        , changeRequestType     = "AIWEAM0P"
        , flFunctionalLocation  = ""
        , eqEquipment           = equiId
        , processRequester      = "ASSET DATA"
        }


    def coalesceCRDetails(xs: List[ChangeRequestDetails]): List[ChangeRequestDetails] = match xs {
        case x :: rs => coalesceCRDetailsHelper(x.description, x.changeRequestType, rs, ks -> x :: ks)
        case Nil => Nil
    }
        
    def coalesceCRDetailsHelper(description: String, 
                                changeRequestType : String, 
                                xs: List[ChangeRequestDetails], 
                                k: List[ChangeRequestDetails] -> List[ChangeRequestDetails]): List[ChangeRequestDetails] = 
        match xs {
            case x :: rs => { 
                if (x.description == description and x.changeRequestType == changeRequestType) { 
                    let x1 = { description = "", changeRequestType = "" | x};
                    coalesceCRDetailsHelper(description, changeRequestType, rs, ks -> k(x1 :: ks))
                } else 
                    coalesceCRDetailsHelper(description, changeRequestType, rs, ks -> k(x :: ks))
            }
            case Nil => k(Nil)        
        }                        


}
