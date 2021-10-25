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

    pub type alias FlocWorkItem = 
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
    pub def readFlocWorkList(src: XlsxSource): Result[List[FlocWorkItem], String] & Impure =
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, allNamedRows};
        let readStep = () -> { 
            let* s1     = getSheetNamed(src.sheet);
            let* xs     = allNamedRows(s1, evalFlocWorkItem());
            return(xs)
        };
        SheetIO/SheetReader.runXlsx(readStep(), src.path)

    def evalFlocWorkItem(): NamedRowEvaluator[FlocWorkItem] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, map, getNonEmptyContentNamed, getTrimmedContentNamed, getInt32Named, optional, liftResult}; 
        use AssetLib/Base/S4/SheetIOUtils.{getS4LocalDateNamed}; 
        let* floc           = map(String.trim, getNonEmptyContentNamed("Functional Location"));
        let* name           = map(String.trim, getNonEmptyContentNamed("Description"));
        let* sainums        = map(stringList, getTrimmedContentNamed("Aib References (semi sep list)"));
        let* installedFrom  = getS4LocalDateNamed("Installed From");
        let* structureInd   = map(String.trim, getNonEmptyContentNamed("Structure Indicator"));
        let* objType        = map(String.trim, getNonEmptyContentNamed("Object Type"));
        let* sysClass       = map(String.trim, getTrimmedContentNamed("Class Name (System)"));
        let* sysType        = map(String.trim, getTrimmedContentNamed("System Type (Text)"));
        let* position       = map(FromString.fromString, getTrimmedContentNamed("Position"));
        let* ngr            = map(String.trim, getNonEmptyContentNamed("NGR"));
        let* solutionId     = map(String.trim, getTrimmedContentNamed("Solution ID"));
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
        String.splitOn({substr = ";"}, s)
            |> List.map(String.trim)
            |> List.filter(s1 -> not String.isEmpty(s1))

    /// Equipment

    pub type alias EquiWorkItem = 
        { equipmentId :: String
        , s4Name :: String
        , s4Floc :: String
        , manufacturer :: String
        , model :: String
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
    pub def readEquiWorkList(src: XlsxSource): Result[List[EquiWorkItem], String] & Impure =
        use SheetIO/NamedRowEvaluator.{optional};
        SheetIO/Reader.readSomeNamedRows(src, optional(evalEquiWorkItem()))
        
    /// TODO SheetIO should trim by default, provide _Raw functions for non-trimming...
    /// Note "Equi Class" is now mandatory
    def evalEquiWorkItem(): NamedRowEvaluator[EquiWorkItem] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, map, getRowNum, getTrimmedContentNamed, getNonEmptyContentNamed, optional, getInt32Named}; 
        let* aibref         = map(String.trim, getNonEmptyContentNamed("Reference"));
        let* s4Name         = map(String.trim, getNonEmptyContentNamed("S4 Equi Name"));
        let* s4Floc         = map(String.trim, getNonEmptyContentNamed("S4 Floc"));
        let* manufacturer   = getTrimmedContentNamed("Manufacturer");
        let* model          = getTrimmedContentNamed("Model");
        let* superId        = getTrimmedContentNamed("Super Equi");
        let* solutionId     = getTrimmedContentNamed("Solution ID");
        let* position       = map(FromString.fromString, getTrimmedContentNamed("Position"));
        let* category       = map(String.trim, getNonEmptyContentNamed("S4 Category"));
        let* s4Type         = map(String.trim, getNonEmptyContentNamed("Object Type"));
        let* s4Class        = map(String.trim, getNonEmptyContentNamed("Object Class"));
        let* batchNo        = optional(getInt32Named("Batch"));
        return({ equipmentId = aibref
                , s4Name = s4Name
                , s4Floc = s4Floc
                , manufacturer = manufacturer
                , model = model
                , superEquiId = superId
                , solutionId = solutionId
                , position = position
                , s4Category = category
                , s4EquiType = s4Type
                , s4EquiClass = s4Class
                , batchNumber = Option.getWithDefault(batchNo, 1)
                })


}
