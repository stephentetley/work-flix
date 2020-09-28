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

    use AutoLifting/Datatypes.FixedOrPortable;
    use AutoLifting/Datatypes.FixedOrPortable.{Fixed, Portable};
    use AutoLifting/MappingTable.{Distinguished, Ordinary};


    def oneOption(xs: List[a]): Option[a] = match xs {
        case x :: Nil   => Some(x)
        case _          => None
    }

    pub rel TypeAnswer(category: String, s4Object: String, s4Class: String, fixedOrPortable: String)



    type alias S4TypeInfo = 
        { category: String 
        , s4Object: String
        , s4Class: String
        , fixedOrPortable: FixedOrPortable
        }

    pub def showS4TypeInfo(x: S4TypeInfo): String = 
        let fop = match x.fixedOrPortable { 
                    case Fixed => "Fixed"
                    case Portable => "Portable"
        };
        "<${x.category}, ${x.s4Object}, ${x.s4Class}, ${fop}>"

    def typeAnswerToS4TypeInfo(src: (String, String, String, String)): S4TypeInfo = 
        let (cat, obj, cls, fop) = src;
        { category = cat, s4Object = obj, s4Class = cls, fixedOrPortable = if (fop == "Fixed") Fixed else Portable }


    pub def getS4TypeInfo[r](db: #{Distinguished, Ordinary, TypeAnswer | r}, srcName: String, srcType: String): Option[S4TypeInfo] = 
        match oneOption(distinguishedMatch(db, srcType, srcName)) { 
            case Some(x) => Some(x)
            case None => oneOption(ordinaryMatch(db, srcType))
        }

    pub def distinguishedMatch[r](db: #{Distinguished, TypeAnswer | r}, srcType: String, srcName: String): List[S4TypeInfo] = 
        let nameContains = (x, pat) -> Text/Regex.contains(x, Text/Regex/Pattern.irrefutablePattern(pat));
        
        let rules = #{
            TypeAnswer(cat, obj, cls, fop) :- 
                Distinguished(atyp, pat, cat, obj, cls, fop), 
                if atyp == srcType,
                nameContains(srcName, pat).
        };
        let ans = solve (db <+> rules);
        fold TypeAnswer Nil ((x, ac) -> typeAnswerToS4TypeInfo(x) :: ac) ans


    pub def ordinaryMatch[r](db: #{Ordinary, TypeAnswer | r}, srcType: String): List[S4TypeInfo] = 
        let rules = #{
            TypeAnswer(cat, obj, cls, fop) :- 
                Ordinary(atyp, cat, obj, cls, fop), 
                if atyp == srcType.
        };
        let ans = solve (db <+> rules);
        fold TypeAnswer Nil ((x, ac) -> typeAnswerToS4TypeInfo(x) :: ac) ans


}
