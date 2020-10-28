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

    
    use SheetIO.SheetReader;
    use SheetIO.NamedRowEvaluator;

    use AutoLifting/Common.ReportMonad;
    use AutoLifting/Common/Datatypes.{FixedOrPortable, S4TypeInfo, EquiWorkItem3, EquiWorkItem4};
    use AutoLifting/Common/Datatypes.FixedOrPortable.{Fixed, Portable};
    
    pub rel Distinguished(aibType: String, pattern: String, category: String, s4Object: String, s4Class: String, fixedOrPortable: String)

    pub rel Ordinary(aibType: String, category: String, s4Object: String, s4Class: String, fixedOrPortable: String)

    pub rel TypeAnswer(category: String, s4Object: String, s4Class: String, fixedOrPortable: String)


    pub def getTypeInfo[s]( db: #{Distinguished, Ordinary, TypeAnswer | s}
                          , x: {s4SiteCode: String, aibEquiName: String, aibEquiType: String}): ReportMonad[{s4TyInfo: S4TypeInfo, s4Floc: String}] = 
        use AutoLifting/Common/ReportMonad.{return, throwError};
        match getS4TypeInfo(db, x.aibEquiName, x.aibEquiType) {
            case Some(typ) => { 
                let floc = AutoLifting/Common/Utils.flocLocation(x.s4SiteCode, typ.fixedOrPortable);
                return({ s4TyInfo = typ, s4Floc = floc})
            }
            case None => throwError("No type mapping for ${x.aibEquiName} ${x.aibEquiType}")
        }



    def getS4TypeInfo[s](db: #{Distinguished, Ordinary, TypeAnswer | s}, srcName: String, srcType: String): Option[S4TypeInfo] = 
        match oneOption(distinguishedMatch(db, srcType, srcName)) { 
            case Some(x) => Some(x)
            case None => oneOption(ordinaryMatch(db, srcType))
        }

    

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




    /// Build Type Mapping Table...

    type alias MappingTableRow = 
        { aibEquipmentType: String
        , nameContains: Option[String]        /// Regex pattern?
        , category: String
        , s4ObjectType: String
        , s4ObjectClass: String
        , fixedOrPortable: String
        }

    pub def readTypeMappingFile[s](path: System.FilePath) : ReportMonad[#{Distinguished, Ordinary | s}] = 
        use AutoLifting/Common/ReportMonad.{return, flatMap, liftActionResult, map};
        let* src = liftActionResult(_ -> SheetIO/SheetReader.runXlsx(readMappingTable(), path));
        return(makeMappings(src))
        

    def readMappingTable(): SheetReader[List[MappingTableRow]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, allNamedRows};      
        let* s1     = getSheetNamed("AI2_to_EquiClass");
        let* xs     = allNamedRows(s1, evalMappingTableRow());
        return(xs)


    // AI2 Equi Type, Name Contains, Category, Object Type, Classification, S4 Description (in classes export Pdf), Fixed or Portable
    def evalMappingTableRow(): NamedRowEvaluator[MappingTableRow] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, optional, getStringNamed, getStringNamedWithDefault};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((s1, s2, s3, s4, s5, s6) -> 
                { aibEquipmentType  = s1
                , nameContains      = s2
                , category          = s3
                , s4ObjectType      = s4
                , s4ObjectClass     = s5
                , fixedOrPortable   = s6
                })
            <&> getStringNamed("AI2 Equi Type")
            <*> optional(getStringNamed("Name Contains"))
            <*> getStringNamed("Category")
            <*> getStringNamed("Object Type")
            <*> getStringNamed("Classification")
            <*> getStringNamed("Fixed or Portable")

    /// TODO - could compile regex pattern at this point so we have control of Pattern.compile errors
    def makeMappings[r](xs: List[MappingTableRow]): #{Distinguished, Ordinary | r} = 
        List.foldLeft((ac,x) -> ac <+> makeSingleMapping(x), #{}, xs)

    def makeSingleMapping[r](x: MappingTableRow): #{Distinguished, Ordinary | r} = 
        match x.nameContains { 
            case Some(pat) => Distinguished(x.aibEquipmentType, pat, x.category, x.s4ObjectType, x.s4ObjectClass, x.fixedOrPortable).
            case None => Ordinary(x.aibEquipmentType, x.category, x.s4ObjectType, x.s4ObjectClass, x.fixedOrPortable).
        } 


}
