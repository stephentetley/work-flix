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
    use Compatibility.{XlsxSource};
    
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
        , batchNumber :: Int32
        }

    /// Flocs

    /// Read from Aib xlsx export file...
    pub def readFlocWorkList(src: XlsxSource): Result[List[FlocWorkItem], String] & Impure =
        SheetIO/Reader.allNamedRows(evalFlocWorkItem(), src)

    def evalFlocWorkItem(): NamedRowEvaluator[FlocWorkItem] =
        use SheetIO/NamedRowEvaluator.{flatMap, point, map, getNonEmptyContentNamed, getTrimmedContentNamed, getInt32Named, optional, liftResult}; 
        use AssetLib/Base/S4/SheetIOUtils.{getS4LocalDateNamed}; 
        let* floc1          = getNonEmptyContentNamed("Functional Location");
        let* name           = getNonEmptyContentNamed("Description");
        let* sainums        = getTrimmedContentNamed("Aib References (semi sep list)");
        let* installedFrom  = getS4LocalDateNamed("Installed From (dd.MM.yyyy)");
        let* structureInd   = getNonEmptyContentNamed("Structure Indicator");
        let* objType        = getNonEmptyContentNamed("Object Type");
        let* sysClass       = getTrimmedContentNamed("Class Name (System)");
        let* sysType        = getTrimmedContentNamed("System Type (Text)");
        let* position       = optional(getInt32Named("Position"));
        let* ngr            = getNonEmptyContentNamed("NGR");
        let* solutionId     = getTrimmedContentNamed("Solution ID");
        let* objfloc        = liftResult(AssetLib/Base/S4/Floc.floc(floc1));
        let* batch          = optional(getInt32Named("Batch"));
        point({ funcloc                = floc1
                , description           = name
                , level                 = AssetLib/Base/S4/Floc.level(objfloc)
                , sainums               = stringList(sainums)
                , installedFrom         = installedFrom
                , structureIndicator    = structureInd
                , objectType            = objType
                , systemClass           = sysClass
                , systemTypeDescription = sysType
                , position              = position
                , gridRef               = ngr
                , solutionId            = solutionId
                , batchNumber           = Option.getWithDefault(1, batch)
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
        , extraMemo :: String
        }


    pub def makeEquiWorkItem3(xs: List[EquiWorkItem]): #{EquiWorkItem3 | r}  = 
        RelLib/Relation.foldMap(x1 -> #{ EquiWorkItem3(x1.equipmentId, x1.s4EquiType, x1.s4EquiClass). }, xs)


    /// Read from Aib xlsx export file...
    pub def readEquiWorkList(src: XlsxSource): Result[List[EquiWorkItem], String] & Impure =
        use SheetIO/NamedRowEvaluator.{optional};
        SheetIO/Reader.someNamedRows(optional(evalEquiWorkItem()), src)
        
    /// TODO SheetIO should trim by default, provide _Raw functions for non-trimming...
    /// Note "Equi Class" is now mandatory
    /// `getNonEmptyContentNamed` trims input.
    def evalEquiWorkItem(): NamedRowEvaluator[EquiWorkItem] =
        use SheetIO/NamedRowEvaluator.{flatMap, point, map, getRowNum, getTrimmedContentNamed, getNonEmptyContentNamed, optional, getInt32Named}; 
        let* aibref         = getNonEmptyContentNamed("Reference");
        let* s4Name         = getNonEmptyContentNamed("S4 Equi Name");
        let* s4Floc         = getNonEmptyContentNamed("S4 Floc");
        let* manufacturer   = getTrimmedContentNamed("Manufacturer");
        let* model          = getTrimmedContentNamed("Model");
        let* superId        = getTrimmedContentNamed("Super Equi");
        let* solutionId     = getTrimmedContentNamed("Solution ID");
        let* position       = map(FromString.fromString, getTrimmedContentNamed("Position"));
        let* category       = getNonEmptyContentNamed("S4 Category");
        let* s4Type         = getNonEmptyContentNamed("Object Type");
        let* s4Class        = getNonEmptyContentNamed("Object Class");
        let* batchNo        = optional(getInt32Named("Batch"));
        let* extraMemo      = getTrimmedContentNamed("Extra Memo");
        point({ equipmentId = aibref
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
                , batchNumber = Option.getWithDefault(1, batchNo)
                , extraMemo = extraMemo
                })


}
