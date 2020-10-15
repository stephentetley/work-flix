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

namespace AutoLifting/Phase1/TypeMappingTable {

    use AutoLifting.ReportMonad;

    use SheetIO.SheetReader;
    use SheetIO.NamedRowEvaluator;

    pub rel Distinguished(aibType: String, pattern: String, category: String, s4Object: String, s4Class: String, fixedOrPortable: String)

    pub rel Ordinary(aibType: String, category: String, s4Object: String, s4Class: String, fixedOrPortable: String)

    type alias MappingTableRow = 
        { aibEquipmentType: String
        , nameContains: Option[String]        /// Regex pattern?
        , category: String
        , s4ObjectType: String
        , s4ObjectClass: String
        , fixedOrPortable: String
        }

    pub def readTypeMappingFile[r](path: System.FilePath) : ReportMonad[#{Distinguished, Ordinary | r}] = 
        use AutoLifting/ReportMonad.{return, flatMap, liftActionResult, map};
        let* src = liftActionResult(_ -> SheetIO/SheetReader.runXlsx(readMappingTable(), path));
        return(makeMappings(src))
        

    def readMappingTable(): SheetReader[List[MappingTableRow]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheet, allNamedRows};      
        let* s1     = getSheet("AI2_to_EquiClass");
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
