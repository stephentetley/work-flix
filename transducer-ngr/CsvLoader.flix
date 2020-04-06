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

use CsvImport.CsvFormat;

rel EquipmentInfo(plicode: String, siteName: String, commonName: String, locref: String, transducerNgr: String, memo: String)

rel SiteListInfo(index: Int32, sai: String, name: String, discharge: String, sensorNgr: String, pli: String, commonName: String)

type alias SourceFiles = 
    { equipmentList: String
    , siteList: String
    }

namespace TransducerNgr/CsvLoader {

    /// Read an AI2 file (saved as to Csv from Xlsx)

    def t0975Memo(xs: List[String]): Option[String] = 
        List.findLeft(s -> String.isSubstringOf("T0975", s), xs)

    def readEquipmentInfo1[r](row: CsvRow): CsvResult[#{ EquipmentInfo | r }] & Impure = 
        ValidationExtras.pipeV9(
            CsvImport.getStringByLabel(row, "Reference"),
            CsvImport.getStringByLabel(row, "Common Name"),
            CsvImport.getStringByLabel(row, "Loc.Ref."),
            CsvImport.getStringByLabel(row, "Transducer NGR"),
            CsvImport.getStringByLabel(row, "Memo Line 1"),
            CsvImport.getStringByLabel(row, "Memo Line 2"),
            CsvImport.getStringByLabel(row, "Memo Line 3"),
            CsvImport.getStringByLabel(row, "Memo Line 4"),
            CsvImport.getStringByLabel(row, "Memo Line 5"),
            (x1, x2, x3, x4, x5, x6, x7, x8, x9) ->
                let site = Work/CommonUtils.siteFromCommonName(x2);
                match t0975Memo(x5 :: x6 :: x7 :: x8 :: x9 :: Nil) {
                    case None => #{ }
                    case Some(memo) => EquipmentInfo(x1, site, x2, x3, x4, memo).
                }
        )

    pub def importEquipmentInfo[r](path: String): Result[#{ EquipmentInfo | r }, String] & Impure =  
        use Result.flatMap;  
        let* src = CsvImport.newCsvSource(path, CsvFormat.Default, true);
        CsvImport.iterate(readEquipmentInfo1, src)



    // Site List
    def readSiteListInfo1[r](row: CsvRow, ix: Int32): CsvResult[#{ SiteListInfo | r }] & Impure = 
        ValidationExtras.pipeV6(
            CsvImport.getStringByIndex(row, 0),
            CsvImport.getStringByIndex(row, 1),
            CsvImport.getStringByIndex(row, 2),
            CsvImport.getStringByIndex(row, 3),
            CsvImport.getStringByIndex(row, 4),
            CsvImport.getStringByIndex(row, 5),
            (sai, sname, dname, sensorNgr, pli, ename) -> SiteListInfo(ix + 1, sai, sname, dname, sensorNgr, pli, ename).
            
        )

    pub def importSiteListInfo[r](path: String): Result[#{ SiteListInfo | r }, String] & Impure =    
        use Result.flatMap;  
        let* src = CsvImport.newCsvSource(path, CsvFormat.Default, true);
        CsvImport.iterateWithCount(readSiteListInfo1, src) 

    pub def loadAll[r](paths: SourceFiles): Result[ #{ SiteListInfo, EquipmentInfo | r }, String] & Impure =
        use Result.flatMap;
        let* r1 = importEquipmentInfo(paths.equipmentList);
        let* r2 = importSiteListInfo(paths.siteList);
        Ok(r1 <+> r2)

}