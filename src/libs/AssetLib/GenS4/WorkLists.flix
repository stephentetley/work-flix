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


namespace AssetLib/GenS4/WorkLists {
    
    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;

    type alias EquipmentWorkItem = 
        { equipmentId: String
        , s4Name: String
        , s4Floc: String
        , superEquiId: String
        , solutionId: String
        , position: Option[Int32]
        , s4Category: String
        , s4EquiType: String
        , s4EquiClass: String
        }



    /// `equipmentId` (and `superEquiId`) will get transposed by S4Lite
    /// `s4EquiClass` should be mandatory (even for valves) this simplifies things significatly.
    /// Arity 9
    pub rel EquiWorkItem(equipmentId: String,
                            s4Name: String,  
                            s4Floc: String,
                            superEquiId: String,
                            solutionId: String,
                            position: Option[Int32],
                            s4Category: String, 
                            s4EquiType: String, 
                            s4EquiClass: String)

    pub def makeEquiWorkItems(xs: List[EquipmentWorkItem]): #{ EquiWorkItem | r} = 
        List.foldLeft((ac, a) -> ac <+> makeEquiWorkItem(a), #{}, xs)

    pub def makeEquiWorkItem(x: EquipmentWorkItem): #{ EquiWorkItem | r} = #{
        EquiWorkItem(x.equipmentId,
                        x.s4Name,  
                        x.s4Floc,
                        x.superEquiId,
                        x.solutionId,
                        x.position,
                        x.s4Category, 
                        x.s4EquiType, 
                        x.s4EquiClass).
    }

    /// Functional Location (under-developed at the moment)

    type alias FunclocWorkItem = 
        { funcloc: String
        , description: String
        , level: Int32
        , sainum: String
        , installedFrom: Time.LocalDate
        , structureIndicator: String
        , objectType: String 
        , systemClass: String                   /// Level 5 flocs only
        , systemTypeDescription: String         /// Level 5 flocs only
        , gridRef: String
        , solutionId: String
        }


    pub rel FlocWorkItem(funcloc: String, 
                        description: String, 
                        level: Int32, 
                        sainum: String,
                        installedFrom: Time.LocalDate,
                        structureIndicator: String,
                        objectType: String, 
                        systemClass: String,        /// Level 5 flocs only
                        systemTypeDescription: String,         /// Level 5 flocs only
                        gridRef: String, 
                        solutionId: String
                        )

    pub def makeFlocWorkItems(xs: List[FunclocWorkItem]): #{FlocWorkItem | r} = 
        List.foldLeft((ac, a) -> ac <+> makeFlocWorkItem(a), #{}, xs)


    pub def makeFlocWorkItem(x: FunclocWorkItem): #{ FlocWorkItem | r}= #{
        FlocWorkItem(x.funcloc, 
                        x.description, 
                        x.level,
                        x.sainum,
                        x.installedFrom,
                        x.structureIndicator,
                        x.objectType, 
                        x.systemClass,
                        x.systemTypeDescription,
                        x.gridRef, 
                        x.solutionId).
    }
  


