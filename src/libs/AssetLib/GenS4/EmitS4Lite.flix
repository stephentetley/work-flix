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


namespace AssetLib/GenS4/EmitS4Lite {

    use SheetIO.SheetWriter;

    use AssetLib/FileIO/S4/UxlFile/Datatypes.{UxlSource, ChangeRequestDetails, 
        FunctionalLocationData, FlMultilingualText, FlClassification, 
        EquipmentData, EqMultilingualText, EqClassification};

    use AssetLib/GenS4/UxlRelations.{FlocDatum, FlocLongText, FlocCharacteristic, 
        EquiDatum, EquiLongText, EquiCharacteristic};


    pub def outputUxl(changeRequestName: String,
                        solutions: #{FlocDatum, FlocLongText, FlocCharacteristic, 
                                    EquiDatum, EquiLongText, EquiCharacteristic | r},
                        uxlTemplate: System.FilePath,
                        outpath: System.FilePath): Result[Unit, String] & Impure = 
        SheetIO/SheetWriter.runTemplateXssf(emitUxl(changeRequestName, solutions), uxlTemplate, outpath)


    def emitUxl(changeRequestName: String,
                solutions: #{FlocDatum, FlocLongText, FlocCharacteristic, 
                            EquiDatum, EquiLongText, EquiCharacteristic | r}): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, return, liftAction};
        let* flocs      = liftAction(_ -> AssetLib/GenS4/UxlRelations.toFunctionalLocationData(solutions));
        let* flmltxts   = liftAction(_ -> AssetLib/GenS4/UxlRelations.toFlMultilingualText(solutions));
        let* flchars    = liftAction(_ -> AssetLib/GenS4/UxlRelations.toFlClassifications(solutions));
        let* equis      = liftAction(_ -> AssetLib/GenS4/UxlRelations.toEquipmentData(solutions));
        let* eqmltxts   = liftAction(_ -> AssetLib/GenS4/UxlRelations.toEqMultilingualText(solutions));
        let* eqchars    = liftAction(_ -> AssetLib/GenS4/UxlRelations.toEqClassifications(solutions));
        let* _          = liftAction(_ -> Console.printLine("**** equi count: ${List.length(equis)}"));
        let* (equis1, eqmltxts1, eqchar1s) = liftAction(_ -> AssetLib/GenS4/Internal/Renumber.renumber(equis, eqmltxts, eqchars));
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




    def makeChangeRequestDetails(description: String, flocs: List[String], equiIds: List[String]): List[ChangeRequestDetails] = 
        let sorter = (x, y) -> Order.compare(x, y) |> Comparison.toInt;
        let xs = flocs |> List.sortWith(sorter) |> List.map(makeFlocCR(description)); 
        let ys = equiIds |> List.sortWith(sorter) |> List.map(makeEquiCR(description)); 
        (xs ::: ys) |> coalesce

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


    def coalesce(xs: List[ChangeRequestDetails]): List[ChangeRequestDetails] = match xs {
        case x :: rs => coalesceHelper(x.description, x.changeRequestType, rs, ks -> x :: ks)
        case Nil => Nil
    }
        
    def coalesceHelper(description: String, 
                        changeRequestType : String, 
                        xs: List[ChangeRequestDetails], 
                        k: List[ChangeRequestDetails] -> List[ChangeRequestDetails]): List[ChangeRequestDetails] = 
        match xs {
            case x :: rs => { 
                if (x.description == description and x.changeRequestType == changeRequestType) { 
                    let x1 = { description = "", changeRequestType = "" | x};
                    coalesceHelper(description, changeRequestType, rs, ks -> k(x1 :: ks))
                } else 
                    coalesceHelper(description, changeRequestType, rs, ks -> k(x :: ks))
            }
            case Nil => k(Nil)        
        }                        



}
