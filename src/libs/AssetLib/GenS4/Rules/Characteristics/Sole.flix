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
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3, IPRating, InsulationClass, CurrentInA, PowerUnits, Power};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{recognizedVoltageUnits, voltageUnits, 
        S4InsulationClass, s4InsulationClassRules};

    type alias SoleFacts[r1: SchemaRow] = 
        #{EquiWorkItem3, IPRating, InsulationClass, CurrentInA, Power, S4InsulationClass, EquiCharacteristic | r1}

    pub def genSole(workitems: #{EquiWorkItem3 | r1}, facts: SoleFacts[r1]): GenMonad[Unit] =
        let workitems1 = workitems as SoleFacts[r1];
        sole(workitems1 <+> facts)

    pub def sole(input: SoleFacts[r1]): GenMonad[Unit] =
        let rules = s4InsulationClassRules() <+> #{
            EquiCharacteristic(equiId, s4Class, "IP_RATING", 1, S4String(rating)) :- 
                EquiWorkItem3(equiId, "SOLE", s4Class),
                IPRating(equiId, rating).

            EquiCharacteristic(equiId, s4Class, "INSULATION_CLASS_DEG_C", 1, S4String(s4InsClass)) :-
                EquiWorkItem3(equiId, "SOLE", s4Class),
                InsulationClass(equiId, insClass),
                S4InsulationClass(insClass, s4InsClass).

            EquiCharacteristic(equiId, s4Class, "ACTU_RATED_CURRENT_A", 1, S4Float(current)) :-
                EquiWorkItem3(equiId, "SOLE", s4Class),
                CurrentInA(equiId, current).

            EquiCharacteristic(equiId, s4Class, "ACTU_RATED_POWER_KW", 1, S4Float(power)) :-
                EquiWorkItem3(equiId, "SOLE", s4Class),
                Power(equiId, power, "KILOWATTS").
        }; 
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(rules <+> input)

}
