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

    use SheetIO/Reader.{XlsxSource};

    use AssetLib/S4Lite/Datatypes.{SLEquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String, S4Float, S4Int};
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3, 
        CurrentInA, InsulationClass, IPRating, Power, SpeedRPM, VoltageIn};
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{recognizedVoltageUnits, voltageUnits};
    
    
    


    type alias StarSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, CurrentInA, IPRating, SpeedRPM, Power, VoltageIn, EquiCharacteristic | r1}

    pub def genStar(workitems: #{EquiWorkItem3 | r1}, facts: StarSchema[r1]): GenMonad[Unit] =
        let workitems1 = workitems as StarSchema[r1];
        star(workitems1 <+> facts)


    /// TODO "STAR_INPUT_CURRENT_A" / "STAR_INPUT_VOLTAGE" ... (STARVF ...)

    pub def star(input: StarSchema[r1]): GenMonad[Unit] = 
        let rules = #{
            EquiCharacteristic(equiId, s4Class, "IP_RATING", 1, S4String(rating)) :-
                EquiWorkItem3(equiId, "STAR", s4Class),
                IPRating(equiId, rating).

            EquiCharacteristic(equiId, s4Class, "STAR_RATED_CURRENT_A", 1, S4Float(current)) :-
                EquiWorkItem3(equiId, "STAR", s4Class),
                CurrentInA(equiId, current).

            EquiCharacteristic(equiId, s4Class, "STAR_RATED_POWER_KW", 1, S4Float(power)) :-
                EquiWorkItem3(equiId, "STAR", s4Class),
                Power(equiId, power, "KILOWATTS").

            EquiCharacteristic(equiId, s4Class, "STAR_RATED_VOLTAGE", 1, S4Int(voltage)) :-
                EquiWorkItem3(equiId, "STAR", s4Class),
                VoltageIn(equiId, voltage, units),
                if recognizedVoltageUnits(units).

            EquiCharacteristic(equiId, s4Class, "STAR_RATED_VOLTAGE_UNITS", 1 , S4String(voltageUnits(units))) :-
                EquiWorkItem3(equiId, "STAR", s4Class),
                VoltageIn(equiId, _, units),
                if recognizedVoltageUnits(units).
        }; 
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(rules <+> input)

}
