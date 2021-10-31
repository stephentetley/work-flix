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


namespace AssetLib/GenS4/Rules/Characteristics/Electrical {

    use SheetIO/Reader.{XlsxSource};

    use AssetLib/S4Lite/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String, S4Float, S4Int};
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3, 
        CurrentInA, InsulationClass, IPRating, SpeedRPM, Power, VoltageIn};
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/S4Lite/Datatypes.{SLEquiCharacteristic};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{recognizedVoltageUnits, voltageUnits, 
        S4InsulationClass, s4InsulationClassRules};
    
    pub def genElectricalCharacteristics(workitems: #{EquiWorkItem3 | r1}, facts: #{|r2}): GenMonad[Unit] = 
        use AssetLib/GenS4/GenMonad.{flatMap, return};
        let* _ = genEmtr(workitems, facts as EmtrSchema[r2]);
        return()

    ///  # EMTR

    pub type alias EmtrSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, CurrentInA, InsulationClass, IPRating, SpeedRPM, Power, VoltageIn, S4InsulationClass,
            EquiCharacteristic | r1}


    pub def genEmtr(workitems: #{EquiWorkItem3 | r1}, facts: EmtrSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as EmtrSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> emtrCharacteristics())
        


    /// IP_RATING should be generated on per type (per class?)
    pub def emtrCharacteristics(): EmtrSchema[r1] = #{
            
        EquiCharacteristic(equiId, s4Class, "IP_RATING", 1, S4String(rating)) :- 
            EquiWorkItem3(equiId, "EMTR", s4Class),
            IPRating(equiId, rating).

        EquiCharacteristic(equiId, s4Class, "INSULATION_CLASS_DEG_C", 1, S4String(s4InsClass)) :-
            EquiWorkItem3(equiId, "EMTR", s4Class),
            InsulationClass(equiId, insClass),
            S4InsulationClass(insClass, s4InsClass).

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

        }
        
}
