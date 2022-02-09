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

namespace S4Loader/PDT/WorkList {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;
    use SheetIO/Reader.{XlsxSource};

    /// use AssetLib/S4Lite/Datatypes.{SLFunctionalLocation};
    use S4Loader/PDT/Rules/Schema.{EquiWorkItem};


    // Track rowId for error messages
    pub type alias EquiWorkItemRow = 
        { rowId :: Int32
        , uid :: String
        , s4Name :: String
        , s4Floc :: String
        , superEquiId :: String
        , solutionId :: String
        , position :: Option[Int32]
        , batchNumber :: Int32
        , extraMemo :: String
        }

    /// Read from Aib xlsx export file...
    pub def readEquiWorkList(src: XlsxSource): Result[List[EquiWorkItemRow], String] & Impure =
        use SheetIO/NamedRowEvaluator.{optional};
        SheetIO/Reader.someNamedRows(optional(evalEquiWorkItemRow()), src)

    def evalEquiWorkItemRow(): NamedRowEvaluator[EquiWorkItemRow] =
        use SheetIO/NamedRowEvaluator.{flatMap, point, map, getRowNum, 
            getNonEmptyContentNamed, getTrimmedContentNamed, getInt32Named, optional, liftResult}; 
        use AssetLib/Base/S4/SheetIOUtils.{getS4LocalDateNamed}; 
        let* rowId          = getRowNum();
        let* uid            = getNonEmptyContentNamed("PDT uid");
        let* name           = getNonEmptyContentNamed("S4 Equi Name");
        let* floc           = getNonEmptyContentNamed("S4 Floc");
        let* superEqui      = getTrimmedContentNamed("Super Equi");
        let* solutionId     = getTrimmedContentNamed("Solution ID");
        let* position       = optional(getInt32Named("Position"));
        let* batch          = optional(getInt32Named("Batch"));
        let* extraMemo      = getTrimmedContentNamed("Extra Memo");
        point({ rowId           = rowId
                , uid           = uid
                , s4Name        = name
                , s4Floc        = floc
                , superEquiId   = superEqui
                , solutionId    = solutionId
                , position      = position
                , batchNumber   = Option.getWithDefault(1, batch)
                , extraMemo     = extraMemo
                })



    pub def genEquiWorkItems(xs: List[EquiWorkItemRow]): #{EquiWorkItem | r} = 
        RelLib/Relation.foldMap(x1 -> #{ EquiWorkItem(x1.uid, x1.s4Name). }, xs)

    /// pub def genSLFunctionalLocation(x: FlocWorkItemRow): SLFunctionalLocation = 
    ///     let floc    = AssetLib/Base/S4/Floc.new1(x.funcloc);
    ///     let level   = AssetLib/Base/S4/Floc.level(floc);
    ///     let parent  = AssetLib/Base/S4/Floc.parent(floc) |> Option.map(ToString.toString) |> Option.getWithDefault("");
    ///     { funcloc               = x.funcloc
    ///     , description           = x.description
    ///     , category              = level
    ///     , structureIndicator    = x.structureIndicator
    ///     , objectType            = x.objectType
    ///     , startupDate           = x.installedFrom
    ///     , position              = x.position
    ///     , superiorFloc          = parent
    ///     , equipmentInstall      = equipmentInstall(x.structureIndicator, level)
    ///     , status                = "UCON"
    ///     }



}
