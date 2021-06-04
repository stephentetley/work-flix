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
        
    use AssetLib/S4Lite/Datatypes.{UxlSource, FunctionalLocation, FlocLongText, FlocCharacteristic, 
        Equipment, EquiLongText, EquiCharacteristic};

    type alias UxlOutputArgs = 
        { uxlTemplate: System.FilePath
        , changeRequestName: String
        , outpath: System.FilePath
        }

    pub def outputUxl(src: UxlSource,
                      args: UxlOutputArgs): Result[Unit, String] & Impure = 
        SheetIO/SheetWriter.runTemplateXssf(writeUxl(args.changeRequestName, src), args.uxlTemplate, args.outpath)


    def writeUxl(changeRequestName: String, input: UxlSource): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, return, liftAction};
        let flocs       = toFunctionalLocationData(input.funclocs);
        let flmltxts    = toFlMultilingualText(input.funclocLongTexts);
        let flchars     = toFlClassifications(input.funclocCharacteristics);
        let equis       = toEquipmentData(input.equipment);
        let eqmltxts    = toEqMultilingualText(input.equiLongTexts);
        let eqchars     = toEqClassifications(input.equiCharacteristics);
        let* _          = liftAction(_ -> Console.printLine("**** equi count: ${List.length(equis)}"));
        let* (equis1, eqmltxts1, eqchar1s) = liftAction(_ -> AssetLib/S4Lite/Internal/Renumber.renumber(equis, eqmltxts, eqchars));
        let flocNames   = List.map(x -> x.functionalLocation, flocs);
        let equiNames   = List.map(x -> x.equiId, equis1);
        let crs         = makeChangeRequestDetails(changeRequestName, flocNames, equiNames);
        let* _          = AssetLib/FileIO/S4/UxlFile/XlsxWriter.writeChangeRequestDetails(crs);
        let* _          = AssetLib/FileIO/S4/UxlFile/XlsxWriter.writeFunctionalLocationData(flocs);
        let* _          = AssetLib/FileIO/S4/UxlFile/XlsxWriter.writeFlMultilingualText(flmltxts);
        let* _          = AssetLib/FileIO/S4/UxlFile/XlsxWriter.writeFlClassification(flchars);
        let* _          = AssetLib/FileIO/S4/UxlFile/XlsxWriter.writeEquipmentData(equis1);
        let* _          = AssetLib/FileIO/S4/UxlFile/XlsxWriter.writeEqMultilingualText(eqmltxts1);
        let* _          = AssetLib/FileIO/S4/UxlFile/XlsxWriter.writeEqClassification(eqchar1s);
        return()


    def toFunctionalLocationData(xs: List[FunctionalLocation]): List[FunctionalLocationData] = 
        let sortStep = (x, y) -> Order.compare(x.functionalLocation, y.functionalLocation) |> Comparison.toInt;
        xs 
            |> List.map(functionalLocationToUxl)
            |> List.sortWith(sortStep)


    def functionalLocationToUxl(x: FunctionalLocation): FunctionalLocationData = 
        let floc1 = x.funcloc;
        let flocCategory = Option.getWithDefault(Option.map(AssetLib/Base/S4/Floc.level, AssetLib/Base/S4/Floc.new(floc1)), 0);
        let superiorFloc = Option.getWithDefault(Option.map(AssetLib/Base/S4/Floc.pop >> ToString.toString, AssetLib/Base/S4/Floc.new(floc1)), "");
        { functionalLocation    = floc1
        , maskedFuncLoc         = floc1
        , description           = x.description
        , functLocCat           = flocCategory
        , strIndicator          = x.structureIndicator
        , objectType            = x.objectType
        , startupDate           = x.startupDate
        , maintPlant            = 2100
        , workCenter            = "DEFAULT"
        , companyCode           = 2100
        , coArea                = 1000
        , mainWorkCenter        = "DEFAULT"     /// default: DEFAULT
        , plantWorkCenter       = 2100          /// default: 2100
        , supFunctLoc           = superiorFloc
        , equipInstall          = x.equipmentInstall
        , statusProfile         = "ZEQUIPST"
        , userStatus            = x.status
        }


    def toFlMultilingualText(xs: List[FlocLongText]): List[FlMultilingualText] = 
        let sortStep = (x, y) -> Order.compare(x.functionalLocation, y.functionalLocation) |> Comparison.toInt;
        xs 
            |> List.map(funclocLongTextToUxl)
            |> List.sortWith(sortStep)

    def funclocLongTextToUxl(x: FlocLongText): FlMultilingualText = 
        { functionalLocation    = x.funcloc
        , deleteIndicator       = false
        , language              = "EN"
        , description           = x.description
        , longText              = x.longText
        }

    def toFlClassifications(xs: List[FlocCharacteristic]): List[FlClassification] = 
        let sortStep = (x, y) -> match Order.compare(x.functionalLocation, y.functionalLocation) { 
            case EqualTo => Order.compare(x.className, y.className) |> Comparison.toInt
            case ans => Comparison.toInt(ans)
        };
        xs 
            |> List.map(funclocCharacteristicToUxl)
            |> List.sortWith(sortStep)


    def funclocCharacteristicToUxl(x: FlocCharacteristic): FlClassification = 
        { functionalLocation    = x.funcloc
        , deletionInd           = false
        , classType             = "003"
        , className             = x.className
        , status                = "1"
        , characteristicName    = x.charName
        , charValue             = x.charValue
        , charDeletionInd       = false
        }

    def toEquipmentData(xs: List[Equipment]): List[EquipmentData] = 
        let sortStep = (x, y) -> match Order.compare(x.functionalLoc, y.functionalLoc) { 
            case EqualTo => match Order.compare(x.superordEquip, y.superordEquip) {
                case EqualTo => Order.compare(x.description, y.description) |> Comparison.toInt
                case ans => Comparison.toInt(ans)    
            }                
            case ans => Comparison.toInt(ans)
        };
        xs 
            |> List.map(equipmentToUxl)
            |> List.sortWith(sortStep)

    def equipmentToUxl(x: Equipment): EquipmentData = 
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


    def toEqMultilingualText(xs: List[EquiLongText]): List[EqMultilingualText] = 
        let sortStep = (x, y) -> Order.compare(x.equiId, y.equiId) |> Comparison.toInt;
        xs 
            |> List.map(equiLongTextToUxl)
            |> List.sortWith(sortStep)

    def equiLongTextToUxl(x: EquiLongText): EqMultilingualText = 
        { equiId                = x.equiId
        , deleteIndicator       = false
        , language              = "EN"
        , description           = x.description
        , longText              = x.longText
        }


    def toEqClassifications(xs: List[EquiCharacteristic]): List[EqClassification] = 
        let sortStep = (x, y) -> match Order.compare(x.equiId, y.equiId) { 
            case EqualTo => Order.compare(x.className, y.className) |> Comparison.toInt
            case ans => Comparison.toInt(ans)
        };
        xs 
            |> List.map(equiCharacteristicToUxl)
            |> List.sortWith(sortStep)

    def equiCharacteristicToUxl(x: EquiCharacteristic): EqClassification = 
        { equiId                = x.equiId 
        , deleteInd             = false
        , classType             = "002"
        , className             = x.className
        , status                = "1"
        , characteristicName    = x.charName
        , charValue             = x.charValue
        , charDeleteInd         = false
        }


    /// Front page "Change Request Details"

    def makeChangeRequestDetails(description: String, flocs: List[String], equiIds: List[String]): List[ChangeRequestDetails] = 
        let sorter = (x, y) -> Order.compare(x, y) |> Comparison.toInt;
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
