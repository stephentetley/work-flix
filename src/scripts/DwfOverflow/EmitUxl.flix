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


    pub def outputUxl[r1, r2](changeItems: List[ChangeRequestDetails], 
                                flocs: #{ FlocDatum | r1 },
                                flocClasses: #{ Characteristic | r2 },
                                uxlTemplate: System.FilePath,
                                outpath: System.FilePath): Result[Unit, String] & Impure = 
        SheetIO/SheetWriter.runTemplateXssf(emitUxl(changeItems, flocs, flocClasses), uxlTemplate, outpath)

    /// Note - `changeItems` could easily be synthesized at this point...
    pub def emitUxl[r1, r2](changeItems: List[ChangeRequestDetails], 
                            flocs: #{ FlocDatum | r1 },
                            flocClasses: #{ Characteristic | r2 }): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, return};
        let* _      = AssetLib/S4/FileIO/UxlFile/XlsxWriter.writeChangeRequestDetails(changeItems);
        let xs      = DwfOverflow/Relations.toFunctionalLocationData(flocs);
        let* _      = AssetLib/S4/FileIO/UxlFile/XlsxWriter.writeFunctionalLocationData(xs);
        let ys      = DwfOverflow/Relations.toFlClassifications(flocClasses);
        let* _      = AssetLib/S4/FileIO/UxlFile/XlsxWriter.writeFlClassification(ys);
        return()


}
