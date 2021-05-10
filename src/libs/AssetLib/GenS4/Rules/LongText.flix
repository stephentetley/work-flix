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

    use AssetLib/AibFacts/Relations.{AibStringValue};
    use AssetLib/GenS4/UxlRelations.{EquiDatum, EquiLongText};

    pub def uxlEquiLongText(): #{EquiLongText, EquiDatum, AibStringValue | r} = 
        #{
            EquiLongText(aibref, description, combine(longText, location) ) :- 
                EquiDatum(aibref, _, description,  _, _, _,  _, _, _,  _, _, _,  _, _, _),
                AibStringValue(aibref, "MEMO_LINES", longText),
                AibStringValue(aibref, "LOCATION_ON_SITE", location), 
                if (String.length(location) > 30).

            EquiLongText(aibref, description, String.trim(longText)) :- 
                EquiDatum(aibref, _, description,  _, _, _,  _, _, _,  _, _, _,  _, _, _),
                AibStringValue(aibref, "MEMO_LINES", longText), 
                not AibStringValue(aibref, "LOCATION_ON_SITE", _).

            EquiLongText(aibref, description, locationOnSite(location) ) :- 
                EquiDatum(aibref, _, description,  _, _, _,  _, _, _,  _, _, _,  _, _, _),
                AibStringValue(aibref, "LOCATION_ON_SITE", location), 
                not AibStringValue(aibref, "MEMO_LINES", _),
                if (String.length(location) > 30).

        }


    def combine(memos: String, location: String): String = 
        String.unlines(
                String.trim(memos)
            :: locationOnSite(location)
            :: Nil
        )

    def locationOnSite(location: String): String = "Location on Site: ${location}"


}
