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
    use AssetLib/AibFacts/Attributes/Electrical.{CurrentIn, InsulationClass, 
        IPRating, SpeedRPM, Power, PowerUnits, VoltageIn, VoltageInACOrDC};
    use AssetLib/S4Lite/Datatypes.{SLEquiCharacteristic};
    use AssetLib/GenS4/WorkLists.{EquipmentWorkItem, EquiWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String, S4Float, S4Int};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{recognizedVoltageUnits, voltageUnits, 
        recognizedInsulationClass, insulationClass};
    

    /// src should be electrical facts
    pub def genEmtr(worklist: List[EquipmentWorkItem], src: XlsxSource): Result[Chain[SLEquiCharacteristic], String] & Impure =
        use Result.{flatMap};
        let workitems   = AssetLib/GenS4/WorkLists.makeEquiWorkItems(worklist);
        let* facts      = AssetLib/AibFacts/Attributes/Electrical.readElectricalData(src);
        let ans         = emtr(workitems <+> facts) |> AssetLib/GenS4/S4LiteRelations.toSLEquiCharacteristic;
        Ok(ans) 


    /// IP_RATING should be generated on per type (per class?)
    pub def emtr(input: #{EquiWorkItem, CurrentIn, InsulationClass, 
                            IPRating, SpeedRPM, Power, 
                            PowerUnits, VoltageIn, VoltageInACOrDC, 
                            EquiCharacteristic | r1}): #{EquiCharacteristic | r} = 
        let rules = #{
            EquiCharacteristic(equiId, s4Class, "IP_RATING", 1, S4String(rating)) :- 
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "EMTR", s4Class),
                IPRating(equiId, rating).

            EquiCharacteristic(equiId, s4Class, "INSULATION_CLASS_DEG_C", 1, S4String(insulationClass(insClass))) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "EMTR", s4Class),
                InsulationClass(equiId, insClass),
                if recognizedInsulationClass(insClass).

            EquiCharacteristic(equiId, s4Class, "EMTR_RATED_CURRENT_A", 1, S4Float(current)) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "EMTR", s4Class),
                CurrentIn(equiId, current).

            EquiCharacteristic(equiId, s4Class, "EMTR_RATED_POWER_KW", 1, S4Float(power)) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "EMTR", s4Class),
                PowerUnits(aibref, "KILOWATTS"),
                Power(equiId, power).

            EquiCharacteristic(equiId, s4Class, "EMTR_RATED_SPEED_RPM", 1, S4Int(speed)) :- 
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "EMTR", s4Class),
                SpeedRPM(equiId, speed).

            EquiCharacteristic(equiId, s4Class, "EMTR_RATED_VOLTAGE", 1, S4Int(voltage)) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "EMTR", s4Class),
                VoltageInACOrDC(equiId, units),
                VoltageIn(equiId, voltage),
                if recognizedVoltageUnits(units).

            EquiCharacteristic(equiId, s4Class, "EMTR_RATED_VOLTAGE_UNITS", 1, S4String(voltageUnits(units))) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "EMTR", s4Class),
                VoltageInACOrDC(equiId, units),
                VoltageIn(equiId, _),
                if recognizedVoltageUnits(units).

        };
        solve (rules <+> input) project EquiCharacteristic

}
