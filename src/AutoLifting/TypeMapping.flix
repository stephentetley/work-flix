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

namespace AutoLifting/TypeMapping {

    pub rel Distinguished(aibType: String, pattern: String, category: String, s4Object: String, s4Class: String, fixedOrPortable: String)

    pub rel Oridnary(aibType: String, category: String, s4Object: String, s4Class: String, fixedOrPortable: String)

    pub rel TypeAnswer(category: String, s4Object: String, s4Class: String, fixedOrPortable: String)

    pub enum FixedOrPortable { 
        case Fixed
        case Portable
    }

    type alias Answer = 
        { category: String 
        , s4Object: String
        , s4Class: String
        , fixedOrPortable: FixedOrPortable
        }

    pub def showAnswer(x: Answer): String = 
        let fop = match x.fixedOrPortable { 
                    case Fixed => "Fixed"
                    case Portable => "Portable"
        };
        "<${x.category}, ${x.s4Object}, ${x.s4Class}, ${fop}>"

    def typeAnswerToAnswer(src: (String, String, String, String)): Answer = 
        let (cat, obj, cls, fop) = src;
        { category = cat, s4Object = obj, s4Class = cls, fixedOrPortable = if (fop == "Fixed") Fixed else Portable }


    pub def distinguishedMatch[r](db: #{Distinguished, TypeAnswer | r}, srcType: String, srcName: String): List[Answer] = 
        let nameContains = (x, pat) -> Text/Regex.contains(x, Text/Regex/Pattern.irrefutablePattern(pat));
        
        let rules = #{
            TypeAnswer(cat, obj, cls, fop) :- 
                Distinguished(atyp, pat, cat, obj, cls, fop), 
                if atyp == srcType,
                nameContains(srcName, pat).
        };
        let ans = solve (db <+> rules);
        fold TypeAnswer Nil ((x, ac) -> typeAnswerToAnswer(x) :: ac) ans





}
