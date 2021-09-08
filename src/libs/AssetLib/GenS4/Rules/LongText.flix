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


namespace AssetLib/GenS4/Rules/LongText {


    use SheetIO/Reader.{XlsxSource};

    use AssetLib/S4Lite/Datatypes.{SLEquiLongText};
    use AssetLib/S4Lite/S4LiteRelations.{EquiLongText};
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/Base/CommonRelations.{AibMemoLine, LocationOnSite};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};




    pub def genEquiLongText(worklist: List[EquiWorkItem], 
                            memosSrc: XlsxSource, 
                            locsSrc: XlsxSource): GenMonad[Unit] =
        use AssetLib/GenS4/GenMonad.{flatMap};
        let workitems   = makeLongTextWorkItems(worklist);
        let* memos      = AssetLib/GenS4/AibFacts/Attributes/MemoLines.readMemoLinesData(memosSrc);
        let* locs       = AssetLib/GenS4/AibFacts/Attributes/LocationData.readLocationOnSiteData(locsSrc);
        equiLongText(workitems <+> memos <+> locs)


    /// Case specific WorkItem so this might be usable to different "EquiWorkList"
    /// although the rules are probably too specific...
    pub rel EquiLongTextWorkItem(equiId: String, equiName: String)

    /// SolutionId specific
    pub def makeLongTextWorkItems(xs: List[EquiWorkItem]): #{EquiLongTextWorkItem | r}  = 
        RelLib/Relation.foldMap(x1 -> #{ EquiLongTextWorkItem(x1.equipmentId, x1.s4Name). }, xs)



    /// IN PROGRESS - we could have easier (and more flexible rules) if we groupBy `equiId`
    /// as a post-processing step then concatenate the answers to make a `SLEquiLongText` ...

    pub def equiLongText(input: #{EquiLongTextWorkItem, AibMemoLine, LocationOnSite,
                                    EquiLongText | r}): GenMonad[Unit] = 
        use AssetLib/GenS4/GenMonad.{flatMap, liftAction};
        let rules = #{

            EquiLongText(equiId, description, locationOnSite(location) ) :- 
                EquiLongTextWorkItem(equiId, description),
                LocationOnSite(equiId, location), 
                if (String.length(location) > 30).

            EquiLongText(equiId, description, memoLine(memoText)) :- 
                EquiLongTextWorkItem(equiId, description),
                AibMemoLine(equiId, memoText), 
                if (String.length(memoText) > 30).
        };
        let getKey = RelLib/Tuple.decons3((x1, y1, _) -> (x1, y1));
        let getLongText = RelLib/Tuple.decons3((_, _, z1) -> z1);
        let* answers = liftAction(_ -> query (rules <+> input) select (x1, x2, x3) from EquiLongText(x1, x2, x3)
                        |> RelLib/Organization.collectToMapList(getKey, getLongText)
                        |> Map.toList
                        |> List.map(xy -> {let ((x1, x2), xs) = xy; {equiId = x1, description = x2, longText = String.unlines(xs)}}));
        AssetLib/GenS4/GenMonad.mapX(AssetLib/GenS4/GenMonad.tellSLEquiLongText, answers)



    def locationOnSite(location: String): String = "Location on Site: ${String.trim(location)}"

    def memoLine(body: String): String = "Memo Line: ${String.trim(body)}"


}
