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


namespace AssetLib/GenS4/Rules/Characteristics/Lstn {

    use AssetLib/AibFacts/Relations.{AibStringValue, AibFloatValue};
    use AssetLib/GenS4/UploadRelations.{ValuaEquiString, ValuaEquiFloat};
    use AssetLib/GenS4/WorkListRelations.{Phase2EquiItem, Phase1EquiItem};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{iEqual};


    /// Note LOCATION_ON_SITE already created.
    pub def lstn(): #{ValuaEquiString, ValuaEquiFloat, 
                        Phase2EquiItem, Phase1EquiItem, 
                        AibStringValue, AibFloatValue | r} = 
        #{
            ValuaEquiString(equiId, "002", "LSTN_SIGNAL_TYPE", "4 - 20 MA", 1) :- 
                Phase2EquiItem(equiId, name, floc,  "LSTN", _),
                Phase1EquiItem(aibref, name, floc,  _, _, _,  _, _, _),
                AibFloatValue(aibref, "SIGNAL_MIN", min),
                AibFloatValue(aibref, "SIGNAL_MAX", max),
                AibStringValue(aibref, "SIGNAL_UNIT", "mA"),
                if iEqual(min, 4) and iEqual(max, 20).

            ValuaEquiString(equiId, "002", "LSTN_SIGNAL_TYPE", "0 - 1 DIGITAL", 1) :- 
                Phase2EquiItem(equiId, name, floc,  "LSTN", _),
                Phase1EquiItem(aibref, name, floc,  _, _, _,  _, _, _),
                AibFloatValue(aibref, "SIGNAL_MIN", min),
                AibFloatValue(aibref, "SIGNAL_MAX", max),
                AibStringValue(aibref, "SIGNAL_UNIT", "Digital"),
                if iEqual(min, 0) and iEqual(max, 1).

            ValuaEquiFloat(equiId, "002", "LSTN_RANGE_MIN", min, 1) :- 
                Phase2EquiItem(equiId, name, floc,  "LSTN", _),
                Phase1EquiItem(aibref, name, floc,  _, _, _,  _, _, _),
                AibFloatValue(aibref, "RANGE_MIN", min),
                AibStringValue(aibref, "RANGE_UNIT", unit),
                if recognizedRangeUnit(unit).

            ValuaEquiFloat(equiId, "002", "LSTN_RANGE_MAX", max, 1) :- 
                Phase2EquiItem(equiId, name, floc,  "LSTN", _),
                Phase1EquiItem(aibref, name, floc,  _, _, _,  _, _, _),
                AibFloatValue(aibref, "RANGE_MAX", max),
                AibStringValue(aibref, "RANGE_UNIT", unit),
                if recognizedRangeUnit(unit).

            ValuaEquiString(equiId, "002", "LSTN_RANGE_UNITS", rangeUnit(unit), 1) :- 
                Phase2EquiItem(equiId, name, floc,  "LSTN", _),
                Phase1EquiItem(aibref, name, floc,  _, _, _,  _, _, _),
                AibStringValue(aibref, "RANGE_UNIT", unit),
                if recognizedRangeUnit(unit).

        }


    def recognizedRangeUnit(s: String): Bool = match s { 
        case "cm/s" => true
        case "l/h" => true
        case "l/s" => true
        case _ => false
    }

    
    def rangeUnit(s: String): String = match s { 
        case "cm/s" => "CM/S"
        case "l/h" => "L/H"
        case "l/s" => "L/S"
        case _ => ""
    }




}
