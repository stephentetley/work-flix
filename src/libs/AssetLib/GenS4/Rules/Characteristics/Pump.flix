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


namespace AssetLib/GenS4/Rules/Characteristics/Pump {

    use AssetLib/AibFacts/Relations.{AibStringValue, AibFloatValue};
    use AssetLib/GenS4/UploadRelations.{ValuaEquiText, ValuaEquiFloat};
    use AssetLib/GenS4/WorkListRelations.{Phase2EquiItem, Phase1EquiItem};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{iEqual};


    pub def pump(): #{ValuaEquiText, ValuaEquiFloat, 
                        Phase2EquiItem, Phase1EquiItem, 
                        AibStringValue, AibFloatValue | r} = 
        #{

            ValuaEquiFloat(equiId, "002", "PUMP_FLOW_LITERS_PER_SEC", flowLitresPerSecond(flow, unit), 1) :- 
                Phase2EquiItem(equiId, name, floc,  "PUMP", _),
                Phase1EquiItem(aibref, name, floc,  _, _, _,  _, _, _),
                AibFloatValue(aibref, "FLOW", flow),
                AibStringValue(aibref, "FLOW_UNIT", unit),
                if recognizedFlowUnit(unit).

            /// ValuaEquiFloat(equiId, "002", "LSTN_RANGE_MAX", max, 1) :- 
            ///     Phase2EquiItem(equiId, name, floc,  "LSTN", _),
            ///     Phase1EquiItem(aibref, name, floc,  _, _, _,  _, _, _),
            ///     AibFloatValue(aibref, "RANGE_MAX", max),
            ///     AibStringValue(aibref, "RANGE_UNIT", unit),
            ///     if recognizedRangeUnit(unit).

            /// ValuaEquiText(equiId, "002", "LSTN_RANGE_UNITS", rangeUnit(unit), 1) :- 
            ///     Phase2EquiItem(equiId, name, floc,  "LSTN", _),
            ///     Phase1EquiItem(aibref, name, floc,  _, _, _,  _, _, _),
            ///     AibStringValue(aibref, "RANGE_UNIT", unit),
            ///     if recognizedRangeUnit(unit).

        }


    def recognizedFlowUnit(units: String): Bool = match units { 
        case "LITRE PER HOUR" => true
        case "LITRE PER MINUTE" => true
        case "LITRES PER SECOND" => true
        case _ => false
    }

    
    def flowLitresPerSecond(flow: Float64, units: String): Float64 = match units { 
        case "LITRE PER HOUR" => flow / 3600.0f64
        case "LITRE PER MINUTE" => flow / 60.0f64
        case "LITRES PER SECOND" => flow
        case _ => -1.0f64
    }


}
