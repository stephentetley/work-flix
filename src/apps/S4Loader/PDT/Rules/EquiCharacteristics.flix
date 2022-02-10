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
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String, S4Int, S4Float};

    use S4Loader/Base/Schema.{StringProperty, IntProperty, FloatProperty, PropertyAlias, EquiObjectClass};
    use S4Loader/PDT/Gen/WorkList.{EquiWorkItem};


    pub type alias EquiCharacteristicSchema[r1: SchemaRow] = 
        #{EquiWorkItem, StringProperty, IntProperty, PropertyAlias, EquiObjectClass, 
            EquiCharacteristic | r1}


    pub def equiCharacteristics(): EquiCharacteristicSchema[r1] =  
        #{



            EquiCharacteristic(uid, equiClass, charName, S4Float(value)) :-
                EquiWorkItem(uid, _),
                EquiObjectClass(uid, _, equiClass),
                FloatProperty(uid, "Rated Current (A)", value),
                PropertyAlias("Rated Current (A)", equiClass, charName).
            
            EquiCharacteristic(uid, equiClass, charName, S4Float(value)) :-
                EquiWorkItem(uid, _),
                EquiObjectClass(uid, _, equiClass),
                FloatProperty(uid, "Insulation Class (°c)", value),
                PropertyAlias("Insulation Class (°c)", equiClass, charName).

            // rated power kw

            
            EquiCharacteristic(uid, equiClass, charName, S4Float(value)) :-
                EquiWorkItem(uid, _),
                EquiObjectClass(uid, _, equiClass),
                FloatProperty(uid, "Rated Power (kW)", value),
                PropertyAlias("Rated Power (kW)", equiClass, charName).


            EquiCharacteristic(uid, equiClass, charName, S4Float(value)) :-
                EquiWorkItem(uid, _),
                EquiObjectClass(uid, _, equiClass),
                FloatProperty(uid, "Range Max", value),
                PropertyAlias("Range Max", equiClass, charName).

                
            EquiCharacteristic(uid, equiClass, charName, S4Float(value)) :-
                EquiWorkItem(uid, _),
                EquiObjectClass(uid, _, equiClass),
                FloatProperty(uid, "Range Min", value),
                PropertyAlias("Range Min", equiClass, charName).

                
            EquiCharacteristic(uid, equiClass, charName, S4String(value)) :-
                EquiWorkItem(uid, _),
                EquiObjectClass(uid, _, equiClass),
                StringProperty(uid, "Range Unit", value),
                PropertyAlias("Range Unit", equiClass, charName).

        }
        


}
