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

    use AssetLib/AibFacts/Attributes/Electrical.{CurrentIn, InsulationClass, 
                            IPRating, Power, PowerUnits, SpeedRPM,
                            VoltageIn, VoltageInACOrDC};

    use AssetLib/GenS4/WorkListRelations.{EquiWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String, S4Float, S4Int};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{recognizedVoltageUnits, voltageUnits};
    use AssetLib/GenS4/XlsxSource.{XlsxSource};

    pub def genConp(input: #{EquiWorkItem, CurrentIn, InsulationClass, 
                            IPRating, Power, PowerUnits, SpeedRPM,
                            VoltageIn, VoltageInACOrDC, EquiCharacteristic | r1}, 
                    source: Option[XlsxSource]): Result[#{EquiCharacteristic | r}, String] & Impure =  
        use Result.{flatMap};    
        match source {
            case Some(src) => { 
                let* c1 = AssetLib/AibFacts/Attributes/Electrical.readElectricalData(src.sheet, src.file);
                let ans = conp(c1 <+> input);
                Ok(ans)
            }
            case None => Ok(#{ }) as & Impure
        }

    pub def conp(input: #{EquiWorkItem, CurrentIn, VoltageIn, VoltageInACOrDC, EquiCharacteristic | r1}): #{EquiCharacteristic | r} = 
        let rules = #{
            EquiCharacteristic(equiId, s4Class, "CONP_RATED_CURRENT_A", 1, S4Float(current)) :-
                EquiWorkItem(equiId, _, _, _, _, _, _, "CONP", s4Class),
                CurrentIn(equiId, current).

            EquiCharacteristic(equiId, s4Class, "CONP_RATED_VOLTAGE", 1, S4Int(voltage)) :-
                EquiWorkItem(equiId, _, _, _, _, _, _, "CONP", s4Class),
                VoltageInACOrDC(equiId, units),
                VoltageIn(equiId, voltage),
                if recognizedVoltageUnits(units).

            EquiCharacteristic(equiId, s4Class, "CONP_RATED_VOLTAGE_UNITS", 1, S4String(voltageUnits(units))) :-
                EquiWorkItem(equiId, _, _, _, _, _, _, "CONP", s4Class),
                VoltageInACOrDC(equiId, units),
                VoltageIn(equiId, _),
                if recognizedVoltageUnits(units).
        }; 
        solve (rules <+> input) project EquiCharacteristic


}
