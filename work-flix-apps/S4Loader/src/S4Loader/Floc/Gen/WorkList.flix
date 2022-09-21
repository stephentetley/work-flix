/*
 * Copyright 2022 Stephen Tetley
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

namespace S4Loader/Floc/Gen/WorkList {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;
    use Compatibility.{XlsxSource};

    use S4Loader/Base/Schema.{StringProperty, IntProperty};


    pub rel FlocWorkItem(s4Floc: String, level: Int32)


    // Track rowId for error messages
    pub type alias FlocWorkItemRow = 
        { rowId :: Int32
        , funcloc :: String
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

    /// Read from Aib xlsx export file...
    pub def readFlocWorkList(src: XlsxSource): Result[List[FlocWorkItemRow], String] & Impure =
        use SheetIO/NamedRowEvaluator.{optional}; 
        SheetIO/Reader.someNamedRows(optional(evalFlocWorkItem()), src)

    def evalFlocWorkItem(): NamedRowEvaluator[FlocWorkItemRow] =
        use SheetIO/NamedRowEvaluator.{flatMap, point, map, getRowNum, 
            getNonEmptyContentNamed, getTrimmedContentNamed, getInt32Named, optional, liftResult}; 
        use AssetLib/Base/S4/SheetIOUtils.{getS4LocalDateNamed}; 
        let* rowId          = getRowNum();
        let* floc           = getNonEmptyContentNamed("Functional Location");
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
        let objfloc         = AssetLib/Base/S4/Floc.floc1(floc);
        let* batch          = optional(getInt32Named("Batch"));
        point({ rowId                   = rowId
                , funcloc               = floc
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


    pub def genProperties(xs: List[FlocWorkItemRow]): #{StringProperty, IntProperty | r} = 
        RelLib/Relation.foldMap(makeProperties1, xs)
        

    def makeProperties1(x: FlocWorkItemRow): #{StringProperty, IntProperty | r} = 
        use RelLib/Relation.{whenTrue, foldMap};
        #{ StringProperty(x.funcloc, "@GRID_REF", x.gridRef). }
            <+> whenTrue(not String.isEmpty(x.solutionId),              #{ StringProperty(x.funcloc, "@SOLUTION_ID", x.solutionId). })
            <+> whenTrue(not String.isEmpty(x.systemClass),             #{ StringProperty(x.funcloc, "@CLASS_NAME", x.systemClass). })
            <+> whenTrue(not String.isEmpty(x.systemTypeDescription),   #{ StringProperty(x.funcloc, "@SYSTEM_DESCR", x.systemTypeDescription). })
            <+> foldMap(s1 -> #{ StringProperty(x.funcloc, "@AIB_REFERENCE", s1). }, x.sainums)


    pub def genFlocWorkItems(xs: List[FlocWorkItemRow]): #{FlocWorkItem | r} = 
        RelLib/Relation.foldMap(x1 -> #{ FlocWorkItem(x1.funcloc, x1.level). }, xs)

}
