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


namespace AssetLib/GenS4/Rules/Characteristics/Emtr {

    use SheetIO/Reader.{XlsxSource};
    use AssetLib/GenS4/Base/CommonRelations.{CurrentInA, InsulationClass, 
        IPRating, SpeedRPM, Power, VoltageIn};
    use AssetLib/S4Lite/Datatypes.{SLEquiCharacteristic};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String, S4Float, S4Int};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{recognizedVoltageUnits, voltageUnits, 
        recognizedInsulationClass, insulationClass};
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3};
    

    /// src should be electrical facts
    pub def genEmtr(worklist: List[EquiWorkItem], src: XlsxSource): Result[Chain[SLEquiCharacteristic], String] & Impure =
        use Result.{flatMap};
        let workitems   = AssetLib/GenS4/WorkLists.makeEquiWorkItem3(worklist);
        let* facts      = AssetLib/GenS4/AibFacts/Attributes/Electrical.readElectricalData(src);
        let ans         = emtr(workitems <+> facts);
        Ok(ans) 


    /// IP_RATING should be generated on per type (per class?)
    pub def emtr(input: #{EquiWorkItem3, CurrentInA, InsulationClass, 
                            IPRating, SpeedRPM, Power, VoltageIn, 
                            EquiCharacteristic | r1}): Chain[SLEquiCharacteristic] & Impure = 
        let rules = #{
            EquiCharacteristic(equiId, s4Class, "IP_RATING", 1, S4String(rating)) :- 
                EquiWorkItem3(equiId, "EMTR", s4Class),
                IPRating(equiId, rating).

            EquiCharacteristic(equiId, s4Class, "INSULATION_CLASS_DEG_C", 1, S4String(insulationClass(insClass))) :-
                EquiWorkItem3(equiId, "EMTR", s4Class),
                InsulationClass(equiId, insClass),
                if recognizedInsulationClass(insClass).

            EquiCharacteristic(equiId, s4Class, "EMTR_RATED_CURRENT_A", 1, S4Float(current)) :-
                EquiWorkItem3(equiId, "EMTR", s4Class),
                CurrentInA(equiId, current).

            EquiCharacteristic(equiId, s4Class, "EMTR_RATED_POWER_KW", 1, S4Float(power)) :-
                EquiWorkItem3(equiId, "EMTR", s4Class),
                Power(equiId, power, "KILOWATTS").

            EquiCharacteristic(equiId, s4Class, "EMTR_RATED_SPEED_RPM", 1, S4Int(speed)) :- 
                EquiWorkItem3(equiId, "EMTR", s4Class),
                SpeedRPM(equiId, speed).

            /// Units are just VAC or VDC - no conversion
            EquiCharacteristic(equiId, s4Class, "EMTR_RATED_VOLTAGE", 1, S4Int(voltage)) :-
                EquiWorkItem3(equiId, "EMTR", s4Class),
                VoltageIn(equiId, voltage, units),
                if recognizedVoltageUnits(units).

            EquiCharacteristic(equiId, s4Class, "EMTR_RATED_VOLTAGE_UNITS", 1, S4String(voltageUnits(units))) :-
                EquiWorkItem3(equiId, "EMTR", s4Class),
                VoltageIn(equiId, _, units),
                if recognizedVoltageUnits(units).

        };
        solve (rules <+> input) project EquiCharacteristic
            |> AssetLib/GenS4/S4LiteRelations.toSLEquiCharacteristic
}
