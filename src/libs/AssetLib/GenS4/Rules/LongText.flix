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

    rel HasLocationOnSite(id: String)
    rel HasMemoLines(id: String)

    /// TODO - we could have easier (and more flexible rules) if we groupBy `equiId`
    /// as a post-processing step (and change the answer type to a record not a relation...)


    pub def genEquiLongText(worklist: List[EquiWorkItem], memosSrc: XlsxSource): Result[Chain[SLEquiLongText], String] & Impure =
        use Result.{flatMap};
        let workitems   = makeLongTextWorkItems(worklist);
        let* facts      = AssetLib/GenS4/AibFacts/Attributes/MemoLines.readMemoLinesData(memosSrc);
        let ans         = equiLongText(workitems <+> facts) |> AssetLib/S4Lite/S4LiteRelations.toSLEquiLongText;
        Ok(ans) 


    /// Case specific WorkItem...
    pub rel LongTextWorkItem(equiId: String, equiName: String)

    /// SolutionId specific
    pub def makeLongTextWorkItems(xs: List[EquiWorkItem]): #{LongTextWorkItem | r}  = 
        List.foldLeft((ac, x) -> ac <+> #{ LongTextWorkItem(x.equipmentId, x.s4Name). }, #{}, xs)


    pub def equiLongText(input: #{LongTextWorkItem, AibMemoLine, LocationOnSite, 
                                    HasLocationOnSite, HasMemoLines,
                                    EquiLongText | r}): #{EquiLongText | r} = 
        let rules = #{

            HasMemoLines(equiId) :- AibMemoLine(equiId, _).
            HasLocationOnSite(equiId) :- LocationOnSite(equiId, _).

            EquiLongText(equiId, description, combine(memoText, location) ) :- 
                LongTextWorkItem(equiId, description),
                AibMemoLine(equiId, memoText),
                LocationOnSite(equiId, location), 
                if (String.length(location) > 30).

            EquiLongText(equiId, description, String.trim(memoText)) :- 
                LongTextWorkItem(equiId, description),
                AibMemoLine(equiId, memoText), 
                not HasLocationOnSite(equiId).

            EquiLongText(equiId, description, String.trim(memoText)) :- 
                LongTextWorkItem(equiId, description),
                AibMemoLine(equiId, memoText), 
                LocationOnSite(equiId, location), 
                if (String.length(location) <= 30).


            EquiLongText(equiId, description, locationOnSite(location) ) :- 
                LongTextWorkItem(equiId, description),
                LocationOnSite(equiId, location), 
                not HasMemoLines(equiId),
                if (String.length(location) > 30).

        };
        solve (rules <+> input) project EquiLongText


    def combine(memos: String, location: String): String = 
        String.unlines(
                String.trim(memos)
            :: locationOnSite(location)
            :: Nil
        )

    def locationOnSite(location: String): String = "Location on Site: ${location}"


}
