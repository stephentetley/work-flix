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

namespace AssetLib/FileIO/PDT/XlsxReader {

    use SheetIO.SheetReader;
    use SheetIO.RowEvaluator;

    /// No headers - read all of the datasheet into a Map[String, String]
    pub def readFile(sheet: String, path: System.FilePath) : Result[Map[String, String], String] & Impure = 
        SheetIO/SheetReader.runXlsx(readPDT(sheet), path)

    def readPDT(sheet: String): SheetReader[Map[String, String]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, foldAllRows};      
        let* s1     = getSheetNamed(sheet);
        let* xs     = foldAllRows(s1, (ac, f) -> f(ac), Map.empty(), evalNameValueRow());
        return(xs)

    def evalNameValueRow(): RowEvaluator[Map[String, String] -> Map[String, String]]  =
        use SheetIO/RowEvaluator.{flatMap, return, getRowNum, getContentAt, getIsBoldAt};
        let* ix         = getRowNum();
        let* linename   = getContentAt(0);
        let* bold       = getIsBoldAt(0);
        let* value      = getContentAt(1);
        let name        = if (bold) "${ix}::${linename} ***** BOLD *****" else "${ix}::${linename}";
        if (String.isEmpty(name))
            return(km -> km)
        else 
            return(km -> Map.insert(name, value, km))

}
