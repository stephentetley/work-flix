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


namespace AibLoader/Rules/EquiAttributes {

    use AssetLib/S4Lite/S4LiteRelations.CharValue;
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String, S4Int, S4Float, S4Date};

    use AibLoader/Base/AttributesLattice.{Attributes, AttributeValue};
    use AibLoader/Base/AttributesLattice.AttributeValue.{AttrString, AttrInt, AttrFloat, AttrDate};
    use AibLoader/Base/Relations.{StringProperty, FloatProperty, EquiWorkItem3};

    // Collect with a lattice because we are expecting relations that are one-to-one 
    // or one-to-zero rather than one-to-many.


    pub type alias EquiAttributesSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, StringProperty, FloatProperty, EquiAttributes | r1}


    /// Strings of location-on-site and Memos
    pub lat EquiAttributes(equiId: String, attrs: Attributes)


    pub def equiAttributes(): EquiAttributesSchema[r1] = 
        use AibLoader/Base/AttributesLattice.{singleton};
        #{

            EquiAttributes(equiId; singleton("ASSET_STATUS", AttrString(value))) :-  
                EquiWorkItem3(equiId, _, _),
                StringProperty(equiId, "ASSETSTATUS", value).

                // INSTALLED FROM
            EquiAttributes(equiId; singleton("INSTALLED_FROM", AttrDate(Option.getWithDefault(fallbackDate(), sqliteDate(value))))) :-  
                EquiWorkItem3(equiId, _, _),
                StringProperty(equiId, "INSTALLED FROM", value).

            EquiAttributes(equiId; singleton("MANUFACTURER", AttrString(value))) :-  
                EquiWorkItem3(equiId, _, _),
                StringProperty(equiId, "MANUFACTURER", value).

            EquiAttributes(equiId; singleton("MODEL", AttrString(value))) :-  
                EquiWorkItem3(equiId, _, _),
                StringProperty(equiId, "MODEL", value).

            EquiAttributes(equiId; singleton("SERIAL_NO", AttrString(value))) :-  
                EquiWorkItem3(equiId, _, _),
                StringProperty(equiId, "SERIAL NO", value).

            EquiAttributes(equiId; singleton("SPECIFIC_MODEL_FRAME", AttrString(value))) :-  
                EquiWorkItem3(equiId, _, _),
                StringProperty(equiId, "SPECIFIC MODEL/FRAME", value).

            EquiAttributes(equiId; singleton("WEIGHT_KG", AttrFloat(value))) :- 
                EquiWorkItem3(equiId, _, _),
                FloatProperty(equiId, "WEIGHT KG", value).
                          
        } 

    // Stored as string e.g. "4/29/21 17:47"
    def sqliteDate(s: String): Option[Time.LocalDate] =
        use Option.flatMap;
        let* fmt    = Time/Format/DateTimeFormatter.ofPattern("M/d/yy H:m");
        let* dt     = Time/LocalDateTime.parse(fmt, s);
        Some(Time/LocalDateTime.toLocalDate(dt))

    def fallbackDate(): Time.LocalDate = 
        Time/LocalDate.new({year=1970, month=1, dayOfMonth=1})
}
