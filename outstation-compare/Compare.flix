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

rel Telemetry(ai: String, s4: String)

rel NoS4(ai: String)

rel InS4(ai: String)

rel SiteMapAnswer(ainame: String, s4code: String, s4name: String)

namespace Compare {

    pub def telemetryMatch[r](): #{ Telemetry, SiteMapping, S4EquiInfo, AI2OutstationInfo | r } =
        let isPrefix = (x,y)  -> String.startsWith(x, y);
        #{ 
            Telemetry(xsite, sfloc) :- 
                AI2OutstationInfo(xsite, _, _, _, "OPERATIONAL"), 
                SiteMapping(xsite, scode, _),
                S4EquiInfo(sfloc, _, _, _),
                if isPrefix(sfloc, scode).
        }

    pub def noS4[r](): #{ NoS4, InS4, SiteMapping, S4EquiInfo, AI2OutstationInfo | r } =
        let isPrefix = (x,y)  -> String.startsWith(x, y);
        #{ 
            InS4(xsite) :- 
                AI2OutstationInfo(xsite, _, _, _, "OPERATIONAL"), 
                SiteMapping(xsite, scode, _),
                if isPrefix(sfloc, scode), 
                S4EquiInfo(sfloc, _, _, _).

            NoS4(xsite) :- 
                AI2OutstationInfo(xsite, _, _, _, "OPERATIONAL"), 
                not InS4(xsite).    
        }     

    pub def siteMap[r](aiName: String, rels: #{ SiteMapping, SiteMapAnswer | r}): #{ SiteMapAnswer } =
        let rules = #{ 
            SiteMapAnswer(x, y, z) :- SiteMapping(x, y, z), if x == aiName.
        };
        project SiteMapAnswer (solve rels <+> rules)


}


