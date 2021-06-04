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


namespace AssetLib/GenS4/Rules/Characteristics/Star {

    use AssetLib/AibFacts/Attributes/Electrical.{CurrentIn, InsulationClass,
        IPRating, SpeedRPM, Power, PowerUnits, VoltageIn, VoltageInACOrDC};

    use AssetLib/GenS4/WorkLists.{EquiWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String, S4Float, S4Int};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{recognizedVoltageUnits, voltageUnits};
    use AssetLib/GenS4/XlsxSource.{XlsxSource};


    pub def genStar(input: #{EquiWorkItem, CurrentIn, InsulationClass, 
                            IPRating, Power, PowerUnits, SpeedRPM,
                            VoltageIn, VoltageInACOrDC, EquiCharacteristic | r1}, 
                    source: Option[XlsxSource]): Result[#{EquiCharacteristic | r}, String] & Impure =  
        use Result.{flatMap};    
        match source {
            case Some(src) => { 
                let* c1 = AssetLib/AibFacts/Attributes/Electrical.readElectricalData(src.sheet, src.file);
                let ans = star(c1 <+> input);
                Ok(ans)
            }
            case None => Ok(#{ }) as & Impure
        }

    /// TODO "STAR_INPUT_CURRENT_A" / "STAR_INPUT_VOLTAGE" ... (STARVF ...)

    pub def star(input: #{EquiWorkItem, CurrentIn,
                            IPRating, SpeedRPM, Power, PowerUnits, 
                            VoltageIn, VoltageInACOrDC, EquiCharacteristic | r1}): #{EquiCharacteristic | r} = 
        let rules = #{
            EquiCharacteristic(equiId, s4Class, "IP_RATING", 1, S4String(rating)) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "STAR", s4Class),
                IPRating(equiId, rating).

            EquiCharacteristic(equiId, s4Class, "STAR_RATED_CURRENT_A", 1, S4Float(current)) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "STAR", s4Class),
                CurrentIn(equiId, current).

            EquiCharacteristic(equiId, s4Class, "STAR_RATED_POWER_KW", 1, S4Float(power)) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "STAR", s4Class),
                PowerUnits(equiId, "KILOWATTS"),
                Power(equiId, power).

            EquiCharacteristic(equiId, s4Class, "STAR_RATED_VOLTAGE", 1, S4Int(voltage)) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "STAR", s4Class),
                VoltageInACOrDC(equiId, units),
                VoltageIn(equiId, voltage),
                if recognizedVoltageUnits(units).

            EquiCharacteristic(equiId, s4Class, "STAR_RATED_VOLTAGE_UNITS", 1 , S4String(voltageUnits(units))) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "STAR", s4Class),
                VoltageInACOrDC(equiId, units),
                VoltageIn(equiId, _),
                if recognizedVoltageUnits(units).
        }; 
        solve (rules <+> input) project EquiCharacteristic


}
