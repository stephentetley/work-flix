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


namespace AssetLib/GenS4/Rules/Characteristics/Conp {

    use AssetLib/AibFacts/Relations.{AibStringValue, AibIntValue, AibFloatValue};
    use AssetLib/GenS4/WorkListRelations.{EquiWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String, S4Int};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{recognizedVoltageUnits, voltageUnits};


    pub def conp(input: #{EquiWorkItem, AibStringValue, AibIntValue, 
                            AibFloatValue, EquiCharacteristic | r}): #{EquiCharacteristic | r} = 
        #{

            EquiCharacteristic(equiId, s4Class, "CONP_RATED_CURRENT_A", 1, S4Float(current)) :-
                EquiWorkItem(equiId, _, _, _, _, _, _, "CONP", s4Class),
                AibFloatValue(equiId, "CURRENT_IN", current).

            EquiCharacteristic(equiId, s4Class, "CONP_RATED_VOLTAGE", 1, S4Int(voltage)) :-
                EquiWorkItem(equiId, _, _, _, _, _, _, "CONP", s4Class),
                AibStringValue(equiId, "VOLTAGE_IN_AC_OR_DC", units),
                AibIntValue(equiId, "VOLTAGE_IN", voltage),
                if recognizedVoltageUnits(units).

            EquiCharacteristic(equiId, s4Class, "CONP_RATED_VOLTAGE_UNITS", 1, S4Int(voltageUnits(units))) :-
                EquiWorkItem(equiId, _, _, _, _, _, _, "CONP", s4Class),
                AibStringValue(equiId, "VOLTAGE_IN_AC_OR_DC", units),
                AibIntValue(equiId, "VOLTAGE_IN", _),
                if recognizedVoltageUnits(units).

        }; 
        solve (rules <+> input) project EquiCharacteristic


}
