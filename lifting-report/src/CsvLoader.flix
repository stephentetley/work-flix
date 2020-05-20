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
use FactIO/CsvImport.{CsvRow, CsvResult};

use LiftingReport/Relations.{EquiMatch, MemoLine, EquipmentInfo};
use LiftingReport/Common.{parseAI2Date, getQuotedNames};

namespace LiftingReport/CsvLoader {
    

    /// ## Equipment `rules`


    def readEquiMatch1[r](row: CsvRow): CsvResult[#{ EquiMatch | r}] & Impure =
        use Result.flatMap;
        use FactIO/CsvImport.{getStringByLabel};
        let* aiName         = getStringByLabel(row, "AI2 Equi Type");
        let* containsList   = getStringByLabel(row, "Name Contains") |> Result.map(getQuotedNames);
        let* s4ObjType      = getStringByLabel(row, "Object Type");
        let* s4Class        = getStringByLabel(row, "Classification");
        let* s1             = getStringByLabel(row, "Fixed or Portable");
        let* fop            = LiftingReport/Relations.readFixedOrPortable(s1);
        Ok( EquiMatch(aiName, containsList, s4ObjType, s4Class, fop). )


    pub def importEquiMatches[r](path: String): Result[#{ EquiMatch | r }, System.Error] & Impure =    
        use Result.flatMap;
        let* src = FactIO/CsvImport.newCsvStreamWithBOM(path, Text/Charset.utf_8(), true);
        FactIO/CsvImport.importRows(readEquiMatch1, src)

    /// ## Equi info - serial number, etc.

    /// Read an AI2 file (saved as to Csv from Xlsx)

    def readEquipmentInfo1[r](row: CsvRow, ix: Int32): CsvResult[#{ EquipmentInfo | r }] & Impure =
        use Result.flatMap;
        use FactIO/CsvImport.{getStringByLabel, getInt32ByLabel};
        let* pli            = getStringByLabel(row, "Reference");
        let* name           = getStringByLabel(row, "Common Name");
        let* sdate          = getStringByLabel(row, "Installed From");
        let* date           = parseAI2Date(sdate) |> Result.mapErr(_ -> System/Error.Generic("parseDate"));        
        let* manuf          = getStringByLabel(row, "Manufacturer");
        let* model          = getStringByLabel(row, "Model");
        let* specificModel  = getStringByLabel(row, "Specific Model/Frame");
        let* serialNum      = getStringByLabel(row, "Serial No");
        let* locnOnSite     = getStringByLabel(row, "Location On Site");        
        let* workLoad       = getInt32ByLabel(row, "Work Load");
        let* workLoadU      = getStringByLabel(row, "Work Load Units");
        let* ywref          = getStringByLabel(row, "YWRef");
        let* testCert       = getStringByLabel(row, "Test Cert No");
        Ok( EquipmentInfo(ix+ 1, pli, name, date, manuf, model, specificModel, serialNum, locnOnSite, 
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

    def readMemoLine1[r](row: CsvRow): CsvResult[#{ MemoLine | r }] & Impure = 
        use Result.flatMap;
        use FactIO/CsvImport.{getStringByLabel};
        let* pli    = getStringByLabel(row, "Reference");
        let* m1     = getStringByLabel(row, "Memo Line 1");
        let* m2     = getStringByLabel(row, "Memo Line 2");
        let* m3     = getStringByLabel(row, "Memo Line 3");      
        let* m4     = getStringByLabel(row, "Memo Line 4");
        let* m5     = getStringByLabel(row, "Memo Line 5");
        let ans     = makeMemoLine(pli, m1 :: m2 :: m3 :: m4 :: m5 :: Nil);
        Ok(ans)

    pub def importMemoLines[r](path: String): Result[#{ MemoLine | r }, System.Error] & Impure =    
        use Result.flatMap;
        let* src = FactIO/CsvImport.newCsvStreamWithBOM(path, Text/Charset.utf_8(), true);
        FactIO/CsvImport.importRows(readMemoLine1, src)

    // pub def loadAll[r](src: String): Result[ #{ EquipmentInfo, MemoLine | r }, String] & Impure =
    //     use Result.flatMap;
    //     let* r1 = importEquipmentInfo(src);
    //     let* r2 = importMemoLines(src);
    //     Ok(r1 <+> r2)
        
}