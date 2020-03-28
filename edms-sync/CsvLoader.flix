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

rel SiteListInfo(index: Int32, sai: String, name: String, name2: String)

type alias SourceFiles = 
    { edmsExport: String
    , edmsPending: String
    , csoSpsSurveys: String
    , stwSurveys: String
    , csoSpsSiteWork: String
    , stwSiteWork: String
    , siteList: String
    }


namespace EdmsSync/CsvLoader {

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
        use Result.flatMap;
        let* src = CsvImport.newCsvSource(path, CsvFormat.Default, true);
        CsvImport.iterate(readEdmsInfo1, src)

    def readEdmsPending1[r](row: CsvRow): CsvResult[#{ EdmsInfo | r }] & Impure = 
        Validation.map(
            x1 -> { EdmsInfo(x1). },
            CsvImport.getStringByIndex(row, 0)            
        )

    pub def importEdmsPending[r](path: String): Result[#{ EdmsInfo | r }, String] & Impure =    
        use Result.flatMap;
        let* src = CsvImport.newCsvSource(path, CsvFormat.Default, true);
        CsvImport.iterate(readEdmsPending1, src)


    // Survey
    def readSurveyInfo1[r](row: CsvRow): CsvResult[#{ SurveyInfo | r }] & Impure = 
        ValidationExtras.pipeV2(
            CsvImport.getStringByIndex(row, 0),
            CsvImport.getStringByIndex(row, 1),
            (x1, x2) -> SurveyInfo(x1, x2).
        )

    pub def importSurveyInfo[r](path: String): Result[#{ SurveyInfo | r }, String] & Impure =
        use Result.flatMap;
        let* src = CsvImport.newCsvSource(path, CsvFormat.Default, true);
        CsvImport.iterate(readSurveyInfo1, src)
        
    // Site Work
    def readSiteWorkInfo1[r](row: CsvRow): CsvResult[#{ SiteWorkInfo | r }] & Impure = 
        ValidationExtras.pipeV2(
            CsvImport.getStringByIndex(row, 0),
            CsvImport.getStringByIndex(row, 1),
            (x1, x2) -> SiteWorkInfo(x1, x2).
        )

    pub def importSiteWorkInfo[r](path: String): Result[#{ SiteWorkInfo | r }, String] & Impure =
        use Result.flatMap;
        let* src = CsvImport.newCsvSource(path, CsvFormat.Default, true);
        CsvImport.iterate(readSiteWorkInfo1, src)

    // Site List
    def readSiteListInfo1[r](row: CsvRow, ix: Int32): CsvResult[#{ SiteListInfo | r }] & Impure = 
        ValidationExtras.pipeV2(
            CsvImport.getStringByIndex(row, 0),
            CsvImport.getStringByIndex(row, 1),
            (x1, x2) -> SiteListInfo(ix+1, x1, x2, String.replace("/", " ", x2)).
        )

    pub def importSiteListInfo[r](path: String): Result[#{ SiteListInfo | r }, String] & Impure =    
        use Result.flatMap;
        let* src = CsvImport.newCsvSource(path, CsvFormat.Default, true);
        CsvImport.iterateWithCount(readSiteListInfo1, src)

    pub def loadAll[r](paths: SourceFiles): Result[ #{ SiteListInfo, EdmsInfo, SurveyInfo, SiteWorkInfo | r }, String] & Impure =
        use Result.flatMap;
        let* r1 = importEdmsInfo(paths.edmsExport);
        let* r2 = importEdmsInfo(paths.edmsPending);
        let* r3 = importSurveyInfo(paths.csoSpsSurveys);
        let* r4 = importSurveyInfo(paths.stwSurveys);
        let* r5 = importSiteWorkInfo(paths.csoSpsSiteWork);
        let* r6 = importSiteWorkInfo(paths.stwSiteWork);
        let* r7 = importSiteListInfo(paths.siteList);
        Ok(r1 <+> r2 <+> r3 <+> r4 <+> r5 <+> r6 <+> r7)

}