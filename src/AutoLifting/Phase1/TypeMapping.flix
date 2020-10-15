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

namespace AutoLifting/Phase1/TypeMapping {

    use AutoLifting.ReportMonad;
    use AutoLifting/Datatypes.{FixedOrPortable, S4TypeInfo, EquiWorkItem3, EquiWorkItem4};
    use AutoLifting/Datatypes.FixedOrPortable.{Fixed, Portable};
    use AutoLifting/Phase1/TypeMappingTable.{Distinguished, Ordinary};

    /// TODO
    /// Polymorphic type aliases would make the signatures much nicer but they don't seem to work at the moment...
    /// type alias SourceType[r] = {s4SiteCode: String, aibEquiName: String, aibEquiType: String | r}
    /// type alias AnswerType[r] = {s4TyInfo: S4TypeInfo, s4Floc: String, s4SiteCode: String, aibEquiName: String, aibEquiType: String | r}

    pub def addTypeInfos[r,s](db: #{Distinguished, Ordinary, TypeAnswer | s}, 
                              xs: List[{s4SiteCode: String, aibEquiName: String, aibEquiType: String | r}]): ReportMonad[List[{s4TyInfo: S4TypeInfo, s4Floc: String, s4SiteCode: String, aibEquiName: String, aibEquiType: String | r}]] = 
        AutoLifting/ReportMonad.mapM(addTypeInfo1(db), xs)

    pub def addTypeInfo1[r,s](db: #{Distinguished, Ordinary, TypeAnswer | s}, 
                              x: {s4SiteCode: String, aibEquiName: String, aibEquiType: String | r}): ReportMonad[{s4TyInfo: S4TypeInfo, s4Floc: String, s4SiteCode: String, aibEquiName: String, aibEquiType: String | r}] = 
        use AutoLifting/ReportMonad.{return, throwError};
        match getS4TypeInfo(db, x.aibEquiName, x.aibEquiType) {
            case Some(typ) => { 
                let floc = AutoLifting/Common.flocLocation(x.s4SiteCode, typ.fixedOrPortable);
                return({ +s4TyInfo = typ, +s4Floc = floc | x})
            }
            case None => throwError("No type mapping for ${x.aibEquiName} ${x.aibEquiType}")
        }

    def getS4TypeInfo[s](db: #{Distinguished, Ordinary, TypeAnswer | s}, srcName: String, srcType: String): Option[S4TypeInfo] = 
        match oneOption(distinguishedMatch(db, srcType, srcName)) { 
            case Some(x) => Some(x)
            case None => oneOption(ordinaryMatch(db, srcType))
        }

    pub rel TypeAnswer(category: String, s4Object: String, s4Class: String, fixedOrPortable: String)

    def typeAnswerToS4TypeInfo(src: (String, String, String, String)): S4TypeInfo = 
        let (cat, obj, cls, fop) = src;
        { category = cat, s4Object = obj, s4Class = cls, fixedOrPortable = if (fop == "Fixed") Fixed else Portable }


    def oneOption(xs: List[a]): Option[a] = match xs {
        case x :: Nil   => Some(x)
        case _          => None
    }

    def distinguishedMatch[r](db: #{Distinguished, TypeAnswer | r}, srcType: String, srcName: String): List[S4TypeInfo] = 
        let nameContains = (x, pat) -> Text/Regex.contains(x, Text/Regex/Pattern.irrefutablePattern(pat));
        
        let rules = #{
            TypeAnswer(cat, obj, cls, fop) :- 
                Distinguished(atyp, pat, cat, obj, cls, fop), 
                if atyp == srcType,
                nameContains(srcName, pat).
        };
        let ans = solve (db <+> rules);
        fold TypeAnswer Nil ((x, ac) -> typeAnswerToS4TypeInfo(x) :: ac) ans


    def ordinaryMatch[r](db: #{Ordinary, TypeAnswer | r}, srcType: String): List[S4TypeInfo] = 
        let rules = #{
            TypeAnswer(cat, obj, cls, fop) :- 
                Ordinary(atyp, cat, obj, cls, fop), 
                if atyp == srcType.
        };
        let ans = solve (db <+> rules);
        fold TypeAnswer Nil ((x, ac) -> typeAnswerToS4TypeInfo(x) :: ac) ans


}
