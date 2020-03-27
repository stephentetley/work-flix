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

rel EquipmentInfo(plicode: String, commonname: String, locref: String, transducerNgr: String, memo: String)
rel SiteListInfo(index: Int32, sai: String, name: String)

type alias SourceFiles = 
    { equipmentList: String
    , siteList: String
    }

namespace CsvLoader {

    /// Read an AI2 file (saved as to Csv from Xlsx)

    def t0975Memo(xs: List[String]): Option[String] = 
        List.findLeft(s -> String.contains(s, "T0975"), xs)

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
                match t0975Memo(x5 :: x6 :: x7 :: x8 :: x9 :: Nil) {
                    case None => #{ }
                    case Some(memo) => EquipmentInfo(x1, x2, x3, x4, memo).
                }
        )

    pub def importEquipmentInfo[r](path: String): Result[#{ EquipmentInfo | r }, String] & Impure =    
        match CsvImport.newCsvSource(path, CsvFormat.Default, true) {
            case Err(msg) => Err(msg)
            case Ok(src) => 
                match CsvImport.iterate(readEquipmentInfo1, src) {
                    case Err(msg) => Err(msg)
                    case Ok(relns) => Ok(relns)
                }
        }

    // Site List
    def readSiteListInfo1[r](row: CsvRow, ix: Int32): CsvResult[#{ SiteListInfo | r }] & Impure = 
        ValidationExtras.pipeV2(
            CsvImport.getStringByIndex(row, 0),
            CsvImport.getStringByIndex(row, 1),
            (x1, x2) -> SiteListInfo(ix + 1, x1, x2).
            
        )

    pub def importSiteListInfo[r](path: String): Result[#{ SiteListInfo | r }, String] & Impure =    
        match CsvImport.newCsvSource(path, CsvFormat.Default, true) {
            case Err(msg) => Err(msg)
            case Ok(src) => 
                match CsvImport.iterateWithCount(readSiteListInfo1, src) {
                    case Err(msg) => Err(msg)
                    case Ok(relns) => Ok(relns)
                }
        }

    pub def loadAll[r](paths: SourceFiles): Result[ #{ SiteListInfo, EquipmentInfo | r }, String] & Impure =
        use Common/Utils.pipeR2;
        pipeR2(
            importEquipmentInfo(paths.equipmentList),                        
            importSiteListInfo(paths.siteList),
            (r1, r2) -> r1 <+> r2
        )

}