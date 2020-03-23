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

rel Synced(name: String)
rel Syncable(name: String)


rel NoSiteWork(name: String)
rel NoSurvey(name: String)

namespace Sync {

    pub def synced[r](): #{ Synced, EdmsInfo, SurveyInfo, SiteWorkInfo | r } = #{ 
        Synced(name) :- 
            EdmsInfo(name), 
            SurveyInfo(name, _),
            SiteWorkInfo(name, _).
    }



    pub def syncable[r](): #{ Syncable, EdmsInfo, SurveyInfo, SiteWorkInfo | r } = #{ 
        Syncable(name) :- 
            SurveyInfo(name, _),
            SiteWorkInfo(name, _),        
            not EdmsInfo(name).
    }

    pub def noSiteWork[r](): #{ NoSiteWork, SurveyInfo, SiteWorkInfo | r } = #{ 
        NoSiteWork(name) :- 
            SurveyInfo(name, _),
            not SiteWorkInfo(name, _).
    }

    pub def noSurvey[r](): #{ NoSurvey, SurveyInfo, SiteWorkInfo | r } = #{ 
        NoSurvey(name) :- 
            SiteWorkInfo(name, _),
            not SurveyInfo(name, _).
    }


    pub def syncableQuery(sources: SourceFiles, outpath: String): Unit & Impure = 
        let headers = ["Syncable"];
        let buildStep = CsvExport.makeBuildStep(x -> [x]); 
        let start = CsvExport.emptyCsvBuilder();
        match CsvLoader.loadAll(sources) { 
            case Err(msg) => Console.printLine(msg)
            case Ok(relns) => {
                { fold Syncable start buildStep (solve relns <+> syncable()) } |> CsvExport.outputCsv(outpath, headers);
                Console.printLine("Wrote: " + outpath)
            }
        }

    pub def noSurveyQuery(sources: SourceFiles, outpath: String): Unit & Impure = 
        let headers = ["No Survey"];
        let buildStep = CsvExport.makeBuildStep(x -> [x]); 
        let start = CsvExport.emptyCsvBuilder();
        match CsvLoader.loadAll(sources) { 
            case Err(msg) => Console.printLine(msg)
            case Ok(relns) => {
                { fold NoSurvey start buildStep (solve relns <+> noSurvey()) } |> CsvExport.outputCsv(outpath, headers);
                Console.printLine("Wrote: " + outpath)
            }
        }

    pub def noSiteWorkQuery(sources: SourceFiles, outpath: String): Unit & Impure = 
        let headers = ["No Site Work"];
        let buildStep = CsvExport.makeBuildStep(x -> [x]); 
        let start = CsvExport.emptyCsvBuilder();
        match CsvLoader.loadAll(sources) { 
            case Err(msg) => Console.printLine(msg)
            case Ok(relns) => {
                { fold NoSiteWork start buildStep (solve relns <+> noSiteWork()) } |> CsvExport.outputCsv(outpath, headers);
                Console.printLine("Wrote: " + outpath)
            }
        }
}
