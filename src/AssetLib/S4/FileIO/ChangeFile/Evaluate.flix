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




use TextParser.RowWithHeadersParser;
use TextParser.RowWithHeadersParser.{RowWithHeadersParser};
use TextParser/RowWithHeadersParser.{makeHeaders};

use AssetLib/S4/FileIO/ChangeFile/Datatypes.{ChangeFile, DataRow};
use AssetLib/S4/FileIO/ChangeFile/Datatypes.ChangeFile.{ChangeFile};
use AssetLib/S4/FileIO/ChangeFile/Datatypes.Headers.{Headers};
use AssetLib/S4/FileIO/ChangeFile/Datatypes.DataRow.{DataRow};

namespace AssetLib/S4/FileIO/ChangeFile/Evaluate {


    pub def transform(rowp: RowWithHeadersParser[row], src: ChangeFile[DataRow]): Result[ChangeFile[row], System.Error] & Impure = 
        use Result.flatMap;
        let ChangeFile(x1) = src;
        let Headers(arr) = x1.headers;
        let headers = makeHeaders(arr);
        let* xs = Result.traverse(evalRow(rowp, headers), x1.dataRows);
        Ok(ChangeFile({dataRows = xs | x1}))


    pub def evaluate(rowp: RowWithHeadersParser[row], src: ChangeFile[DataRow]): Result[List[row], System.Error] & Impure = 
        use Result.flatMap;
        let ChangeFile(x1) = src;
        let Headers(arr) = x1.headers;
        let headers = makeHeaders(arr);
        Result.traverse(evalRow(rowp, headers), x1.dataRows)


    pub def evaluateRelations(rowp: RowWithHeadersParser[reln], src: ChangeFile[DataRow]): Result[reln, System.Error] & Impure = 
        use Result.flatMap;
        let ChangeFile(x1) = src;
        let Headers(arr) = x1.headers;
        let headers = makeHeaders(arr);
        let accumRow = (ac, x) -> 
            match evalRow(rowp, headers, x) {
                case Ok(r1) => Ok(ac <+> r1)
                case Err(e) => Err(e)
            };
        Result.foldLeftM(accumRow, #{ },  x1.dataRows)

    def evalRow(rowp: RowWithHeadersParser[row], headers: Map[String, Int32], row: DataRow): Result[row, System.Error] & Impure =  
        let RowWithHeadersParser(f) = rowp;
        let DataRow(r1) = row;
        f(headers, r1)

 
    pub def importRows(rowp: RowWithHeadersParser[reln], path: System.FilePath): Result[reln, System.Error] & Impure = 
        use Result.flatMap;        
        let* ast = AssetLib/S4/FileIO/ChangeFile/Parser.parseFile(path);
        evaluateRelations(rowp, ast)

    
}