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


namespace AssetLib/GenS4/Rules/MultilingualText {


    use Compatibility.{XlsxSource};

    use AssetLib/S4Lite/Datatypes.{SLEquiLongText};
    use AssetLib/S4Lite/S4LiteRelations.{EquiLongText};
    use AssetLib/GenS4/Base/OrderedStrings.{OrderedStrings};
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/Base/CommonRelations.{AibMemoLine, LocationOnSite};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};




    pub def genEquiLongText(worklist: List[EquiWorkItem], 
                            args: {memosSrc :: XlsxSource, locsSrc :: XlsxSource}): GenMonad[Unit] =
        use AssetLib/GenS4/GenMonad.{flatMap};
        let workitems   = makeLongTextWorkItems(worklist);
        let* memos     = AssetLib/GenS4/AibFacts/Attributes/MemoLines.readMemoLinesData(args.memosSrc);
        let* locs       = AssetLib/GenS4/AibFacts/Attributes/LocationData.readLocationOnSiteData(args.locsSrc);
        equiLongText(workitems <+> memos <+> locs)


    /// Case specific WorkItem so this might be usable to different "EquiWorkList"
    /// although the rules are probably too specific...
    pub rel EquiLongTextWorkItem(equiId: String, equiName: String)

    /// SolutionId specific
    pub def makeLongTextWorkItems(xs: List[EquiWorkItem]): #{EquiLongTextWorkItem | r}  = 
        RelLib/Relation.foldMap(x1 -> #{ EquiLongTextWorkItem(x1.equipmentId, x1.s4Name). }, xs)



    /// Strings of location-on-site and Memos
    lat LongText1(equiId: String, body: OrderedStrings)

    pub def equiLongText(input: #{EquiLongTextWorkItem, AibMemoLine, LocationOnSite,
                                    LongText1, EquiLongText | r}): GenMonad[Unit] = 
        use AssetLib/GenS4/GenMonad.{flatMap, liftAction};
        let rules = #{

            LongText1(equiId; locationText(location)) :- 
                LocationOnSite(equiId, location), 
                if String.length(location) > 30.

            /// Calling `isLongMemo` is a bit of a hack...
            LongText1(equiId; memoText) :- 
                AibMemoLine(equiId; memoText), 
                if isLongMemo(memoText).

            EquiLongText(equiId, description, AssetLib/GenS4/Base/OrderedStrings.getValue(longText)) :- 
                EquiLongTextWorkItem(equiId, description),
                fix LongText1(equiId; longText).

        };
        let* answers = 
            liftAction(_ -> 
                query (rules <+> input) select (x1, x2, x3) from EquiLongText(x1, x2, x3) 
                    |> Array.toList
                    |> List.map(RelLib/Tuple.decons3((x, y, z) -> {equiId = x, description = y, longText = z})));
        AssetLib/GenS4/GenMonad.mapX(AssetLib/GenS4/GenMonad.tellSLEquiLongText, answers)



    def locationText(location: String): OrderedStrings = 
        AssetLib/GenS4/Base/OrderedStrings.singleton(0, "Location on Site: ${String.trim(location)}")

    def isLongMemo(s: OrderedStrings): Bool = 
        let text = AssetLib/GenS4/Base/OrderedStrings.getValue(s);
        AssetLib/GenS4/Base/OrderedStrings.count(s) > 1 or String.length(text) >= 30

}
