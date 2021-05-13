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
    use AssetLib/GenS4/UploadRelations.{ValuaEquiString, ValuaEquiFloat};
    use AssetLib/GenS4/WorkListRelations.{Phase2EquiItem, Phase1EquiItem};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{iEqual};


    pub def pump(): #{ValuaEquiString, ValuaEquiFloat, 
                        Phase2EquiItem, Phase1EquiItem, 
                        AibStringValue, AibFloatValue | r} = 
        #{

            ValuaEquiFloat(equiId, "002", "PUMP_FLOW_LITERS_PER_SEC", flowLitresPerSecond(flow, unit), 1) :- 
                Phase2EquiItem(equiId, name, floc,  "PUMP", _),
                Phase1EquiItem(aibref, name, floc,  _, _, _,  _, _, _),
                AibFloatValue(aibref, "FLOW", flow),
                AibStringValue(aibref, "FLOW_UNITS", unit),
                if recognizedFlowUnits(unit).

            ValuaEquiFloat(equiId, "002", "PUMP_INSTALLED_DESIGN_HEAD_M", ans, 1) :- 
                Phase2EquiItem(equiId, name, floc,  "PUMP", _),
                Phase1EquiItem(aibref, name, floc,  _, _, _,  _, _, _),
                AibFloatValue(aibref, "DUTY_HEAD", ans),
                AibStringValue(aibref, "DUTY_HEAD_UNITS", "METRES").

            /// TODO may have to limit pump-classes here...
            ValuaEquiString(equiId, "002", "PUMP_IMPELLER_TYPE", ans, 1) :- 
                Phase2EquiItem(equiId, name, floc,  "PUMP", _),
                Phase1EquiItem(aibref, name, floc,  _, _, _,  _, _, _),
                AibStringValue(aibref, "IMPELLER_TYPE", ans).

                
            ValuaEquiString(equiId, "002", "PUMP_DIAPHRAGM_MATERIAL", diaphragmMaterial(material), 1) :- 
                Phase2EquiItem(equiId, name, floc,  "PUMP", _),
                Phase1EquiItem(aibref, name, floc,  _, _, _,  _, _, _),
                AibStringValue(aibref, "DIAPHRAGM_MATERIAL", material),
                if recognizedDiaphragmMaterial(material).

            ValuaEquiFloat(equiId, "002", "PUMP_RATED_POWER_KW", ans, 1) :- 
                Phase2EquiItem(equiId, name, floc,  "PUMP", _),
                Phase1EquiItem(aibref, name, floc,  _, _, _,  _, _, _),
                AibFloatValue(aibref, "RATING_POWER", ans),
                AibStringValue(aibref, "RATING_UNITS", "KILOWATTS").


        }


    def recognizedFlowUnits(units: String): Bool = match units { 
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

    def recognizedDiaphragmMaterial(s: String): Bool = match s { 
        case "EPDM" => true
        case _ => false
    }

    
    def diaphragmMaterial(s: String): String = match s { 
        case "EPDM" => "EPMD"
        case _ => ""
    }


}