    /// Read from Aib xlsx export file...
    pub def readEquiWorkList(sheetName: String, 
                            path: System.FilePath): Result[List[EquipmentWorkItem], String] & Impure =
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, someNamedRows};
        let readStep = () -> { 
            let* s1     = getSheetNamed(sheetName);
            let* xs     = someNamedRows(s1, evalEquiWorkItem());
            return(xs)
        };
        SheetIO/SheetReader.runXlsx(readStep(), path)
        
    /// TODO SheetIO should trim by default, provide _Raw functions for non-trimming...
    /// Note "Equi Class" is now mandatory
    def evalEquiWorkItem(): NamedRowEvaluator[EquipmentWorkItem] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, map, getRowNum, getContentNamed, getNonEmptyContentNamed, optional, getInt32Named}; 
        let* aibref     = map(String.trim, getNonEmptyContentNamed("Reference"));
        let* s4Name     = map(String.trim, getNonEmptyContentNamed("S4 Equi Name"));
        let* s4Floc     = map(String.trim, getNonEmptyContentNamed("S4 Floc"));
        let* superId    = map(String.trim, getContentNamed("Super Equi"));
        let* solutionId = map(String.trim, getContentNamed("Solution ID"));
        let* position   = optional(getInt32Named("Position"));
        let* category   = map(String.trim, getNonEmptyContentNamed("S4 Category"));
        let* s4Type     = map(String.trim, getNonEmptyContentNamed("Equi Type"));
        let* s4Class    = map(String.trim, getNonEmptyContentNamed("Equi Class"));
        return({ equipmentId = aibref
                , s4Name = s4Name
                , s4Floc = s4Floc
                , superEquiId = superId
                , solutionId = solutionId
                , position = position
                , s4Category = category
                , s4EquiType = s4Type
                , s4EquiClass = s4Class
                })


 
    pub def getEquipmentWorkItemKeyMap(xs: List[EquipmentWorkItem]): Map[String, String] =
        let dict1 = buildKeyToDesc(xs);
        List.foldLeft((ac, x) ->  Map.insert(x.equipmentId, makeThreePartName(x, dict1), ac), Map.empty(), xs)
        
    def buildKeyToDesc(xs: List[EquipmentWorkItem]): Map[String, String] = 
        List.foldLeft((ac, x) -> Map.insert(x.equipmentId, x.s4Name, ac), Map.empty(), xs)

    def makeThreePartName(x: EquipmentWorkItem, descs: Map[String, String]): String = 
        if (not String.isEmpty(x.superEquiId)) {
            let superDesc = Map.getWithDefault(x.equipmentId, "Impossible", descs);
            "${x.s4Name}::${x.s4Floc}::${superDesc}"
        } else "${x.s4Name}::${x.s4Floc}::NO_SUPER"


    /// Flocs

    /// Read from Aib xlsx export file...
    pub def readFlocWorkList(sheetName: String, 
                                path: System.FilePath): Result[List[FunclocWorkItem], String] & Impure =
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, allNamedRows};
        let readStep = () -> { 
            let* s1     = getSheetNamed(sheetName);
            let* xs     = allNamedRows(s1, evalFlocWorkItem());
            return(xs)
        };
        SheetIO/SheetReader.runXlsx(readStep(), path)

    def evalFlocWorkItem(): NamedRowEvaluator[FunclocWorkItem] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, map, getNonEmptyContentNamed, getContentNamed}; 
        use AssetLib/Base/S4/SheetIOUtils.{getS4LocalDateNamed}; 
        let* floc           = map(String.trim, getNonEmptyContentNamed("Functional Location"));
        let* name           = map(String.trim, getNonEmptyContentNamed("Description"));
        let* sainum         = map(String.trim, getNonEmptyContentNamed("Aib Reference"));
        let* installedFrom  = getS4LocalDateNamed("Installed From");
        let* structureInd   = map(String.trim, getNonEmptyContentNamed("Structure Indicator"));
        let* objType        = map(String.trim, getNonEmptyContentNamed("Object Type"));
        let* sysClass       = map(String.trim, getContentNamed("Class Name (System)"));
        let* sysType        = map(String.trim, getContentNamed("System Type (Text)"));
        let* ngr            = map(String.trim, getNonEmptyContentNamed("NGR"));
        let* solutionId     = map(String.trim, getContentNamed("Solution ID"));
        let ofloc           = AssetLib/Base/S4/Floc.new(floc);
        let level           = Option.getWithDefault(Option.map(AssetLib/Base/S4/Floc.level, ofloc), 0);
        return({ funcloc = floc
                , description = name
                , level = level
                , sainum = sainum
                , installedFrom = installedFrom
                , structureIndicator = structureInd
                , objectType = objType
                , systemClass = sysClass
                , systemTypeDescription = sysType
                , gridRef = ngr
                , solutionId = solutionId
                })
        
}
