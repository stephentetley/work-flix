/*
 * Copyright 2021 Stephen Tetley
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


namespace AssetLib/GenS4/WorkListRelations {
    
    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;

    /// Phase 1
    pub rel Phase1EquiItem(aibref: String,
                            s4Name: String,  
                            s4Floc: String,
                            superEqui: String,
                            soultionId: String,
                            position: Option[Int32],
                            s4Category: String, 
                            s4EquiType: String, 
                            s4EquiClass: String)

    
    /// Phase 2
    /// Object Class (e.g. VALVNR) is available directly, we don't have to 
    /// worry about calculating it.
    pub rel Phase2EquiItem(equipmentId: String,  
                            description: String,    /// aka name
                            functionalLocation: String,
                            objectType: String,
                            objectClass: String)


    /// Functional Location (under-developed at the moment)

    pub rel FlocWorkItem(funcloc: String, 
                        description: String, 
                        level: Int32, 
                        installedFrom: Time.LocalDate,
                        structureIndicator: String,
                        objectType: String, 
                        systemClass: String,        /// Level 5 flocs only
                        systemType: String,         /// Level 5 flocs only
                        gridRef: String, 
                        solutionId: String
                        )


    def readWorkList(sheetName: String, eval: NamedRowEvaluator[#{| r}]): SheetReader[#{| r}] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, allNamedRows};  
        use SheetIO/NamedRowEvaluator.{withDefault};
        let* s1     = getSheetNamed(sheetName);
        let* xs     = allNamedRows(s1, withDefault(eval, #{}));
        let relns   = List.foldLeft((ac, x) -> ac <+> x, #{}, xs);
        return(relns)

    


    /// Read from Aib xlsx export file...
    pub def readPhase1EquiWorkList(sheetName: String, 
                                    path: System.FilePath): Result[#{Phase1EquiItem | r}, String] & Impure =
        SheetIO/SheetReader.runXlsx(readWorkList(sheetName, evalPhase1EquiItem()), path)
        
    /// TODO SheetIO should trim by default, provide _Raw functions for non-trimming...
    def evalPhase1EquiItem(): NamedRowEvaluator[#{Phase1EquiItem | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, map, getRowNum, getContentNamed, getNonEmptyContentNamed, optional, getInt32Named}; 
        let* aibref     = map(String.trim, getNonEmptyContentNamed("Reference"));
        let* s4Name     = map(String.trim, getNonEmptyContentNamed("S4 Equi Name"));
        let* s4Floc     = map(String.trim, getNonEmptyContentNamed("S4 Floc"));
        let* superId    = map(String.trim, getContentNamed("Super Equi"));
        let* solutionId = map(String.trim, getContentNamed("Solution ID"));
        let* position   = optional(getInt32Named("Position"));
        let* category   = map(String.trim, getNonEmptyContentNamed("S4 Category"));
        let* s4Type     = map(String.trim, getNonEmptyContentNamed("Equi Type"));
        let* s4Class    = map(String.trim, getContentNamed("Equi Class"));
        return(#{ Phase1EquiItem(aibref, s4Name, s4Floc, superId, solutionId, position, category, s4Type, s4Class). })


    /// Read from Aib xlsx export file...
    pub def readPhase2EquiWorkList(sheetName: String, 
                                    path: System.FilePath): Result[#{Phase2EquiItem | r}, String] & Impure =
        SheetIO/SheetReader.runXlsx(readWorkList(sheetName, evalPhase2EquiItem()), path)
        
    def evalPhase2EquiItem(): NamedRowEvaluator[#{Phase2EquiItem | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, map, getContentNamed, getNonEmptyContentNamed}; 
        let* equiId     = map(String.trim, getNonEmptyContentNamed("Equipment"));
        let* name       = map(String.trim, getNonEmptyContentNamed("Description"));
        let* funcloc    = map(String.trim, getNonEmptyContentNamed("Functional Location"));
        let* objType    = map(String.trim, getNonEmptyContentNamed("Object Type"));
        let* objClass   = map(String.trim, getNonEmptyContentNamed("Object Type Class"));
        return(#{ Phase2EquiItem(equiId, name, funcloc, objType, objClass). })


    /// Flocs

    /// Read from Aib xlsx export file...
    pub def readFlocWorkList(sheetName: String, 
                                path: System.FilePath): Result[#{FlocWorkItem | r}, String] & Impure =
        SheetIO/SheetReader.runXlsx(readFlocs(sheetName), path)
        
    def readFlocs(sheetName: String): SheetReader[#{FlocWorkItem | r}] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, allNamedRows};  
        use SheetIO/NamedRowEvaluator.{withDefault};
        let* s1     = getSheetNamed(sheetName);
        let* xs     = allNamedRows(s1, evalFlocWorkItem());
        let relns   = List.foldLeft((ac, x) -> ac <+> x, #{}, xs);
        return(relns)


    def evalFlocWorkItem(): NamedRowEvaluator[#{FlocWorkItem| r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, map, getNonEmptyContentNamed, getContentNamed}; 
        use AssetLib/Base/S4/SheetIOUtils.{getS4LocalDateNamed}; 
        let* floc           = map(String.trim, getNonEmptyContentNamed("Functional Location"));
        let* name           = map(String.trim, getNonEmptyContentNamed("Description"));
        let* installedFrom  = getS4LocalDateNamed("Installed From");
        let* structureInd   = map(String.trim, getNonEmptyContentNamed("Structure Indicator"));
        let* objType        = map(String.trim, getNonEmptyContentNamed("Object Type"));
        let* sysClass       = map(String.trim, getContentNamed("System Class"));
        let* sysType        = map(String.trim, getContentNamed("System Type"));
        let* ngr            = map(String.trim, getNonEmptyContentNamed("NGR"));
        let* solutionId     = map(String.trim, getContentNamed("Solution Id"));
        let ofloc           = AssetLib/Base/S4/Floc.new(floc);
        let level           = Option.getWithDefault(Option.map(AssetLib/Base/S4/Floc.level, ofloc), 0);
        return(#{ FlocWorkItem(floc, name, level, installedFrom, structureInd, objType, sysClass, sysType, ngr, solutionId). })




}
