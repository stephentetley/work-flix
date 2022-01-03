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


namespace AssetLib/Properties/Rules2/EquiCharacteristics {

    use AssetLib/S4Lite/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String, S4Int, S4Float};
    use AssetLib/Properties/Relations.{StringProperty, IntProperty, FloatProperty, PropertyAlias};
    use AssetLib/Properties/Rules2/CommonRelations.{EquiWorkItem3};



    pub type alias EquiCharacteristicSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, StringProperty, IntProperty, PropertyAlias, EquiCharacteristic | r1}


    pub def equiCharacteristics(): EquiCharacteristicSchema[r1] =  
        #{

            EquiCharacteristic(equiId, s4EquiClass, s4CharName, 1, S4Float(value)) :-
                EquiWorkItem3(equiId, _, s4EquiClass),
                FloatProperty(equiId, "CURRENT IN", value),
                PropertyAlias("CURRENT IN", s4EquiClass, s4CharName).

            EquiCharacteristic(equiId, s4EquiClass, "INSULATION_CLASS_DEG_C", 1, S4String(String.toUpperCase(value))) :-
                EquiWorkItem3(equiId, _, s4EquiClass),
                StringProperty(equiId, "INSULATION CLASS", value).
        
            EquiCharacteristic(equiId, s4EquiClass, "IP_RATING", 1, S4String(String.toUpperCase(value))) :-
                EquiWorkItem3(equiId, _, s4EquiClass),
                StringProperty(equiId, "IP RATING", value).

            
        }
        


}
