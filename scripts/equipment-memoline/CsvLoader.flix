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


rel EquipmentInfo(plicode: String, commonname: String, manufacturer: String, model:String, serialnumber: String, status: String, installedyear: Int32)

rel MemoLine(plicode: String, index: Int32, memotext:String)

namespace EquipmentMemoline/CsvLoader {
    
    /// Read an AI2 file (saved as to Csv from Xlsx)

    def readEquipmentInfo1[r](row: CsvRow): CsvResult[#{ EquipmentInfo | r }] & Impure = 
        use Work/CommonUtils.getYear;
        use Validation.lift7;
        lift7(
            (x1, x2, x3, x4, x5, x6, x7) -> { 
                let instyear = getYear(x7) |> x -> Result.getWithDefault(x, 0);
                EquipmentInfo(x1, x2, x3, x4, x5, x6, instyear).
            },
            FactIO/CsvImport.getStringByLabel(row, "Reference"),
            FactIO/CsvImport.getStringByLabel(row, "Common Name"),
            FactIO/CsvImport.getStringByLabel(row, "Manufacturer"),
            FactIO/CsvImport.getStringByLabel(row, "Model"),
            FactIO/CsvImport.getStringByLabel(row, "Serial No"),
            FactIO/CsvImport.getStringByLabel(row, "AssetStatus"),
            FactIO/CsvImport.getStringByLabel(row, "Installed From")           
        )

    pub def importEquipmentInfo[r](path: String): Result[#{ EquipmentInfo | r }, String] & Impure =    
        use Result.flatMap;
        let* src = FactIO/CsvImport.newCsvSource(path, CsvFormat.Default, true);
        FactIO/CsvImport.iterate(readEquipmentInfo1, src)

    /// Read an AI2 file (saved as to Csv from Xlsx) for memo lines

    def addIfNotBlank[r](plicode: String, ix: Int32, memo: String, relns: #{ MemoLine | r }): #{ MemoLine | r } = 
        if (memo == "") 
            relns
        else 
            relns <+> MemoLine(plicode, ix, memo).

    def readMemoLines1[r](row: CsvRow): CsvResult[#{ MemoLine | r }] & Impure = 
        Validation.lift6(
            (pli, m1, m2, m3, m4, m5) -> {
                #{ } 
                    |> addIfNotBlank(pli, 1, m1)
                    |> addIfNotBlank(pli, 2, m2)
                    |> addIfNotBlank(pli, 1, m3)
                    |> addIfNotBlank(pli, 1, m4)
                    |> addIfNotBlank(pli, 1, m5)
            },
            FactIO/CsvImport.getStringByLabel(row, "Reference"),
            FactIO/CsvImport.getStringByLabel(row, "Memo Line 1"),
            FactIO/CsvImport.getStringByLabel(row, "Memo Line 2"),
            FactIO/CsvImport.getStringByLabel(row, "Memo Line 3"),            
            FactIO/CsvImport.getStringByLabel(row, "Memo Line 4"),
            FactIO/CsvImport.getStringByLabel(row, "Memo Line 5")            
        )

    pub def importMemoLines[r](path: String): Result[#{ MemoLine | r }, String] & Impure =    
        use Result.flatMap;
        let* src = FactIO/CsvImport.newCsvSource(path, CsvFormat.Default, true);
        FactIO/CsvImport.iterate(readMemoLines1, src)

    pub def loadAll[r](src: String): Result[ #{ EquipmentInfo, MemoLine | r }, String] & Impure =
        use Result.flatMap;
        let* r1 = importEquipmentInfo(src);
        let* r2 = importMemoLines(src);
        Ok(r1 <+> r2)
        
}