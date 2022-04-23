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

namespace AssetLib/FileIO/Aib/AideChangeSummary/XlsxReader {

    use FlixSandbox/System.FilePath;
    use SheetIO.SheetReader;
    use SheetIO.NamedRowEvaluator;

    use AssetLib/FileIO/Aib/AideChangeSummary/Datatypes.AibExportRow;

    pub def readFile(path: FilePath) : Result[List[AibExportRow], String] & Impure = 
        SheetIO/SheetReader.runXlsx(readAideChanges(), path)

    def readAideChanges(): SheetReader[List[AibExportRow]] = 
        use SheetIO/SheetReader.{flatMap, point, getSheetNamed, allNamedRows};      
        let* s1     = getSheetNamed("Sheet1");
        let* xs     = allNamedRows(evalAibExportRow(), s1);
        point(xs)


    // Change,Reference,Asset Name,OldParentName,NewParentName
    def evalAibExportRow(): NamedRowEvaluator[AibExportRow] = 
        use SheetIO/NamedRowEvaluator.{flatMap, point, getStringNamed, getStringNamedWithDefault};
        let* s0     = getStringNamed("Change");
        let* s1     = getStringNamed("Reference");
        let* s2     = getStringNamedWithDefault("Asset Name", "");
        let* s3     = getStringNamedWithDefault("OldParentName", "");
        let* s4     = getStringNamedWithDefault("NewParentName", "");
        point( { change = s0
                , reference = s1
                , assetName = s2
                , oldParentName = s3
                , newParentName = s4
                } )

    /// def logged(name: String, ma: NamedRowEvaluator[String]): NamedRowEvaluator[String] = 
    ///     use SheetIO/NamedRowEvaluator.{flatMap, point, liftAction};
    ///     let* ans = ma;
    ///     let* _ = liftAction(_ -> println("${name}: ${ans}"));
    ///     point(ans)

}



