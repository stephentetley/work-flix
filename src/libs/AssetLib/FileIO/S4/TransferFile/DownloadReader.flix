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

namespace AssetLib/FileIO/S4/TransferFile/DownloadReader {

    use AssetLib/FileIO/S4/TransferFile/Datatypes.{TransferFile, DataRow, EntityType, Headers};
    use AssetLib/FileIO/S4/TransferFile.DownloadRowEvaluator;
    use AssetLib/FileIO/S4/TransferFile.DownloadRowEvaluator.{DownloadRowEvaluator};
    use AssetLib/FileIO/S4/TransferFile/DownloadRowEvaluator.{makeHeaders};




    /// Import rows of a FileDownload
    /// Builds relations from the List.
    pub def readAllRows(rowp: DownloadRowEvaluator[r], path: System.FilePath): Result[List[r], String] & Impure = 
        use Result.flatMap;        
        let* ast = AssetLib/FileIO/S4/TransferFile/Parser.parseFile(path);
        buildRows(rowp, ast)


    def buildRows(rowp: DownloadRowEvaluator[row], x: TransferFile): Result[List[row], String] & Impure = 
        use Result.flatMap;
        let headers = makeHeaders(x.headers);
        let accumRow = (x1, ac) -> 
            match evalRow(rowp, headers, x1) {
                case Ok(r1) => Ok(r1 :: ac)
                case Err(e) => Err(e)
            };
        Result.foldRightM(accumRow, Nil,  x.dataRows)

    def evalRow(rowp: DownloadRowEvaluator[row], headers: Map[String, Int32], row: DataRow): Result[row, String] & Impure =  
        let DownloadRowEvaluator(f) = rowp;
        f(headers, row)
    
}
