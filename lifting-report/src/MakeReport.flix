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

use LiftingReport/Relations.{EquiMatch, FixedOrPortable, EquiProps};
use LiftingReport/Relations.FixedOrPortable.{Fixed, Portable};

namespace LiftingReport/MakeReport {


    pub def tempFacts[r](): #{ EquiMatch | r} = 
        #{ 
            EquiMatch("EQUIPMENT: BEAM CLAMP", Nil, "LIAC", "LIACBC", Portable).
            EquiMatch("EQUIPMENT: BEAM TROLLEY", Nil , "CRHT", "CRHTBT", Fixed).
            EquiMatch("EQUIPMENT: BEAMS - LIFTING AND SPREADING", "SPREAD" :: Nil, "CRHT", "CRHTLS", Fixed).
            EquiMatch("EQUIPMENT: BEAMS - LIFTING AND SPREADING", "FRAME" :: Nil, "LIAC", "LIACLF", Fixed).
        }

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

}