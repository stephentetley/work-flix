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

rel SiteListStatus(name: String, status: String)

rel EdmsStatus(ix: Int32, sai: String, name: String, status: String)

namespace EdmsSync {

    pub def synced[r](): #{ Synced, EdmsInfo, SurveyInfo, SiteWorkInfo | r } = #{ 
        Synced(name) :- 
            EdmsInfo(name), 
            SurveyInfo(name, _),
            SiteWorkInfo(name, _).
    }

    /// Synacable

    pub def syncable[r](): #{ Syncable, EdmsInfo, SurveyInfo, SiteWorkInfo | r } = #{ 
        Syncable(name) :- 
            SurveyInfo(name, _),
            SiteWorkInfo(name, _),        
            not EdmsInfo(name).
    }

    pub def syncableQuery(sources: SourceFiles, outpath: String): Unit & Impure = 
        let headers = ["Syncable"];
        let buildStep = CsvExport.makeBuildStep(x -> [x]); 
        let start = CsvExport.emptyCsvBuilder();
        match EdmsSync/CsvLoader.loadAll(sources) { 
            case Err(msg) => Console.printLine(msg)
            case Ok(relns) => {
                { fold Syncable start buildStep (solve relns <+> syncable()) } |> CsvExport.outputCsv(outpath, headers);
                Console.printLine("Wrote: " + outpath)
            }
        }

    /// No Site work

    pub def noSiteWork[r](): #{ NoSiteWork, SurveyInfo, SiteWorkInfo | r } = #{ 
        NoSiteWork(name) :- 
            SurveyInfo(name, _),
            not SiteWorkInfo(name, _).
    }


    pub def noSiteWorkQuery(sources: SourceFiles, outpath: String): Unit & Impure = 
        let headers = ["No Site Work"];
        let buildStep = CsvExport.makeBuildStep(x -> [x]); 
        let start = CsvExport.emptyCsvBuilder();
        match EdmsSync/CsvLoader.loadAll(sources) { 
            case Err(msg) => Console.printLine(msg)
            case Ok(relns) => {
                { fold NoSiteWork start buildStep (solve relns <+> noSiteWork()) } |> CsvExport.outputCsv(outpath, headers);
                Console.printLine("Wrote: " + outpath)
            }
        }

    /// No Survey

    pub def noSurvey[r](): #{ NoSurvey, SurveyInfo, SiteWorkInfo | r } = #{ 
        NoSurvey(name) :- 
            SiteWorkInfo(name, _),
            not SurveyInfo(name, _).
    }

    pub def noSurveyQuery(sources: SourceFiles, outpath: String): Unit & Impure = 
        let headers = ["No Survey"];
        let buildStep = CsvExport.makeBuildStep(x -> [x]); 
        let start = CsvExport.emptyCsvBuilder();
        match EdmsSync/CsvLoader.loadAll(sources) { 
            case Err(msg) => Console.printLine(msg)
            case Ok(relns) => {
                { fold NoSurvey start buildStep (solve relns <+> noSurvey()) } |> CsvExport.outputCsv(outpath, headers);
                Console.printLine("Wrote: " + outpath)
            }
        }

    /// Site List Status

    pub def siteListStatus[r](): #{ SiteListStatus, SiteListInfo, SurveyInfo, SiteWorkInfo | r } = #{ 
        SiteListStatus(name1, "Both Missing") :- 
            SiteListInfo(_, _, name1, name2),
            not SurveyInfo(name2, _), 
            not SiteWorkInfo(name2, _).
        
        SiteListStatus(name1, "Survey Missing") :- 
            SiteListInfo(_, _, name1, name2),
            SiteWorkInfo(name2, _),
            not SurveyInfo(name2, _).

        SiteListStatus(name1, "Site Work Missing") :- 
            SiteListInfo(_, _, name1, name2),
            SurveyInfo(name2, _),
            not SiteWorkInfo(name2, _).
    }

    def makeCells2(src: (String,String)): Array[String] & Impure = 
        let (x1,x2) = src;
        [x1, x2]

    pub def siteListStatusQuery(sources: SourceFiles, outpath: String): Unit & Impure = 
        let headers = ["Site", "Status"];
        let buildStep = CsvExport.makeBuildStep(makeCells2); 
        let start = CsvExport.emptyCsvBuilder();
        match EdmsSync/CsvLoader.loadAll(sources) { 
            case Err(msg) => Console.printLine(msg)
            case Ok(relns) => {
                { fold SiteListStatus start buildStep (solve relns <+> siteListStatus()) } |> CsvExport.outputCsv(outpath, headers);
                Console.printLine("Wrote: " + outpath)
            }
        }

    /// Edms Status
    pub def edmsStatus[r](): #{ EdmsStatus, SiteListInfo, EdmsInfo | r } = #{ 
        EdmsStatus(ix, sai, name1, "On Edms") :- 
            SiteListInfo(ix, sai, name1, name2),
            EdmsInfo(name2).
            
        
        EdmsStatus(ix, sai, name1, "") :- 
            SiteListInfo(ix, sai, name1, name2),
            not EdmsInfo(name2).
    }

    def makeEdmsStatusCells(src: (Int32, String, String, String)): Array[String] & Impure = 
        let (x1,x2,x3,x4) = src;
        [Int32.toString(x1), x2, x3, x4]

    pub def edmsStatusQuery(sources: SourceFiles, outpath: String): Unit & Impure = 
        let headers = ["Index", "Sai", "Name", "Status"];
        let buildStep = CsvExport.makeBuildStep(makeEdmsStatusCells); 
        let start = CsvExport.emptyCsvBuilder();
        match EdmsSync/CsvLoader.loadAll(sources) { 
            case Err(msg) => Console.printLine(msg)
            case Ok(relns) => {
                { fold EdmsStatus start buildStep (solve relns <+> edmsStatus()) } |> CsvExport.outputCsv(outpath, headers);
                Console.printLine("Wrote: " + outpath)
            }
        }
}
