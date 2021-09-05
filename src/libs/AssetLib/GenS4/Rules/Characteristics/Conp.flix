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

    use SheetIO/Reader.{XlsxSource};

    use AssetLib/GenS4/Base/CommonRelations.{CurrentInA, InsulationClass, 
        IPRating, Power, SpeedRPM, VoltageIn};
    use AssetLib/S4Lite/Datatypes.{SLEquiCharacteristic};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};
    use AssetLib/S4Lite/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String, S4Float, S4Int};
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{recognizedVoltageUnits, voltageUnits};
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3};
    

    /// src should be electrical facts
    pub def genConp(worklist: List[EquiWorkItem], src: XlsxSource): GenMonad[Unit] =
        use AssetLib/GenS4/GenMonad.{flatMap};
        let workitems   = AssetLib/GenS4/WorkLists.makeEquiWorkItem3(worklist);
        let* facts      = AssetLib/GenS4/AibFacts/Attributes/Electrical.readElectricalData(src);
        conp(workitems <+> facts)


    pub def conp(input: #{EquiWorkItem3, CurrentInA, VoltageIn, 
                            EquiCharacteristic | r1}): GenMonad[Unit] = 
        let rules = #{
            EquiCharacteristic(equiId, s4Class, "CONP_RATED_CURRENT_A", 1, S4Float(current)) :-
                EquiWorkItem3(equiId, "CONP", s4Class),
                CurrentInA(equiId, current).

            EquiCharacteristic(equiId, s4Class, "CONP_RATED_VOLTAGE", 1, S4Int(voltage)) :-
                EquiWorkItem3(equiId, "CONP", s4Class),
                VoltageIn(equiId, voltage, units),
                if recognizedVoltageUnits(units).

            EquiCharacteristic(equiId, s4Class, "CONP_RATED_VOLTAGE_UNITS", 1, S4String(voltageUnits(units))) :-
                EquiWorkItem3(equiId, "CONP", s4Class),
                VoltageIn(equiId, _, units),
                if recognizedVoltageUnits(units).
        }; 
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(rules <+> input)

}
