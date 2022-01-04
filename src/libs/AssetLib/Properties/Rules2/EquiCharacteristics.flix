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


    pub rel RangeUnit(aibName: String, s4Name: String)

    pub type alias EquiCharacteristicSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, StringProperty, IntProperty, PropertyAlias, RangeUnit, EquiCharacteristic | r1}


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

            RangeUnit("%",          "PCT").
            RangeUnit("Bar",        "BAR"). 
            RangeUnit("cm/s",       "CM/S"). 
            RangeUnit("Deg C",      "DEG C" ).
            RangeUnit("l/h",        "L/H"). 
            RangeUnit("l/s",        "L/S").
            RangeUnit("m",          "M").
            RangeUnit("m/s",        "M/S").
            RangeUnit("m3/h",       "M3/H").
            RangeUnit("mbar",       "MBAR").
            RangeUnit("mg/l",       "MG/L").
            RangeUnit("mm",         "MM").
            RangeUnit("NTU",        "NTU").


            EquiCharacteristic(equiId, s4EquiClass, s4CharName, 1, S4Float(value)) :- 
                EquiWorkItem3(equiId, _, s4EquiClass),
                FloatProperty(equiId, "RANGE MIN", value),
                StringProperty(equiId, "RANGE UNIT", units),
                PropertyAlias("RANGE MIN", s4EquiClass, s4CharName),
                RangeUnit(units, _).

           EquiCharacteristic(equiId, s4EquiClass, s4CharName, 1, S4Float(value)) :- 
                EquiWorkItem3(equiId, _, s4EquiClass),
                FloatProperty(equiId, "RANGE MAX", value),
                StringProperty(equiId, "RANGE UNIT", units),
                PropertyAlias("RANGE MAX", s4EquiClass, s4CharName),
                RangeUnit(units, _).

            EquiCharacteristic(equiId, s4EquiClass, s4CharName, 1, S4String(units)) :- 
                EquiWorkItem3(equiId, _, s4EquiClass),
                StringProperty(equiId, "RANGE UNIT", units),
                PropertyAlias("RANGE UNIT", s4EquiClass, s4CharName),
                RangeUnit(units, _).


        }
        


}
