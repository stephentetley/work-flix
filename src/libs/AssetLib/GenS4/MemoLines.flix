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


namespace AssetLib/GenS4/MemoLines {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;

    use AssetLib/AibFacts/Relations.{AibStringValue};
    use AssetLib/GenS4/UxlRelations.{EquiDatum, EquiLongText};

    pub def uxlEquiLongText(): #{EquiLongText, EquiDatum, AibStringValue | r} = 
        #{
            EquiLongText(aibref, description, longText) :- 
                EquiDatum(aibref, _, description,  _, _, _,  _, _, _,  _, _, _,  _, _),
                AibStringValue(aibref, "MEMO_LINES", longText).

        }

 
}
