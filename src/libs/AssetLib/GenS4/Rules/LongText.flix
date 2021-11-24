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
        let* memos1     = AssetLib/GenS4/AibFacts/Attributes/MemoLines.readMemoLinesData(memosSrc);
        /// Always make as LongText1 rather than AibMemoLine so it will always go in S4 Long Text...
        let memos2      = RelLib/Relation.foldMap(x1 -> 
                            if (not String.isEmpty(x1.extraMemo)) #{ LongText1(x1.equipmentId; Set.singleton(x1.extraMemo)). } else #{}, worklist);
        let* locs       = AssetLib/GenS4/AibFacts/Attributes/LocationData.readLocationOnSiteData(locsSrc);
        equiLongText(workitems <+> memos1 <+> memos2 <+> locs)


    /// Case specific WorkItem so this might be usable to different "EquiWorkList"
    /// although the rules are probably too specific...
    pub rel EquiLongTextWorkItem(equiId: String, equiName: String)

    /// SolutionId specific
    pub def makeLongTextWorkItems(xs: List[EquiWorkItem]): #{EquiLongTextWorkItem | r}  = 
        RelLib/Relation.foldMap(x1 -> #{ EquiLongTextWorkItem(x1.equipmentId, x1.s4Name). }, xs)



    /// IN PROGRESS - we could have easier (and more flexible rules) if we groupBy `equiId`
    /// as a post-processing step then concatenate the answers to make a `SLEquiLongText` ...

    /// Use the `Set[String]` lattice to store strings before concatenating them...

    lat LongText1(equiId: String, body: Set[String])

    pub def equiLongText(input: #{EquiLongTextWorkItem, AibMemoLine, LocationOnSite,
                                    LongText1, EquiLongText | r}): GenMonad[Unit] = 
        use AssetLib/GenS4/GenMonad.{flatMap, liftAction};
        let rules = #{

            LongText1(equiId; locationOnSite(location)) :- 
                LocationOnSite(equiId, location), 
                if String.length(location) > 30.

            LongText1(equiId; memoText) :- 
                AibMemoLine(equiId; memoText), 
                if Set.size(memoText) > 1 or Set.exists(isMultiline, memoText).

            EquiLongText(equiId, description, getLongText(longText)) :- 
                EquiLongTextWorkItem(equiId, description),
                LongText1(equiId; longText).

        };
        let* answers = 
            liftAction(_ -> 
                query (rules <+> input) select (x1, x2, x3) from EquiLongText(x1, x2, x3) 
                    |> Array.toList
                    |> List.map(RelLib/Tuple.decons3((x, y, z) -> {equiId = x, description = y, longText = z})));
        AssetLib/GenS4/GenMonad.mapX(AssetLib/GenS4/GenMonad.tellSLEquiLongText, answers)



    def locationOnSite(location: String): Set[String] = Set.singleton("Location on Site: ${String.trim(location)}")

    def getLongText(body: Set[String]): String = 
        body |> Set.toList |> List.flatMap(String.lines) |> List.filter(s1 -> not String.isEmpty(s1)) |> String.unlines

    def isMultiline(s: String): Bool = List.length(String.lines(s)) > 1

}
