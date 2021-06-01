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

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;

    use AssetLib/AibFacts/Attributes/Equipment.{LocationOnSite};
    use AssetLib/AibFacts/Attributes/MemoLines.{AibMemoLine};
    use AssetLib/GenS4/WorkListRelations.{EquiWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{EquiLongText};

    rel HasLocationOnSite(id: String)
    rel HasMemoLines(id: String)

    pub def genEquiLongText(input: #{EquiWorkItem, AibMemoLine, LocationOnSite, 
                                    HasLocationOnSite, HasMemoLines,
                                    EquiLongText | r}): #{EquiLongText | r} = 
        let rules = #{

            HasMemoLines(equiId) :- AibMemoLine(equiId, _).
            HasLocationOnSite(equiId) :- LocationOnSite(equiId, _).

            EquiLongText(equiId, description, combine(longText, location) ) :- 
                EquiWorkItem(equiId, description, _, _, _, _, _, _, _),
                AibMemoLine(equiId, longText),
                LocationOnSite(equiId, location), 
                if (String.length(location) > 30).

            EquiLongText(equiId, description, String.trim(longText)) :- 
                EquiWorkItem(equiId, description, _, _, _, _, _, _, _),
                AibMemoLine(equiId, longText), 
                not HasLocationOnSite(equiId).

            EquiLongText(equiId, description, String.trim(longText)) :- 
                EquiWorkItem(equiId, description, _, _, _, _, _, _, _),
                AibMemoLine(equiId, longText), 
                LocationOnSite(equiId, location), 
                if (String.length(location) <= 30).


            EquiLongText(equiId, description, locationOnSite(location) ) :- 
                EquiWorkItem(equiId, description, _, _, _, _, _, _, _),
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
