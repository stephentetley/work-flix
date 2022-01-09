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


namespace AssetLib/Properties/Rules2/EquiAttributes {

    use AssetLib/S4Lite/S4LiteRelations.CharValue;
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String, S4Int, S4Float, S4Date};
    use AssetLib/Properties/AttributesLattice.{Attributes, AttributeValue};
    use AssetLib/Properties/AttributesLattice.AttributeValue.{AttrString, AttrInt, AttrFloat};
    use AssetLib/Properties/Relations.{StringProperty, FloatProperty};
    use AssetLib/Properties/Rules2/CommonRelations.{EquiWorkItem3};

    /// Collect with a lattice because we are expecting one-to-one relationships


    pub type alias EquiAttributesSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, FloatProperty, EquiAttributes | r1}


    /// Strings of location-on-site and Memos
    pub lat EquiAttributes(equiId: String, attrs: Attributes)


    pub def equiAttributes(): EquiAttributesSchema[r1] = 
        use AssetLib/Properties/AttributesLattice.{singleton};
        #{

            EquiAttributes(equiId; singleton("WEIGHT_KG", AttrFloat(value))) :- 
                EquiWorkItem3(equiId, _, _),
                FloatProperty(equiId, "WEIGHT KG", value).
            
        } 

    /// def toAttributeValue(x: CharValue): AttributeValue = match x { 
    ///     case S4String(s) => AttrString(s)
    ///     case S4Date(_)   => AttrString("Date - TODO")
    ///     case S4Int(i)    => AttrInt(i)
    ///     case S4Float(d)  => AttrFloat(d)
    /// }

}
