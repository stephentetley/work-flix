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


namespace S4Loader/Aib/Rules/EquiCharacteristics {

    use AssetLib/S4Lite/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String, S4Int, S4Float};

    use S4Loader/Base/Schema.{StringProperty, IntProperty, FloatProperty, PropertyAlias, EquiCharacteristicSpec, EquiWorkItem3};
    
    /// Helper relations...

    pub rel HasFloatProperty(equiId: String, propName: String)
    pub rel IntOfFloatProperty(equiId: String, propName: String, value: Int32)

    pub rel RangeUnit(aibName: String, s4Name: String)
    pub rel Signal1(unit: String, signalName: String)
    pub rel Signal3(smin: Int32, smax: Int32, unit: String, signalName: String)
    pub rel PropertyName(objectName: String, suffix: String, propName: String)
    

    /// TODO remove PropertyAlias...
    pub type alias EquiCharacteristicSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, StringProperty, IntProperty, PropertyAlias, 
            IntOfFloatProperty, HasFloatProperty, 
            RangeUnit, Signal1, Signal3, 
            EquiCharacteristicSpec, PropertyName,
            EquiCharacteristic | r1}


    pub def equiCharacteristics(): EquiCharacteristicSchema[r1] =  
        #{

            // Helpers

            HasFloatProperty(equiId, propName) :- FloatProperty(equiId, propName, _).

            IntOfFloatProperty(equiId, propName, S4Loader/Base/Utils.wholeFloat(d)) :-
                FloatProperty(equiId, propName, d),
                if S4Loader/Base/Utils.isWholeFloat(d).

            /// TODO - synthesize from `meta_equi_characteristics`
            PropertyName("ACTU", "RATED_CURRENT_A", "ACTU_RATED_CURRENT_A").


            // Current in
            EquiCharacteristic(equiId, equiClass, charName, S4Float(value)) :-
                EquiWorkItem3(equiId, equiObject, equiClass),
                FloatProperty(equiId, "Current In", value),
                PropertyName(equiObject, "RATED_CURRENT_A", charName),
                EquiCharacteristicSpec(equiClass, charName, _, _, _, _).

            EquiCharacteristic(equiId, equiClass, "INSULATION_CLASS_DEG_C", S4String(String.toUpperCase(value))) :-
                EquiWorkItem3(equiId, _, equiClass),
                StringProperty(equiId, "Insulation Class", value).
        
            EquiCharacteristic(equiId, s4EquiClass, "IP_RATING", S4String(String.toUpperCase(value))) :-
                EquiWorkItem3(equiId, _, s4EquiClass),
                StringProperty(equiId, "IP RATING", value).


            

            // Range min
            EquiCharacteristic(equiId, equiClass, charName, S4Float(value)) :- 
                EquiWorkItem3(equiId, equiObject, equiClass),
                FloatProperty(equiId, "RANGE MIN", value),
                StringProperty(equiId, "RANGE UNIT", units),
                // PropertyAlias("RANGE MIN", s4EquiClass, s4CharName),
                PropertyName(equiObject, "RANGE_MIN", charName),
                EquiCharacteristicSpec(equiClass, charName, _, _, _, _),
                RangeUnit(units, _).

            // Range max
            EquiCharacteristic(equiId, s4EquiClass, s4CharName, S4Float(value)) :- 
                EquiWorkItem3(equiId, _, s4EquiClass),
                FloatProperty(equiId, "RANGE MAX", value),
                StringProperty(equiId, "RANGE UNIT", units),
                PropertyAlias("RANGE MAX", s4EquiClass, s4CharName),
                RangeUnit(units, _).

            // Range units
            EquiCharacteristic(equiId, s4EquiClass, s4CharName, S4String(units)) :- 
                EquiWorkItem3(equiId, _, s4EquiClass),
                StringProperty(equiId, "RANGE UNIT", units),
                PropertyAlias("RANGE UNIT", s4EquiClass, s4CharName),
                RangeUnit(units, _).

            // ** Range (instrument)
            RangeUnit("%",          "PCT").
            RangeUnit("Bar",        "BAR"). 
            RangeUnit("cm/s",       "CM/S"). 
            RangeUnit("Deg C",      "DEG C").
            RangeUnit("l/h",        "L/H"). 
            RangeUnit("l/s",        "L/S").
            RangeUnit("m",          "M").
            RangeUnit("m/s",        "M/S").
            RangeUnit("m3/h",       "M3/H").
            RangeUnit("mbar",       "MBAR").
            RangeUnit("mg/l",       "MG/L").
            RangeUnit("mm",         "MM").
            RangeUnit("NTU",        "NTU").

            // ## SIGNAL TYPE

            // Signal without min/max
            EquiCharacteristic(equiId, s4EquiClass, s4CharName, S4String(signalName)) :- 
                EquiWorkItem3(equiId, _, s4EquiClass),
                not HasFloatProperty(equiId, "SIGNAL MIN"),
                not HasFloatProperty(equiId, "SIGNAL MAX"),
                StringProperty(equiId, "SIGNAL UNIT", unit),
                PropertyAlias("SIGNAL TYPE", s4EquiClass, s4CharName), 
                Signal1(unit, signalName).


            // Signal with min/max
            // Use `IntOfFloat` to get matchable numbers...
            EquiCharacteristic(equiId, s4EquiClass, s4CharName, S4String(signalName)) :- 
                EquiWorkItem3(equiId, _, s4EquiClass),
                IntOfFloatProperty(equiId, "SIGNAL MIN", smin),
                IntOfFloatProperty(equiId, "SIGNAL MAX", smax),
                StringProperty(equiId, "SIGNAL UNIT", unit),
                PropertyAlias("SIGNAL TYPE", s4EquiClass, s4CharName), 
                Signal3(smin, smax, unit, signalName).

            
            /// Also "PROFIBUS", "PROFIBUS DP", ...
            Signal1("Digital", "DIGITAL").

            /// also mV ?
            Signal3(0, 1, "Digital", "0 - 1 DIGITAL").
            Signal3(0, 2, "Digital", "0 - 2 DIGITAL").
            Signal3(0, 20, "Digital", "0 - 20 DIGITAL").
            Signal3(0, 200, "mA", "0 - 200 MA").
            Signal3(4, 12, "mA", "4 - 12 MA").
            Signal3(4, 20, "mA", "4 - 20 MA").
            Signal3(4, 40, "mA", "4 - 40 MA").
                

            // ## SPEED RPM
            // TODO - some speed (rpm)'s are decimal - where is the source coming from?
            // We may have to use the metadata tables to decide whether answer is S4Int / S4Float.
            EquiCharacteristic(equiId, s4EquiClass, s4CharName, S4Int(value)) :-
                EquiWorkItem3(equiId, _, s4EquiClass),
                IntOfFloatProperty(equiId, "SPEED (RPM)", value),
                PropertyAlias("SPEED (RMP)", s4EquiClass, s4CharName).

        }
        


}
