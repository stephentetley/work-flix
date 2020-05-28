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

use FactIO.CsvFormat;
use FactIO.CsvRowEvaluator;

use LiftingReport/Relations.{EquiMatch, MemoLine, EquipmentInfo};
use LiftingReport/Common.{parseAI2Date, getQuotedNames};

namespace LiftingReport/CsvLoader {
    

    /// ## Equipment `rules`


    def readEquiMatch1[r](): CsvRowEvaluator[#{ EquiMatch | r}] =
        use FactIO/CsvRowEvaluator.{flatMap, return, map, getStringByLabel, liftResult};
        let* aiName         = getStringByLabel("AI2 Equi Type");
        let* containsList   = getStringByLabel("Name Contains") |> map(getQuotedNames);
        let* s4ObjType      = getStringByLabel("Object Type");
        let* s4Class        = getStringByLabel("Classification");
        let* s1             = getStringByLabel("Fixed or Portable");
        let* fop            = liftResult(LiftingReport/Relations.readFixedOrPortable(s1));
        return( EquiMatch(aiName, containsList, s4ObjType, s4Class, fop). )


    pub def importEquiMatches[r](path: String): Result[#{ EquiMatch | r }, System.Error] & Impure =    
        use Result.flatMap;
        let* src = FactIO/CsvImport.newCsvStreamWithBOM(path, Text/Charset.utf_8(), true);
        FactIO/CsvImport.importRows(readEquiMatch1(), src)

    /// ## Equi info - serial number, etc.

    /// Read an AI2 file (saved as to Csv from Xlsx)

    def readEquipmentInfo1[r](ix: Int32): CsvRowEvaluator[#{ EquipmentInfo | r }] =
        use FactIO/CsvRowEvaluator.{flatMap, return, getStringByLabel, getInt32ByLabel, liftResult};
        let* pli            = getStringByLabel("Reference");
        let* name           = getStringByLabel("Common Name");
        let* sdate          = getStringByLabel("Installed From");
        let* date           = liftResult(parseAI2Date(sdate) |> Result.mapErr(_ -> System/Error.Generic("parseDate")));
        let* manuf          = getStringByLabel("Manufacturer");
        let* model          = getStringByLabel("Model");
        let* specificModel  = getStringByLabel("Specific Model/Frame");
        let* serialNum      = getStringByLabel("Serial No");
        let* locnOnSite     = getStringByLabel("Location On Site");        
        let* workLoad       = getInt32ByLabel("Work Load");
        let* workLoadU      = getStringByLabel("Work Load Units");
        let* ywref          = getStringByLabel("YWRef");
        let* testCert       = getStringByLabel("Test Cert No");
        return( EquipmentInfo(ix+ 1, pli, name, date, manuf, model, specificModel, serialNum, locnOnSite, 
                            workLoad, workLoadU, ywref, testCert). )

    pub def importEquipmentInfo[r](path: String): Result[#{ EquipmentInfo | r }, System.Error] & Impure =    
        use Result.flatMap;
        let* src = FactIO/CsvImport.newCsvStreamWithBOM(path, Text/Charset.utf_8(), true);
        FactIO/CsvImport.importRowsWithCount(readEquipmentInfo1, src)

    /// ## Memo Lines

    /// Read an AI2 file (saved as to Csv from Xlsx) for memo lines

    def makeMemoLine[r](pli: String,  memos: List[String]): #{ MemoLine | r } = 
        let xs = List.filter(s -> s != "", memos);
        let text = String.intercalate(". ", xs);
        MemoLine(pli, text).

    def readMemoLine1[r](): CsvRowEvaluator[#{ MemoLine | r }] = 
        use FactIO/CsvRowEvaluator.{flatMap, return, getStringByLabel};
        let* pli    = getStringByLabel("Reference");
        let* m1     = getStringByLabel("Memo Line 1");
        let* m2     = getStringByLabel("Memo Line 2");
        let* m3     = getStringByLabel("Memo Line 3");      
        let* m4     = getStringByLabel("Memo Line 4");
        let* m5     = getStringByLabel("Memo Line 5");
        let ans     = makeMemoLine(pli, m1 :: m2 :: m3 :: m4 :: m5 :: Nil);
        return(ans)

    pub def importMemoLines[r](path: String): Result[#{ MemoLine | r }, System.Error] & Impure =    
        use Result.flatMap;
        let* src = FactIO/CsvImport.newCsvStreamWithBOM(path, Text/Charset.utf_8(), true);
        FactIO/CsvImport.importRows(readMemoLine1(), src)

        
}