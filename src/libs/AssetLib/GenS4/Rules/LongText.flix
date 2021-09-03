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
    use AssetLib/GenS4/Base/CommonRelations.{AibMemoLine, LocationOnSite};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};




    pub def genEquiLongText(worklist: List[EquiWorkItem], 
                            memosSrc: XlsxSource, 
                            locsSrc: XlsxSource): Result[Chain[SLEquiLongText], String] & Impure =
        use Result.{flatMap};
        let workitems   = makeLongTextWorkItems(worklist);
        let* memos      = AssetLib/GenS4/AibFacts/Attributes/MemoLines.readMemoLinesData(memosSrc);
        let* locs       = AssetLib/GenS4/AibFacts/Attributes/LocationData.readLocationOnSiteData(locsSrc);
        let ans         = equiLongText(workitems <+> memos <+> locs);
        Ok(ans) 


    /// Case specific WorkItem so this might be usable to different "EquiWorkList"
    /// although the rules are probably too specific...
    pub rel EquiLongTextWorkItem(equiId: String, equiName: String)

    /// SolutionId specific
    pub def makeLongTextWorkItems(xs: List[EquiWorkItem]): #{EquiLongTextWorkItem | r}  = 
        Relation.foldMap(x1 -> #{ EquiLongTextWorkItem(x1.equipmentId, x1.s4Name). }, xs)



    /// IN PROGRESS - we could have easier (and more flexible rules) if we groupBy `equiId`
    /// as a post-processing step then concatenate the answers to make a `SLEquiLongText` ...

    pub def equiLongText(input: #{EquiLongTextWorkItem, AibMemoLine, LocationOnSite,
                                    EquiLongText | r}): Chain[SLEquiLongText] & Impure = 
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
        let getKey = x1 -> (x1.equiId, x1.description);
        /// TODO - obviously these representation changes need to be minimized...
        solve (rules <+> input) project EquiLongText
            |> AssetLib/S4Lite/S4LiteRelations.toSLEquiLongText
            |> Chain.toArray
            |> Relation/Organization.collectToMapList(getKey, x1 -> x1.longText)
            |> Map.map(String.unlines)
            |> Map.toList
            |> Chain.fromList
            |> Chain.map(xy -> {let (r1, s) = xy; {equiId = fst(r1), description = snd(r1), longText = s}})


    def locationOnSite(location: String): String = "Location on Site: ${String.trim(location)}"

    def memoLine(body: String): String = "Memo Line: ${String.trim(body)}"


}
