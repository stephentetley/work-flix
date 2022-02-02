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

    use S4Loader/Base/Schema.{StringProperty, IntProperty, FloatProperty, PropertyAlias};
    use S4Loader/PDT/Rules/Schema.{EquiWorkItem};


    pub type alias EquiCharacteristicSchema[r1: SchemaRow] = 
        #{EquiWorkItem, StringProperty, IntProperty, PropertyAlias, 
            EquiCharacteristic | r1}


    pub def equiCharacteristics(): EquiCharacteristicSchema[r1] =  
        #{

                    
            EquiCharacteristic(equiId, s4EquiClass, s4CharName, S4Float(value)) :-
                EquiWorkItem(equiId, _),
                FloatProperty(equiId, "Rated Current (A)", value),
                PropertyAlias("Rated Current (A)", s4EquiClass, s4CharName).
            
            EquiCharacteristic(uid, s4EquiClass, s4CharName, S4Float(value)) :-
                EquiWorkItem(uid, _),
                FloatProperty(uid, "Insulation Class (°c)", value),
                PropertyAlias("Insulation Class (°c)", s4EquiClass, s4CharName).

            

        }
        


}
