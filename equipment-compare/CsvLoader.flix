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

rel S4EquiInfo(floc: String, description: String, manufacturer: String, model:String, serialnumber: String)

rel AI2EquipmentInfo(site: String, name: String, manufacturer: String, model:String, serialnumber: String, status: String)

rel SiteMapping(ainame: String, s4code: String, s4name: String)

type alias SourceFiles = 
    { s4Equipment: String
    , aiOutstations: String
    , siteMapping: String
    }

namespace EquipmentCompare/CsvLoader {

    /// Read a S4 download file converted to Csv for speed

    def readS4EquiInfo1[r](row: CsvRow): CsvResult[#{ S4EquiInfo | r }] & Impure = 
        Validation.lift5(
            (x1, x2, x3, x4, x5) -> { S4EquiInfo(x1, x2, x3, x4, x5). },
            FactIO/CsvImport.getStringByLabel(row, "Functional Location [TPLN_EILO]"),
            FactIO/CsvImport.getStringByLabel(row, "Description (medium text) [TXTMI]"),
            FactIO/CsvImport.getStringByLabel(row, "Manufacturer [HERST]"),
            FactIO/CsvImport.getStringByLabel(row, "Model number [TYPBZ]"),
            FactIO/CsvImport.getStringByLabel(row, "ManufSerialNumber [SERGE]")            
        )

    pub def importS4EquiInfo[r](path: String): Result[#{ S4EquiInfo | r }, String] & Impure =    
        use Result.flatMap;  
        let* src = FactIO/CsvImport.newCsvSource(path, CsvFormat.Default, true);
        FactIO/CsvImport.iterate(readS4EquiInfo1, src)
        

    /// Read an AI2 export file (xlsx saved as csv)


    def readAI2EquipmentInfo1[r](row: CsvRow): CsvResult[#{ AI2EquipmentInfo | r }] & Impure = 
        Validation.lift5(
            (x1, x2, x3, x4, x5) -> { 
                let site = Work/CommonUtils.siteFromCommonName(x1);
                let desc = Work/CommonUtils.descriptionFromCommonName(x1);
                AI2EquipmentInfo(site, desc, x2, x3, x4, x5).                
            },
            FactIO/CsvImport.getStringByLabel(row, "Common Name"),
            FactIO/CsvImport.getStringByLabel(row, "Manufacturer"),
            FactIO/CsvImport.getStringByLabel(row, "Model"),           
            FactIO/CsvImport.getStringByLabel(row, "Serial No"),
            FactIO/CsvImport.getStringByLabel(row, "AssetStatus")            
        )

    pub def importAI2EquipmentInfo[r](path: String): Result[#{ AI2EquipmentInfo | r }, String] & Impure =    
        use Result.flatMap;  
        let* src = FactIO/CsvImport.newCsvSource(path, CsvFormat.Default, true);
        FactIO/CsvImport.iterate(readAI2EquipmentInfo1, src)
        

    def renameHLR(s: String): String = String.replace("HLR", "CSO", s)
    
    /// Read site mapping (ai2 to s4)
    def readSiteMapping1[r](row: CsvRow): CsvResult[#{ SiteMapping | r }] & Impure = 
        Validation.lift3(
            (x1, x2, x3) -> { 
                let r1 = SiteMapping(x1, x2, x3). ;
                let r2 = SiteMapping(renameHLR(x1), x2, x3). ;
                if (String.isSubstringOf("HLR", x1)) (r1 <+> r2) else r1                
            },
            FactIO/CsvImport.getStringByIndex(row, 0),     // Workaround from not handling BOM
            FactIO/CsvImport.getStringByLabel(row, "S/4 Hana Floc Lvl1_Code"),
            FactIO/CsvImport.getStringByLabel(row, "S/4 Hana Floc Description")            
        )

    pub def importSiteMapping[r](path: String): Result[#{ SiteMapping | r }, String] & Impure =    
        use Result.flatMap;  
        let* src = FactIO/CsvImport.newCsvSource(path, CsvFormat.Default, true);
        FactIO/CsvImport.iterate(readSiteMapping1, src) 

    pub def loadAll[r](paths: SourceFiles): Result[ #{ SiteMapping, S4EquiInfo, AI2EquipmentInfo | r }, String] & Impure =
        use Result.flatMap;
        let* r1 = importS4EquiInfo(paths.s4Equipment);
        let* r2 = importAI2EquipmentInfo(paths.aiOutstations);
        let* r3 = importSiteMapping(paths.siteMapping);
        Ok(r1 <+> r2 <+> r3)


}