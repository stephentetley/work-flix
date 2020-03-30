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

rel Answer(index: Int32, siteSai: String, siteName: String, dischargeName: String, existingPli: String, existingNgr: String, 
            pli: String, ngr: String, commonName: String)

namespace TransducerNgr {

    pub def getAnswer[r](): #{ Answer, SiteListInfo, EquipmentInfo | r } =
        #{ 
            Answer(ix, sai, sname, dname, ex1, ex2, pli, ngr, commonName) :-
                SiteListInfo(ix, sai, sname, dname, ex1, ex2, _),
                EquipmentInfo(pli, sname, commonName, _, ngr, _).

            Answer(ix, sai, sname, dname, ex1, ex2, "", "", "") :-
                SiteListInfo(ix, sai, sname, dname, ex1, ex2, _),
                not EquipmentInfo(_, sname, _, _, _, _).
        }

    def answerCells(x: (Int32, String, String, String, String, String, String, String, String)): Array[String] & Impure = 
        let (x1, x2, x3, x4, x5, x6, x7, x8, x9) = x;
        [Int32.toString(x1), x2, x3, x4, x5, x6, x7, x8, x9] 

    pub def answerQuery(sources: SourceFiles, outpath: String): Unit & Impure = 
        let headers = ["Index", "SAI", "Site Name", "Discharge Name", "Sensor NGR (Sitr List)", "PLI (Site List)", "PLI (AI2)", "NGR (AI2)", "Common Name (AI2)"];
        let buildStep = CsvExport.makeBuildStep(answerCells); 
        let start = CsvExport.emptyCsvBuilder();
        match TransducerNgr/CsvLoader.loadAll(sources) { 
            case Err(msg) => Console.printLine(msg)
            case Ok(relns) => {
                { fold Answer start buildStep (solve relns <+> getAnswer()) } |> CsvExport.outputCsv(outpath, headers);
                Console.printLine("Wrote: " + outpath)
            }
        }

}