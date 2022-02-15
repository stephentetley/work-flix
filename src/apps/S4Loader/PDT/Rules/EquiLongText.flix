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


namespace S4Loader/PDT/Rules/EquiLongText {


    use AssetLib/Base/AttributesLattice.{Attributes, AttributeValue};
    use AssetLib/Base/AttributesLattice.AttributeValue.{AttrString};
    use AssetLib/S4Lite/S4LiteRelations.{EquiLongText};
    
    use S4Loader/Base/Schema.{StringProperty};
    use S4Loader/PDT/Gen/WorkList.{EquiWorkItem};

    pub type alias EquiLongTextSchema[r1: SchemaRow] = 
        #{EquiWorkItem, StringProperty, LongText, EquiLongText | r1}


    /// Strings of location-on-site and Memos
    pub lat LongText(equiId: String, body: Attributes)


    pub def equiLongText(): EquiLongTextSchema[r1] =  
        use AssetLib/Base/AttributesLattice.{singleton};
        #{

            EquiLongText(uid, s4Name, getLongText(longText)) :- 
                EquiWorkItem(uid, s4Name),
                fix LongText(uid; longText).

            // Long Text could be memoText
            LongText(uid; singleton("A1", AttrString(memoText))) :- 
                EquiWorkItem(uid, _),
                StringProperty(uid, "Memo Line", memoText),
                if isLongOrMultiline(memoText).

            // Long Text could be location text if too long
            LongText(uid; singleton("L1", AttrString("Location on Site: ${location}"))) :- 
                EquiWorkItem(uid, _),
                StringProperty(uid, "Location on Site", location),
                if isLongOrMultiline(location).

            LongText(uid; singleton("Z1", AttrString(memoText))) :- 
                EquiWorkItem(uid, _),
                StringProperty(uid, "@EXTRA_MEMO", memoText).
                
        }

    def getLongText(attrs: Attributes): String = 
        let get1 = x -> match x {
            case AttrString(s) => s
            case _             => ""
        };
        attrs
            |> AssetLib/Base/AttributesLattice.getAttributes1
            |> Map.valuesOf
            |> List.map(get1)
            |> String.unlines

    def isLongOrMultiline(s: String): Bool = 
        let isMultiLine = s1 -> match String.lines(s1) { 
            case Nil      => false
            case _ :: Nil => false
            case _ :: _   => true
        };
        String.length(s) >= 30 or isMultiLine(s)

}
