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

namespace AssetLib/S4/FileIO/DownloadFile/Evaluate {

    use AssetLib/S4/FileIO/DownloadFile/Datatypes.{DownloadFile, DataRow, EntityData};
    use AssetLib/S4/FileIO/DownloadFile/Datatypes.DownloadFile.{DownloadFile};
    use AssetLib/S4/FileIO/DownloadFile/Datatypes.EntityData.{EntityData};
    use AssetLib/S4/FileIO/DownloadFile/Datatypes.Headers.{Headers};
    use AssetLib/S4/FileIO/DownloadFile/Datatypes.DataRow.{DataRow};
    use AssetLib/S4/FileIO/DownloadFile.RowEvaluator;
    use AssetLib/S4/FileIO/DownloadFile.RowEvaluator.{RowEvaluator};
    use AssetLib/S4/FileIO/DownloadFile/RowEvaluator.{makeHeaders};


    pub def toEntityData( headers: Array[String]
                        , eval: RowEvaluator[row]
                        , src: DownloadFile): Result[EntityData[row], System.Error] & Impure = 
        use Result.flatMap;
        let DownloadFile(x1) = src;
        let Headers(arr) = x1.headers;
        let oheaders = makeHeaders(arr);
        let* xs = Result.traverse(evalRow(eval, oheaders), x1.dataRows);
        Ok(EntityData({entityType = x1.fileHeader.entityType, headers = Headers(headers), dataRows = xs}))

    ///
    /// Specialized version of `toEntityData` all rows selected.
    ///
    pub def toEntityData1(src: DownloadFile): Result[EntityData[DataRow], System.Error] = 
        use Result.flatMap;
        let DownloadFile(x1) = src;
        Ok(EntityData({entityType = x1.fileHeader.entityType, headers = x1.headers, dataRows = x1.dataRows}))


    /// Import rows of a FileDownload
    /// Builds relations with in a List.
    pub def allRows(rowp: RowEvaluator[r], path: System.FilePath): Result[List[r], System.Error] & Impure = 
        use Result.flatMap;        
        let* ast = AssetLib/S4/FileIO/DownloadFile/Parser.parseFile(path);
        buildRows(rowp, ast)


    def buildRows(rowp: RowEvaluator[row], src: DownloadFile): Result[List[row], System.Error] & Impure = 
        use Result.flatMap;
        let DownloadFile(x1) = src;
        let Headers(arr) = x1.headers;
        let headers = makeHeaders(arr);
        let accumRow = (x, ac) -> 
            match evalRow(rowp, headers, x) {
                case Ok(r1) => Ok(r1 :: ac)
                case Err(e) => Err(e)
            };
        Result.foldRightM(accumRow, Nil,  x1.dataRows)

    def evalRow(rowp: RowEvaluator[row], headers: Map[String, Int32], row: DataRow): Result[row, System.Error] & Impure =  
        let RowEvaluator(f) = rowp;
        let DataRow(r1) = row;
        f(headers, r1)



    
}