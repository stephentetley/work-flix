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

rel S4EquiInfo(floc: String, description: String, manufacturer: String, model:String)

rel AI2EquipmentInfo(site: String, name: String, manufacturer: String, model:String, status: String)

rel SiteMapping(ainame: String, s4code: String, s4name: String)

type alias SourceFiles = 
    { s4Equipment: String
    , aiOutstations: String
    , siteMapping: String
    }

namespace CsvLoader {

    /// Read a S4 download file converted to Csv for speed

    def readS4EquiInfo1[r](row: CsvRow): CsvResult[#{ S4EquiInfo | r }] & Impure = 
        ValidationExtras.pipeV4(
            CsvImport.getStringByLabel(row, "Functional Location [TPLN_EILO]"),
            CsvImport.getStringByLabel(row, "Description (medium text) [TXTMI]"),
            CsvImport.getStringByLabel(row, "Manufacturer [HERST]"),
            CsvImport.getStringByLabel(row, "Model number [TYPBZ]"),
            (x1, x2, x3, x4) -> S4EquiInfo(x1, x2, x3, x4).
        )

    pub def importS4EquiInfo[r](path: String): Result[#{ S4EquiInfo | r }, String] & Impure =    
        match CsvImport.newCsvSource(path, CsvFormat.Default, true) {
            case Err(msg) => Err(msg)
            case Ok(src) => 
                match CsvImport.iterate(readS4EquiInfo1, src) {
                    case Err(msg) => Err(msg)
                    case Ok(relns) => Ok(relns)
                }
        }

    /// Read an AI2 export file (xlsx saved as csv)

    def siteFromCommonName(s: String): String & Impure = 
        let arr = String.split(s, "/");
        if (String.matches(s, ".*/SEWER MAINTENANCE/.*") && Array.length(arr) == 5) {
            let s1 = arr[2];
            let s2 = arr[3];
            s1 + "/" + s2
        } else if (Array.length(arr) > 2) {
            let s1 = arr[0];
            let s2 = arr[1];
            s1 + "/" + s2
        } else s

    def descriptionFromCommonName(s: String): String & Impure = 
        let arr = String.split(s, "/");
        if (String.matches(s, ".*/SEWER MAINTENANCE/.*") && Array.length(arr) == 5) {
            "LEVEL MONITORING POINT"
        } else if (Array.length(arr) > 2) {
            let ix = Array.length(arr) - 2;
            arr[ix]
        } else s

    def readAI2EquipmentInfo1[r](row: CsvRow): CsvResult[#{ AI2EquipmentInfo | r }] & Impure = 
        ValidationExtras.pipeV4(
            CsvImport.getStringByLabel(row, "Common Name"),
            CsvImport.getStringByLabel(row, "Manufacturer"),
            CsvImport.getStringByLabel(row, "Model"),
            CsvImport.getStringByLabel(row, "AssetStatus"),
            (x1, x2, x3, x4) -> { 
                let site = siteFromCommonName(x1);
                let desc = descriptionFromCommonName(x1);
                AI2EquipmentInfo(site, desc, x2, x3, x4).                
            }
        )

    pub def importAI2EquipmentInfo[r](path: String): Result[#{ AI2EquipmentInfo | r }, String] & Impure =    
        match CsvImport.newCsvSource(path, CsvFormat.Default, true) {
            case Err(msg) => Err(msg)
            case Ok(src) => 
                match CsvImport.iterate(readAI2EquipmentInfo1, src) { 
                    case Err(msg) => Err(msg)
                    case Ok(relns) => Ok(relns)
                }
        }

    def renameHLR(s: String): String = String.replaceAll("HLR", "CSO", s)
    
    /// Read site mapping (ai2 to s4)
    def readSiteMapping1[r](row: CsvRow): CsvResult[#{ SiteMapping | r }] & Impure = 
        ValidationExtras.pipeV3(
            CsvImport.getStringByIndex(row, 0),     // Workaround from not handling BOM
            CsvImport.getStringByLabel(row, "S/4 Hana Floc Lvl1_Code"),
            CsvImport.getStringByLabel(row, "S/4 Hana Floc Description"),
            (x1, x2, x3) -> { 
                let r1 = SiteMapping(x1, x2, x3). ;
                let r2 = SiteMapping(renameHLR(x1), x2, x3). ;
                if (String.contains(x1, "HLR")) (r1 <+> r2) else r1                
            }
        )

    pub def importSiteMapping[r](path: String): Result[#{ SiteMapping | r }, String] & Impure =    
        match CsvImport.newCsvSource(path, CsvFormat.Default, true) {
            case Err(msg) => Err(msg)
            case Ok(src) => 
                match CsvImport.iterate(readSiteMapping1, src) {
                    case Err(msg) => Err(msg)
                    case Ok(relns) => Ok(relns)
                }
        }

    pub def loadAll[r](paths: SourceFiles): Result[ #{ SiteMapping, S4EquiInfo, AI2EquipmentInfo | r }, String] & Impure =
        use Common/Utils.pipeR3;
        pipeR3(
            importS4EquiInfo(paths.s4Equipment),
            importAI2EquipmentInfo(paths.aiOutstations),
            importSiteMapping(paths.siteMapping),
            (r1, r2, r3) -> r1 <+> r2 <+> r3
        )


}