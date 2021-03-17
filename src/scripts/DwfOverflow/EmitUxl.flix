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


namespace DwfOverflow/EmitUxl {

    use SheetIO.SheetWriter;

    use AssetLib/S4/FileIO/UxlFile/Datatypes.{ChangeRequestDetails, FunctionalLocationData, FlClassification};
    use DwfOverflow/Relations.{ChangeRequestItem, FlocDatum, Characteristic};

    /// TODO add version for Flocs and Equi...

    pub def outputNewFlocsUxl[r1, r2](changeRequestName: String,
                                        flocs: #{ FlocDatum | r1 },
                                        flocClasses: #{ Characteristic | r2 },
                                        uxlTemplate: System.FilePath,
                                        outpath: System.FilePath): Result[Unit, String] & Impure = 
        SheetIO/SheetWriter.runTemplateXssf(emitNewFlocsUxl(changeRequestName, flocs, flocClasses), uxlTemplate, outpath)


    pub def emitNewFlocsUxl[r1, r2](changeRequestName: String,
                            flocs: #{ FlocDatum | r1 },
                            flocClasses: #{ Characteristic | r2 }): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, return};
        let xs      = DwfOverflow/Relations.toFunctionalLocationData(flocs);
        let crs     = makeChangeRequestDetails(changeRequestName, List.map(x -> x.functionalLocation, xs), Nil);
        let* _      = AssetLib/S4/FileIO/UxlFile/XlsxWriter.writeChangeRequestDetails(crs);        
        let* _      = AssetLib/S4/FileIO/UxlFile/XlsxWriter.writeFunctionalLocationData(xs);
        let ys      = DwfOverflow/Relations.toFlClassifications(flocClasses);
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


    /// def changeRequestDetailsSortStep(x: ChangeRequestDetails, y: ChangeRequestDetails): Int32 = 
    ///     let xkey = if (not String.isEmpty(x.flFunctionalLocation)) "A:{x.flFunctionalLocation}" else "Z:{$x.eqEquipment}";
    ///     let ykey = if (not String.isEmpty(y.flFunctionalLocation)) "A:{y.flFunctionalLocation}" else "Z:{$y.eqEquipment}";
    ///     Order.compare(xkey, ykey) |> Order.toInt

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
