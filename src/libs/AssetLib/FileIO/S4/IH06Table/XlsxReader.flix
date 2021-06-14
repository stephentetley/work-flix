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


namespace AssetLib/FileIO/S4/IH06Table/XlsxReader {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;

    use AssetLib/FileIO/S4/IH06Table/Datatypes.{IH06Row};

    pub def readIH06File(path: System.FilePath): Result[List[IH06Row], String] & Impure =    
        SheetIO/SheetReader.runXlsx(readIH06Sheet(), path)

    pub def readIH06Sheet(): SheetReader[List[IH06Row]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, allNamedRows};      
        let* s1     = getSheetNamed("Sheet1");
        let* xs     = allNamedRows(s1, evalIH06Row());
        return(xs)


    def evalIH06Row(): NamedRowEvaluator[IH06Row] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, optional, getContentNamed, getInt32Named, getInt64Named};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7) -> 
                { floc              = x1
                , description       = x2
                , planningPlant     = x3
                , costCenter        = x4
                , costCenterOrigin  = x5
                , userStatus        = x6
                , objectType        = x7
                })
            <&> getContentNamed("Functional Loc.")
            <*> getContentNamed("Description")
            <*> getInt32StoredAsTextNamed("Planning Plant")
            <*> optional(getInt32StoredAsTextNamed("Cost Center"))
            <*> getContentNamed("CCtr orig.")
            <*> getContentNamed("User status")
            <*> getContentNamed("Object Type")


    /// Candidate for SheetIO...
    def getInt32StoredAsTextNamed(label: String): NamedRowEvaluator[Int32] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, getContentNamed, throwError};
        let* s1      = getContentNamed(label);
        match Int32.fromString(s1) {
            case Ok(i)  => return(i)
            case Err(_) => throwError("getInt32StoredAsTextNamed('${label}')")
        }

}
