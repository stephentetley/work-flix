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

namespace AssetLib/S4/FileIO/TransferFile/Evaluate {

    use AssetLib/S4/FileIO/TransferFile/Datatypes.{TransferFile, DataRow, EntityData};
    use AssetLib/S4/FileIO/TransferFile.RowEvaluator;
    use AssetLib/S4/FileIO/TransferFile.RowEvaluator.{RowEvaluator};
    use AssetLib/S4/FileIO/TransferFile/RowEvaluator.{makeHeaders};


    pub def toEntityData( outputHeaders: Array[String]
                        , eval: RowEvaluator[row]
                        , x: TransferFile): Result[EntityData[row], String] & Impure = 
        use Result.flatMap;
        let oheaders = makeHeaders(x.headers);
        let* xs = Result.traverse(evalRow(eval, oheaders), x.dataRows);
        Ok({entityType = x.fileHeader.entityType, headers = outputHeaders, dataRows = xs})

    ///
    /// Specialized version of `toEntityData` all rows selected.
    ///
    pub def toEntityData1(x: TransferFile): Result[EntityData[DataRow], String] = 
        Ok({entityType = x.fileHeader.entityType, headers = x.headers, dataRows = x.dataRows})


    /// Import rows of a FileDownload
    /// Builds relations from the List.
    pub def allRows(rowp: RowEvaluator[r], path: System.FilePath): Result[List[r], String] & Impure = 
        use Result.flatMap;        
        let* ast = AssetLib/S4/FileIO/TransferFile/Parser.parseFile(path);
        buildRows(rowp, ast)


    def buildRows(rowp: RowEvaluator[row], x: TransferFile): Result[List[row], String] & Impure = 
        use Result.flatMap;
        let headers = makeHeaders(x.headers);
        let accumRow = (x1, ac) -> 
            match evalRow(rowp, headers, x1) {
                case Ok(r1) => Ok(r1 :: ac)
                case Err(e) => Err(e)
            };
        Result.foldRightM(accumRow, Nil,  x.dataRows)

    def evalRow(rowp: RowEvaluator[row], headers: Map[String, Int32], row: DataRow): Result[row, String] & Impure =  
        let RowEvaluator(f) = rowp;
        f(headers, row)



    
}