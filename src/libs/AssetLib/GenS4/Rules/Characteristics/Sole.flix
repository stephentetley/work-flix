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


namespace AssetLib/GenS4/Rules/Characteristics/Sole {

    use SheetIO/Reader.{XlsxSource};

    use AssetLib/S4Lite/Datatypes.{SLEquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String, S4Float, S4Int};
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3, IPRating, InsulationClass, CurrentInA, PowerUnits, Power};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{recognizedVoltageUnits, voltageUnits, 
        recognizedInsulationClass, insulationClass};

    /// src should be electrical facts
    pub def genSole(worklist: List[EquiWorkItem], src: XlsxSource): Result[Chain[SLEquiCharacteristic], String] & Impure =
        use Result.{flatMap};
        let workitems   = AssetLib/GenS4/WorkLists.makeEquiWorkItem3(worklist);
        let* facts      = AssetLib/GenS4/AibFacts/Attributes/Electrical.readElectricalData(src);
        let ans         = sole(workitems <+> facts);
        Ok(ans) 


    pub def sole(input: #{EquiWorkItem3, IPRating, InsulationClass, CurrentInA, Power, 
                            EquiCharacteristic | r}): Chain[SLEquiCharacteristic] & Impure = 
        let rules = #{
            EquiCharacteristic(equiId, s4Class, "IP_RATING", 1, S4String(rating)) :- 
                EquiWorkItem3(equiId, "SOLE", s4Class),
                IPRating(equiId, rating).

            EquiCharacteristic(equiId, s4Class, "INSULATION_CLASS_DEG_C", 1, S4String(insulationClass(insClass))) :-
                EquiWorkItem3(equiId, "SOLE", s4Class),
                InsulationClass(equiId, insClass),
                if recognizedInsulationClass(insClass).

            EquiCharacteristic(equiId, s4Class, "ACTU_RATED_CURRENT_A", 1, S4Float(current)) :-
                EquiWorkItem3(equiId, "SOLE", s4Class),
                CurrentInA(equiId, current).

            EquiCharacteristic(equiId, s4Class, "ACTU_RATED_POWER_KW", 1, S4Float(power)) :-
                EquiWorkItem3(equiId, "SOLE", s4Class),
                Power(equiId, power, "KILOWATTS").
        }; 
        solve (rules <+> input) project EquiCharacteristic
            |> AssetLib/S4Lite/S4LiteRelations.toSLEquiCharacteristic

}
