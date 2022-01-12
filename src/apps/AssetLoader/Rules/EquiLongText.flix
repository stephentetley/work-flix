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


namespace AssetLoader/Rules/EquiLongText {


    use AssetLib/Base/OrderedStringsLattice.{OrderedStrings};
    use AssetLib/S4Lite/S4LiteRelations.{EquiLongText};
    
    use AssetLoader/Base/Relations.{StringProperty};
    use AssetLoader/Rules/CommonRelations.{EquiWorkItem3};


    pub type alias EquiLongTextSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, StringProperty, LongText1, MemoLine, EquiLongText | r1}


    /// Strings of location-on-site and Memos
    pub lat LongText1(equiId: String, body: OrderedStrings)

    /// MemoLines need a special lattice to preserve order...
    pub lat MemoLine(equiId: String, body: AssetLib/Base/OrderedStringsLattice.OrderedStrings)

    pub def equiLongText(): EquiLongTextSchema[r1] = 
        use AssetLib/Base/OrderedStringsLattice.{getValue, singleton};
        #{

            EquiLongText(equiId, s4Name, getValue(longText)) :- 
                EquiWorkItem3(equiId, _, _),
                StringProperty(equiId, "@S4_NAME", s4Name),
                LongText1(equiId; longText).

            AibMemoLine(equiId; singleton(1, text)) :- 
                EquiWorkItem3(equiId, _, _),
                StringProperty(equiId, "MEMO LINE 1", text).
            
            AibMemoLine(equiId; singleton(2, text)) :- 
                EquiWorkItem3(equiId, _, _),
                StringProperty(equiId, "MEMO LINE 2", text).
            
            AibMemoLine(equiId; singleton(3, text)) :- 
                EquiWorkItem3(equiId, _, _),
                StringProperty(equiId, "MEMO LINE 3", text).
            
            AibMemoLine(equiId; singleton(4, text)) :- 
                EquiWorkItem3(equiId, _, _),
                StringProperty(equiId, "MEMO LINE 4", text).
                            
            AibMemoLine(equiId; singleton(5, text)) :- 
                EquiWorkItem3(equiId, _, _),
                StringProperty(equiId, "MEMO LINE 5", text).

            // Long Text could be memoText
            LongText1(equiId; memoText) :- 
                MemoLine(equiId; memoText), 
                if isLongMemo(memoText).

            // Long Text could be locatio text if too long
            LongText1(equiId; locationText(location)) :- 
                EquiWorkItem3(equiId, _, _),
                StringProperty(equiId, "LOCATION ON SITE", location),
                if String.length(location) > 30.

            

        }

    def locationText(location: String): OrderedStrings = 
        AssetLib/Base/OrderedStringsLattice.singleton(0, "Location on Site: ${String.trim(location)}")

    def isLongMemo(s: OrderedStrings): Bool = 
        let text = AssetLib/Base/OrderedStringsLattice.getValue(s);
        AssetLib/Base/OrderedStringsLattice.count(s) > 1 or String.length(text) >= 30

}
