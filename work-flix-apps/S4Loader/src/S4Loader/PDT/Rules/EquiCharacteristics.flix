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


namespace S4Loader/PDT/Rules/EquiCharacteristics {

    use AssetLib/S4Lite/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String, S4Int, S4Float, S4Date};

    use S4Loader/Base/Schema.{StringProperty, IntProperty, FloatProperty, EquiCharMapping, PropertyAlias, EquiObjectClass};
    use S4Loader/PDT/Gen/WorkList.{EquiWorkItem};


    pub type alias EquiCharacteristicSchema[r1: SchemaRow] = 
        #{EquiWorkItem, StringProperty, IntProperty, EquiCharMapping, PropertyAlias, EquiObjectClass, 
            EquiCharacteristic | r1}


    ///
    /// Must ensure `pdt_field_types.csv` includes the expected property and its type.
    ///
    pub def equiCharacteristics(): EquiCharacteristicSchema[r1] =  
        #{            

            
            EquiCharacteristic(uid, s4ClassName, s4CharName, S4String(value)) :-
                EquiWorkItem(uid, _),
                StringProperty(uid, "Asset Type", pdtAssertType),
                EquiCharMapping(pdtAssertType, pdtStringProperty, s4ClassName, s4CharName),
                StringProperty(uid, pdtStringProperty, value).

            EquiCharacteristic(uid, s4ClassName, s4CharName, S4Int(value)) :-
                EquiWorkItem(uid, _),
                StringProperty(uid, "Asset Type", pdtAssertType),
                EquiCharMapping(pdtAssertType, pdtIntProperty, s4ClassName, s4CharName),
                IntProperty(uid, pdtIntProperty, value).

            EquiCharacteristic(uid, s4ClassName, s4CharName, S4Float(value)) :-
                EquiWorkItem(uid, _),
                StringProperty(uid, "Asset Type", pdtAssertType),
                EquiCharMapping(pdtAssertType, pdtFloatProperty, s4ClassName, s4CharName),
                FloatProperty(uid, pdtFloatProperty, value).

            EquiCharacteristic(uid, s4ClassName, s4CharName, S4Date(value)) :-
                EquiWorkItem(uid, _),
                StringProperty(uid, "Asset Type", pdtAssertType),
                EquiCharMapping(pdtAssertType, pdtDateField, s4ClassName, s4CharName),
                DateProperty(uid, pdtDateField, value).


            /// Special - uses "Tank Shape" has been converted as an enum to the appropriate class
            EquiCharacteristic(uid, tankShapeClass, charName, S4Float(value)) :-
                EquiWorkItem(uid, _),
                StringProperty(uid, "Tank Shape", tankShapeClass),
                FloatProperty(uid, "Capacity (m3)", value),
                PropertyAlias("Capacity (m3)", tankShapeClass, charName).

            /// Special - uses TankShape property
            EquiCharacteristic(uid, tankShapeClass, charName, S4Int(value)) :-
                EquiWorkItem(uid, _),
                StringProperty(uid, "Tank Shape", tankShapeClass),
                IntProperty(uid, "Diameter (mm)", value),
                PropertyAlias("Diameter (mm)", tankShapeClass, charName).



            /// Special - "Type of Gas Sensor"
            EquiCharacteristic(uid, equiClass, charName, S4String("HYDROGEN SULPHIDE")) :-
                EquiWorkItem(uid, _),
                EquiObjectClass(uid, _, _, equiClass),
                StringProperty(uid, "Type of Gas Sensor 1", value),
                PropertyAlias("Type of Gas Sensor 1", equiClass, charName),
                if String.toUpperCase(value) == "HYDROGEN SULPHIDE".

            EquiCharacteristic(uid, equiClass, charName, S4String(String.toUpperCase(value))) :-
                EquiWorkItem(uid, _),
                EquiObjectClass(uid, _, _, equiClass),
                StringProperty(uid, "Type of Gas Sensor 1", value),
                PropertyAlias("Type of Gas Sensor 2", equiClass, charName),
                if String.toUpperCase(value) != "HYDROGEN SULPHIDE".

        }
        


}
