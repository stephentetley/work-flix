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

namespace AssetLib/FileIO/PDT/Reader {

    use SheetIO.Sheet;
    use SheetIO.SheetReader;
    use SheetIO.RowEvaluator;

    pub type alias PDTRow = 
        { rowNumber :: Int32
        , rowName :: String
        , cellValues :: List[String]
        }

    pub def getDataSheet(): SheetReader[Sheet] = 
        use SheetIO/SheetReader.{flatMap, getSheetNames, getSheetNamed, liftOption};
        let* xs     = getSheetNames();
        let* name   = liftOption(List.find(String.startsWith(prefix ="PDT_"), xs), "Could not find PDT datasheet");
        getSheetNamed(name)

    pub def readDataSheet(sheet1: Sheet): SheetReader[List[PDTRow]] = 
        SheetIO/SheetReader.someRows(SheetIO/RowEvaluator.optional(evalPDTRow()), sheet1)
        

    def evalPDTRow(): RowEvaluator[PDTRow] = 
        use SheetIO/RowEvaluator.{flatMap, point, getRowContents, getRowNum, liftAction, throwError};
        let* arr    = getRowContents();
        let sz      = Array.length(arr);
        if (sz < 2)
            throwError("evalPDTRow - row is missing content")
        else {
            let* ix     = getRowNum();
            let* name   = liftAction(_ -> arr[0]);
            let* vs     = liftAction(_ -> Array.toList(arr) |> List.drop(1));
            point({rowNumber = ix, rowName = name, cellValues = vs})
        }


}
