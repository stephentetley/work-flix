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

rel Answer(plicode: String, commonname: String, memotext: String, installedyear: Int32, serialnumber: String)

namespace EquipmentMemoline {

    pub def memoMatch[r](patt: String): #{ Answer, EquipmentInfo, MemoLine | r } =
        let rmatches = src -> String.isMatch(patt, src);
        let yearmatch = yr -> yr == 2019 || yr == 2020;
        #{             
            Answer(pli, longname, text, instyear, serialnum) :- 
                EquipmentInfo(pli, longname, _, _, serialnum, "OPERATIONAL", instyear), 
                MemoLine(pli, _, text),
                if rmatches(text) && yearmatch(instyear).

        }

}