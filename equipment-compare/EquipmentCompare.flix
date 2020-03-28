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

rel Equipment(ai: String, s4: String, serialnumber: String)

rel NoS4(ai: String, s4: String)

rel InS4(ai: String)

rel SiteMapAnswer(ainame: String, s4code: String, s4name: String)

namespace EquipmentCompare {

    /// A "cell printer" for the body of NoS4.
    def equipmentCells(src: (String, String, String)): Array[String] & Impure = 
        let (x1, x2, x3) = src;
        [x1, x2, x3]

    pub def csvWriteEquipment[r](outpath: String, relns: #{ Equipment | r }): Unit & Impure = 
        let headers = ["AI Name", "S4 Code", "Serial Number"];
        let buildStep = CsvExport.makeBuildStep(equipmentCells);
        { fold Equipment CsvExport.emptyCsvBuilder() buildStep relns }
                |> CsvExport.outputCsv(outpath, headers)

    pub def equipmentMatch[r](): #{ Equipment, SiteMapping, S4EquiInfo, AI2EquipmentInfo | r } =
        let isPrefix = (x,y)  -> String.startsWith(x, y);
        #{ 
            Equipment(xsite, sfloc, serialnum) :- 
                AI2EquipmentInfo(xsite, _, _, _, serialnum, "OPERATIONAL"), 
                SiteMapping(xsite, scode, _),
                S4EquiInfo(sfloc, _, _, _, serialnum),
                if isPrefix(sfloc, scode).
        }

    pub def noS4[r](): #{ NoS4, InS4, SiteMapping, S4EquiInfo, AI2EquipmentInfo | r } =
        let isPrefix = (x,y)  -> String.startsWith(x, y);
        #{ 
            InS4(xsite) :- 
                AI2EquipmentInfo(xsite, _, _, _, _, "OPERATIONAL"), 
                SiteMapping(xsite, scode, _),
                if isPrefix(sfloc, scode), 
                S4EquiInfo(sfloc, _, _, _, _).

            NoS4(xsite, "No code") :- 
                AI2EquipmentInfo(xsite, _, _, _, _, "OPERATIONAL"), 
                not SiteMapping(xsite, _, _).

            NoS4(xsite, scode) :- 
                AI2EquipmentInfo(xsite, _, _, _, _, "OPERATIONAL"), 
                SiteMapping(xsite, scode, _),
                not InS4(xsite).    
        }     

    pub def siteMap[r](aiName: String, rels: #{ SiteMapping, SiteMapAnswer | r}): #{ SiteMapAnswer } =
        let rules = #{ 
            SiteMapAnswer(x, y, z) :- SiteMapping(x, y, z), if x == aiName.
        };
        project SiteMapAnswer (solve rels <+> rules)


}


