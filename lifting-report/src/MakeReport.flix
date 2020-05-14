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

use LiftingReport/Relations.{EquiMatch, FixedOrPortable, EquipmentInfo, MemoLine, Answer};
use LiftingReport/Relations.FixedOrPortable.{Fixed, Portable};

namespace LiftingReport/MakeReport {

    rel EquiProps(s4Type: String, s4Class: String, fop: FixedOrPortable)

    pub def equipmentMatch[r](commonName: String, facts: #{ EquiMatch }): #{ EquiProps | r } =
        let contains = (x, xs) -> match xs {
            case Nil => true
            case _ => List.exists(y -> String.isInfixOf(y, x), xs)
        };
        
        let a1EquiName = LiftingReport/Common.getEquipmentName(commonName) ;

        let rules = #{
            EquiProps(s4type, s4class, fop) :- 
                EquiMatch(equiName, keywords, s4type, s4class, fop),                 
                if String.isSuffixOf(equiName, commonName), 
                if contains(a1EquiName, keywords).
            };
        
        project EquiProps solve facts <+> rules

    pub def rule1[r](): #{ Answer, MemoLine, EquipmentInfo | r } = 
        use LiftingReport/Common.{getEquipmentName, toProperCase};
        #{
            Answer(pliCode, toProperCase(getEquipmentName(commonName)), "H", "2100", memoline) :-
                EquipmentInfo(pliCode, commonName, _, _, _, _, _, _, _, _, _, _),
                MemoLine(pliCode, memoline).
            }

    type alias ReportSources = { aiMemoLinesCsv: String, aiInfosCsv: String }

    pub def makeReport[r](x: ReportSources): Result[#{ Answer | r }, FactIO.Error] & Impure = 
        use Result.flatMap;
        let* aiMemos = LiftingReport/CsvLoader.importMemoLines(x.aiMemoLinesCsv);
        let* aiInfos = LiftingReport/CsvLoader.importEquipmentInfo(x.aiInfosCsv);
        let ans = project Answer solve (rule1() <+> aiMemos <+> aiInfos);
        Ok(ans)

 

}