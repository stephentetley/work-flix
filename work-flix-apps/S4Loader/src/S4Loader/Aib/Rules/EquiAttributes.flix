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


namespace S4Loader/Aib/Rules/EquiAttributes {

    use AssetLib/S4Lite/S4LiteRelations.CharValue;
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String, S4Int, S4Float, S4Date};
    use AssetLib/Base/AttributesLattice.{Attributes, AttributeValue};
    use AssetLib/Base/AttributesLattice.AttributeValue.{AttrString, AttrInt, AttrFloat, AttrDate};

    use S4Loader/Base/Schema.{StringProperty, FloatProperty, EquiWorkItem3};

    // Collect with a lattice because we are expecting relations that are one-to-one 
    // or one-to-zero rather than one-to-many.


    pub type alias EquiAttributesSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, StringProperty, FloatProperty, EquiAttributes | r1}


    /// Strings of location-on-site and Memos
    pub lat EquiAttributes(equiId: String, attrs: Attributes)


    pub def equiAttributes(): EquiAttributesSchema[r1] = 
        use AssetLib/Base/AttributesLattice.{singleton};
        #{

            EquiAttributes(equiId; singleton("ASSET_STATUS", AttrString(value))) :-  
                EquiWorkItem3(equiId, _, _),
                StringProperty(equiId, "AssetStatus", value).

                // INSTALLED FROM
            EquiAttributes(equiId; singleton("INSTALLED_FROM", AttrDate(value))) :-  
                EquiWorkItem3(equiId, _, _),
                DateProperty(equiId, "Installed From", value).

            EquiAttributes(equiId; singleton("MANUFACTURER", AttrString(value))) :-  
                EquiWorkItem3(equiId, _, _),
                StringProperty(equiId, "Manufacturer", value).

            EquiAttributes(equiId; singleton("MODEL", AttrString(value))) :-  
                EquiWorkItem3(equiId, _, _),
                StringProperty(equiId, "Model", value).

            EquiAttributes(equiId; singleton("SERIAL_NO", AttrString(value))) :-  
                EquiWorkItem3(equiId, _, _),
                StringProperty(equiId, "Serial No", value).

            EquiAttributes(equiId; singleton("SPECIFIC_MODEL_FRAME", AttrString(value))) :-  
                EquiWorkItem3(equiId, _, _),
                StringProperty(equiId, "Specific Model/Frame", value).

            EquiAttributes(equiId; singleton("WEIGHT_KG", AttrFloat(value))) :- 
                EquiWorkItem3(equiId, _, _),
                FloatProperty(equiId, "Weight kg", value).
                          
        } 


}
