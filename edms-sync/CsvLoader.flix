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

// TODO add date as a YYYYMMDD Int32

rel EdmsInfo(site: String)

rel SurveyInfo(site: String, document: String)

rel SiteWorkInfo(site: String, document: String)

type alias SourceFiles = 
    { edmExport: String
    , csoSpsSurveys: String
    , stwSurveys: String
    , csoSpsSiteWork: String
    , stwSiteWork: String
    }


namespace CsvLoader {

    // EDMS

    def getEdmsName(s: String): String = match String.indexOfLeft(s, " T0975") {
        case None => s
        case Some(n) => String.slice(0, n, s)
    }

    def readEdmsInfo1[r](row: CsvRow): CsvResult[#{ EdmsInfo | r }] & Impure = 
        Validation.map(
            x1 -> { EdmsInfo(getEdmsName(x1)). },
            CsvImport.getStringByIndex(row, 0)            
        )

    pub def importEdmsInfo[r](path: String): Result[#{ EdmsInfo | r }, String] & Impure =    
        match CsvImport.newCsvSource(path, CsvFormat.Default, true) {
            case Err(msg) => Err(msg)
            case Ok(src) => 
                match CsvImport.iterate(readEdmsInfo1, src) {
                    case Err(msg) => Err(msg)
                    case Ok(relns) => Ok(relns)
                }
        }

    // Survey
    def readSurveyInfo1[r](row: CsvRow): CsvResult[#{ SurveyInfo | r }] & Impure = 
        ValidationExtras.pipeV2(
            CsvImport.getStringByIndex(row, 0),
            CsvImport.getStringByIndex(row, 1),
            (x1, x2) -> SurveyInfo(x1, x2).
        )

    pub def importSurveyInfo[r](path: String): Result[#{ SurveyInfo | r }, String] & Impure =    
        match CsvImport.newCsvSource(path, CsvFormat.Default, true) {
            case Err(msg) => Err(msg)
            case Ok(src) => 
                match CsvImport.iterate(readSurveyInfo1, src) {
                    case Err(msg) => Err(msg)
                    case Ok(relns) => Ok(relns)
                }
        }

    // Site Work
    def readSiteWorkInfo1[r](row: CsvRow): CsvResult[#{ SiteWorkInfo | r }] & Impure = 
        ValidationExtras.pipeV2(
            CsvImport.getStringByIndex(row, 0),
            CsvImport.getStringByIndex(row, 1),
            (x1, x2) -> SiteWorkInfo(x1, x2).
        )

    pub def importSiteWorkInfo[r](path: String): Result[#{ SiteWorkInfo | r }, String] & Impure =    
        match CsvImport.newCsvSource(path, CsvFormat.Default, true) {
            case Err(msg) => Err(msg)
            case Ok(src) => 
                match CsvImport.iterate(readSiteWorkInfo1, src) {
                    case Err(msg) => Err(msg)
                    case Ok(relns) => Ok(relns)
                }
        }

    pub def loadAll[r](paths: SourceFiles): Result[ #{ EdmsInfo, SurveyInfo, SiteWorkInfo | r }, String] & Impure =
        use Common/Utils.pipeR5;
        pipeR5(
            importEdmsInfo(paths.edmExport),
            importSurveyInfo(paths.csoSpsSurveys),
            importSurveyInfo(paths.stwSurveys),
            importSiteWorkInfo(paths.csoSpsSiteWork),
            importSiteWorkInfo(paths.stwSiteWork),
            (r1, r2, r3, r4, r5) -> r1 <+> r2 <+> r3 <+> r4 <+> r5
        )

}