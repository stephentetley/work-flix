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


namespace S4Loader/PDT/Rules/EquiAttributes {

    use AssetLib/S4Lite/S4LiteRelations.CharValue;
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String, S4Int, S4Float, S4Date};

    use S4Loader/Base/AttributesLattice.{Attributes, AttributeValue};
    use S4Loader/Base/AttributesLattice.AttributeValue.{AttrString, AttrInt, AttrFloat, AttrDate};
    use S4Loader/Base/Schema.{StringProperty, FloatProperty, EquiObjectClass};

    use S4Loader/PDT/Gen/WorkList.{EquiWorkItem};

    // Collect with a lattice because we are expecting relations that are one-to-one 
    // or one-to-zero rather than one-to-many.


    pub type alias EquiAttributesSchema[r1: SchemaRow] = 
        #{EquiWorkItem, StringProperty, FloatProperty, EquiAttributes, EquiObjectClass | r1}


    pub lat EquiAttributes(uid: String, attrs: Attributes)


    pub def equiAttributes(): EquiAttributesSchema[r1] = 
        use S4Loader/Base/AttributesLattice.{singleton};
        #{


            EquiAttributes(uid; singleton("EquipCategory", AttrString(category))) :-  
                EquiWorkItem(uid, _),
                EquiObjectClass(uid, category, _, _).


            EquiAttributes(uid; singleton("Object type", AttrString(objtype))) :-  
                EquiWorkItem(uid, _),
                EquiObjectClass(uid, _, objtype, _).

            /// Needs translation...
            EquiAttributes(uid; singleton("Status of an object", AttrString(value))) :-  
                EquiWorkItem(uid, _),
                StringProperty(uid, "Asset Status", value).

            // 
            EquiAttributes(uid; singleton("Start-up date", AttrDate(value))) :-  
                EquiWorkItem(uid, _),
                DateProperty(uid, "Date of installation", value).

            EquiAttributes(uid; singleton("Manufacturer", AttrString(value))) :-  
                EquiWorkItem(uid, _),
                StringProperty(uid, "Manufacturer", value).

            EquiAttributes(uid; singleton("Model number", AttrString(value))) :-  
                EquiWorkItem(uid, _),
                StringProperty(uid, "Product range", value).

            EquiAttributes(uid; singleton("ManufSerialNo.", AttrString(value))) :-  
                EquiWorkItem(uid, _),
                StringProperty(uid, "Manufacturer's serial number", value).

            EquiAttributes(uid; singleton("ManufPartNo.", AttrString(value))) :-  
                EquiWorkItem(uid, _),
                StringProperty(uid, "Product model number", value).

            EquiAttributes(uid; singleton("TechIdentNo.", AttrString(value))) :-  
                EquiWorkItem(uid, _),
                StringProperty(uid, "Tag reference", value).
                
            EquiAttributes(uid; singleton("Gross Weight kg", AttrFloat(value))) :- 
                EquiWorkItem(uid, _),
                FloatProperty(uid, "Weight(kg)", value).
                          
        } 

    pub def toAttributePatches(relns: #{EquiAttributes | r1}): Map[String, Map[String, AttributeValue]] & Impure = 
        query relns select (x1; x2) from EquiAttributes(x1; x2)
            |> Array.map(makePatch1)
            |> Array.toMap

    def makePatch1(x: (String, Attributes)): (String, Map[String, AttributeValue]) = 
        let (uid, x1) = x;
        (uid, S4Loader/Base/AttributesLattice.getAttributes1(x1))

}
