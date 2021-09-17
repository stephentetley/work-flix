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



namespace Hierarchy/Loader {

    use SheetIO/Reader.{XlsxSource};
    use SheetIO.NamedRowEvaluator;

    type alias ExportRow = 
        { reference: String
        , commonName: String
        , installedFrom: Time.LocalDate
        }


    pub def loadExportRows(src: XlsxSource): Result[List[ExportRow], String] & Impure = 
        SheetIO/Reader.readAllNamedRows(src, evalExportRow())

    def evalExportRow(): NamedRowEvaluator[ExportRow] = 
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed, getLocalDateNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3) -> 
            { reference         = x1
            , commonName        = x2
            , installedFrom     = x3
            })
            <&> getTrimmedContentNamed("Reference")
            <*> getTrimmedContentNamed("Common Name")
            <*> getLocalDateNamed("Installed From")



}
