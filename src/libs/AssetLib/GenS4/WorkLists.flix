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
    use SheetIO/Reader.{XlsxSource};
    
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3};


    /// Functional Location 

    type alias FlocWorkItem = 
        { funcloc :: String
        , description :: String
        , level :: Int32
        , sainums :: List[String]
        , installedFrom :: Time.LocalDate
        , structureIndicator :: String
        , objectType :: String 
        , systemClass :: String                   /// Level 5 flocs only
        , systemTypeDescription :: String         /// Level 5 flocs only
        , position :: Option[Int32]
        , gridRef :: String
        , solutionId :: String
        }

    /// Flocs

    /// Read from Aib xlsx export file...
    pub def readFlocWorkList(src: XlsxSource): GenMonad[List[FlocWorkItem]] =
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, allNamedRows};
        let readStep = () -> { 
            let* s1     = getSheetNamed(src.sheet);
            let* xs     = allNamedRows(s1, evalFlocWorkItem());
            return(xs)
        };
        AssetLib/GenS4/GenMonad.liftActionResult(_ -> SheetIO/SheetReader.runXlsx(readStep(), src.path))

    def evalFlocWorkItem(): NamedRowEvaluator[FlocWorkItem] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, map, getNonEmptyContentNamed, getContentNamed, getInt32Named, optional, liftResult}; 
        use AssetLib/Base/S4/SheetIOUtils.{getS4LocalDateNamed}; 
        let* floc           = map(String.trim, getNonEmptyContentNamed("Functional Location"));
        let* name           = map(String.trim, getNonEmptyContentNamed("Description"));
        let* sainums        = map(stringList, getContentNamed("Aib References (semi sep list)"));
        let* installedFrom  = getS4LocalDateNamed("Installed From");
        let* structureInd   = map(String.trim, getNonEmptyContentNamed("Structure Indicator"));
        let* objType        = map(String.trim, getNonEmptyContentNamed("Object Type"));
        let* sysClass       = map(String.trim, getContentNamed("Class Name (System)"));
        let* sysType        = map(String.trim, getContentNamed("System Type (Text)"));
        let* position       = optional(getInt32Named("Position"));
        let* ngr            = map(String.trim, getNonEmptyContentNamed("NGR"));
        let* solutionId     = map(String.trim, getContentNamed("Solution ID"));
        let* objfloc        = liftResult(AssetLib/Base/S4/Floc.new(floc), msg -> msg);
        let level           = AssetLib/Base/S4/Floc.level(objfloc);
        return({ funcloc                = floc
                , description           = name
                , level                 = level
                , sainums               = sainums
                , installedFrom         = installedFrom
                , structureIndicator    = structureInd
                , objectType            = objType
                , systemClass           = sysClass
                , systemTypeDescription = sysType
                , position              = position
                , gridRef               = ngr
                , solutionId            = solutionId
                })

    def stringList(s: String): List[String] = 
        String.splitOn(s, ";")
            |> List.map(String.trim)
            |> List.filter(s1 -> not String.isEmpty(s1))

    /// Equipment

    type alias EquiWorkItem = 
        { equipmentId :: String
        , s4Name :: String
        , s4Floc :: String
        , superEquiId :: String
        , solutionId :: String
        , position :: Option[Int32]
        , s4Category :: String
        , s4EquiType :: String
        , s4EquiClass :: String
        , batchNumber :: Int32
        }


    pub def makeEquiWorkItem3(xs: List[EquiWorkItem]): #{EquiWorkItem3 | r}  = 
        RelLib/Relation.foldMap(x1 -> #{ EquiWorkItem3(x1.equipmentId, x1.s4EquiType, x1.s4EquiClass). }, xs)


    /// Read from Aib xlsx export file...
    pub def readEquiWorkList(src: XlsxSource): GenMonad[List[EquiWorkItem]] =
        use SheetIO/NamedRowEvaluator.{optional};
        AssetLib/GenS4/GenMonad.liftActionResult(_ -> SheetIO/Reader.readSomeNamedRows(src, optional(evalEquiWorkItem())))
        
    /// TODO SheetIO should trim by default, provide _Raw functions for non-trimming...
    /// Note "Equi Class" is now mandatory
    def evalEquiWorkItem(): NamedRowEvaluator[EquiWorkItem] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, map, getRowNum, getContentNamed, getNonEmptyContentNamed, optional, getInt32Named}; 
        let* aibref     = map(String.trim, getNonEmptyContentNamed("Reference"));
        let* s4Name     = map(String.trim, getNonEmptyContentNamed("S4 Equi Name"));
        let* s4Floc     = map(String.trim, getNonEmptyContentNamed("S4 Floc"));
        let* superId    = map(String.trim, getContentNamed("Super Equi"));
        let* solutionId = map(String.trim, getContentNamed("Solution ID"));
        let* position   = optional(getInt32Named("Position"));
        let* category   = map(String.trim, getNonEmptyContentNamed("S4 Category"));
        let* s4Type     = map(String.trim, getNonEmptyContentNamed("Object Type"));
        let* s4Class    = map(String.trim, getNonEmptyContentNamed("Object Class"));
        let* batchNo    = optional(getInt32Named("Batch"));
        return({ equipmentId = aibref
                , s4Name = s4Name
                , s4Floc = s4Floc
                , superEquiId = superId
                , solutionId = solutionId
                , position = position
                , s4Category = category
                , s4EquiType = s4Type
                , s4EquiClass = s4Class
                , batchNumber = Option.getWithDefault(batchNo, 1)
                })


 




}
