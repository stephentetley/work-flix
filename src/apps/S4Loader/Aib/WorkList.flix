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

namespace S4Loader/Aib/WorkList {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;
    use SheetIO/Reader.{XlsxSource};

    use S4Loader/Base/Schema.{StringProperty, EquiWorkItem3};


    /// Equipment
    pub type alias EquiWorkItem = 
        { rowId :: Int32
        , equipmentId :: String
        , s4Name :: String
        , s4Floc :: String
        , superEquiId :: String
        , solutionId :: String
        , position :: Option[Int32]
        , s4Category :: String
        , s4EquiType :: String
        , s4EquiClass :: String
        , batchNumber :: Int32
        , extraMemo :: String
        }


    pub def makeEquiWorkRelations(xs: List[EquiWorkItem]): #{EquiWorkItem3, StringProperty | r}  = 
        let makeEquiWorkItem3 = x1 -> #{ EquiWorkItem3(x1.equipmentId, x1.s4EquiType, x1.s4EquiClass). };
        RelLib/Relation.foldMap(x1 -> makeEquiWorkItem3(x1) <+> makeExtraProperties(x1), xs)

    // @S4_NAME needed for longText
    def makeExtraProperties(x: EquiWorkItem): #{EquiWorkItem3, StringProperty | r} = 
        use RelLib/Relation.{whenTrue};
        whenTrue(not String.isEmpty(x.s4Name), #{ StringProperty(x.equipmentId, "@S4_NAME", x.s4Name). })
            <+> whenTrue(not String.isEmpty(x.solutionId), #{ StringProperty(x.equipmentId, "@SOLUTION_ID", x.solutionId). })
            <+> whenTrue(not String.isEmpty(x.extraMemo),  #{ StringProperty(x.equipmentId, "@EXTRA_MEMO", x.extraMemo). })




    /// Read from Aib xlsx export file...
    pub def readEquiWorkList(src: XlsxSource): Result[List[EquiWorkItem], String] & Impure =
        use SheetIO/NamedRowEvaluator.{optional};
        SheetIO/Reader.someNamedRows(optional(evalEquiWorkItem()), src)
        
    /// TODO SheetIO should trim by default, provide _Raw functions for non-trimming...
    /// Note "Equi Class" is now mandatory
    /// `getNonEmptyContentNamed` trims input.
    def evalEquiWorkItem(): NamedRowEvaluator[EquiWorkItem] =
        use SheetIO/NamedRowEvaluator.{flatMap, point, map, getRowNum, getTrimmedContentNamed, getNonEmptyContentNamed, optional, getInt32Named}; 
        let* rowId          = getRowNum();
        let* aibref         = getNonEmptyContentNamed("Reference");
        let* s4Name         = getNonEmptyContentNamed("S4 Equi Name");
        let* s4Floc         = getNonEmptyContentNamed("S4 Floc");
        let* superId        = getTrimmedContentNamed("Super Equi");
        let* solutionId     = getTrimmedContentNamed("Solution ID");
        let* position       = map(FromString.fromString, getTrimmedContentNamed("Position"));
        let* category       = getNonEmptyContentNamed("S4 Category");
        let* s4Type         = getNonEmptyContentNamed("Object Type");
        let* s4Class        = getNonEmptyContentNamed("Object Class");
        let* batchNo        = optional(getInt32Named("Batch"));
        let* extraMemo      = getTrimmedContentNamed("Extra Memo");
        point({ rowId           = rowId
                , equipmentId   = aibref
                , s4Name        = s4Name
                , s4Floc        = s4Floc
                , superEquiId   = superId
                , solutionId    = solutionId
                , position      = position
                , s4Category    = category
                , s4EquiType    = s4Type
                , s4EquiClass   = s4Class
                , batchNumber   = Option.getWithDefault(1, batchNo)
                , extraMemo     = extraMemo
                })

}
