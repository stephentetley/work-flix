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

    use AssetLib/AibFacts/Relations.{AibStringValue, AibIntValue, AibFloatValue};
    use AssetLib/GenS4/UploadRelations.{ValuaEquiText, ValuaEquiInt, ValuaEquiFloat};
    use AssetLib/GenS4/WorkListRelations.{Phase2EquiItem, Phase1EquiItem};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{recognizedVoltageUnits, voltageUnits};


    pub def star(): #{ValuaEquiText, ValuaEquiInt, ValuaEquiFloat, 
                        Phase2EquiItem, Phase1EquiItem, 
                        AibStringValue, AibIntValue, AibFloatValue | r} = 
        #{
            ValuaEquiText(equiId, "002", "IP_RATING", rating, 1) :- 
                Phase2EquiItem(equiId, name, floc,  "STAR", _),
                Phase1EquiItem(aibref, name, floc,  _, _, _,  _, _, _),
                AibStringValue(aibref, "IP_RATING", rating).

            ValuaEquiFloat(equiId, "002", "STAR_RATED_CURRENT_A", current, 1) :-
                Phase2EquiItem(equiId, name, floc,  "STAR", _),
                Phase1EquiItem(aibref, name, floc,  _, _, _,  _, _, _),
                AibFloatValue(aibref, "CURRENT_IN", current).

            ValuaEquiFloat(equiId, "002", "STAR_RATED_POWER_KW", power, 1) :-
                Phase2EquiItem(equiId, name, floc,  "STAR", _),
                Phase1EquiItem(aibref, name, floc,  _, _, _,  _, _, _),
                AibStringValue(aibref, "POWER", "KILOWATTS"),
                AibFloatValue(aibref, "POWER", power).

            ValuaEquiInt(equiId, "002", "STAR_RATED_VOLTAGE", voltage, 1) :-
                Phase2EquiItem(equiId, name, floc,  "STAR", _),
                Phase1EquiItem(aibref, name, floc,  _, _, _,  _, _, _),
                AibStringValue(aibref, "VOLTAGE_IN_AC_OR_DC", units),
                AibIntValue(aibref, "VOLTAGE_IN", voltage),
                if recognizedVoltageUnits(units).

            ValuaEquiText(equiId, "002", "STAR_RATED_VOLTAGE_UNITS", voltageUnits(units), 1) :-
                Phase2EquiItem(equiId, name, floc,  "STAR", _),
                Phase1EquiItem(aibref, name, floc,  _, _, _,  _, _, _),
                AibStringValue(aibref, "VOLTAGE_IN_AC_OR_DC", units),
                AibIntValue(aibref, "VOLTAGE_IN", _),
                if recognizedVoltageUnits(units).

        }


}
