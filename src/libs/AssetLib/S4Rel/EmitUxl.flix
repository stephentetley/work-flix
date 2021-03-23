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


namespace AssetLib/S4Rel/EmitUxl {

    use SheetIO.SheetWriter;

    use AssetLib/S4/FileIO/UxlFile/Datatypes.{ChangeRequestDetails, FunctionalLocationData, FlClassification};
    use AssetLib/S4Rel/Relations.{FlocDatum, FlocLongText, FlocCharacteristic};

    /// TODO include Equi...

    pub def outputUxl[r](changeRequestName: String,
                            solutions: #{FlocDatum, FlocCharacteristic | r},
                            uxlTemplate: System.FilePath,
                            outpath: System.FilePath): Result[Unit, String] & Impure = 
        SheetIO/SheetWriter.runTemplateXssf(emitUxl(changeRequestName, solutions), uxlTemplate, outpath)


    pub def emitUxl[r](changeRequestName: String,
                        solutions: #{FlocDatum, FlocCharacteristic | r}): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, return};
        let xs      = AssetLib/S4Rel/Relations.toFunctionalLocationData(solutions);
        let crs     = makeChangeRequestDetails(changeRequestName, List.map(x -> x.functionalLocation, xs), Nil);
        let* _      = AssetLib/S4/FileIO/UxlFile/XlsxWriter.writeChangeRequestDetails(crs);        
        let* _      = AssetLib/S4/FileIO/UxlFile/XlsxWriter.writeFunctionalLocationData(xs);
        let ys      = AssetLib/S4Rel/Relations.toFlClassifications(solutions);
        let* _      = AssetLib/S4/FileIO/UxlFile/XlsxWriter.writeFlClassification(ys);
        return()




    def makeChangeRequestDetails(description: String, flocs: List[String], equiIds: List[String]): List[ChangeRequestDetails] = 
        let sorter = (x, y) -> Order.compare(x, y) |> Order.toInt;
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
