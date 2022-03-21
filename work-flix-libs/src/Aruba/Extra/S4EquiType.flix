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

namespace Aruba/Extra/S4EquiType {


    pub rel S4EquiType(itemId: String, category: String, objType: String, objClass: String)
    pub rel AibEquiType(itemId: String, typeName: String)
    pub rel ValveType(itemId: String, valveType: String)

    pub def getTypeFromCommonName(commonName: String): Result[Option[String], String] = 
        getTypeFromCommonNameHelper(commonName) as & Pure

    def getTypeFromCommonNameHelper(commonName: String): Result[Option[String], String] & Impure = 
        use Result.flatMap;
        use Text/RegexEval/MatchEvaluator.{optional, getCaptureNamed};
        let* patt = Text/Regex/Pattern.compile("(?<equitype>EQUIPMENT: .+)$");
        let eval = getCaptureNamed("equitype");
        match Text/RegexEval/Regex.contains(patt, eval, commonName) {
            /// Error means both "not found" and operational error - Regex API needs changing to support optional `evalContains`...
            case Err(_) => Ok(None)
            case Ok(s) => Ok(Some(s))
        }




    pub def s4EquiTypeRules(): #{AibEquiType, ValveType, S4EquiType | r} = #{
        
        S4EquiType(itemId, "M", "VALV", "VALVBA") :- 
            AibEquiType(itemId, "EQUIPMENT: ISOLATING VALVES"), 
            ValveType(itemId, "Ball").

        S4EquiType(itemId, "M", "VALV", "VALVGA") :- 
            AibEquiType(itemId, "EQUIPMENT: ISOLATING VALVES"), 
            ValveType(itemId, "Wedge Gate").

        S4EquiType(itemId, "M", "VALV", "VALVGA") :- 
            AibEquiType(itemId, "EQUIPMENT: ISOLATING VALVES"), 
            ValveType(itemId, "Knife Gate").

        S4EquiType(itemId, "M", "VALV", "VALVMW") :- 
            AibEquiType(itemId, "EQUIPMENT: MULTI-WAY VALVE").

        S4EquiType(itemId, "M", "VALV", "VALVNR") :- 
            AibEquiType(itemId, "EQUIPMENT: NON RETURN VALVE").

        S4EquiType(itemId, "M", "VALV", "VALVRE") :- 
            AibEquiType(itemId, "EQUIPMENT: PRESSURE REGULATING VALVE").

        S4EquiType(itemId, "M", "VALV", "VALVSF") :- 
            AibEquiType(itemId, "EQUIPMENT: RELIEF/SAFETY VALVE").


        S4EquiType(itemId, "I", "LSTN", "LSTNFL") :- 
            AibEquiType(itemId, "EQUIPMENT: FLOAT LEVEL INSTRUMENT").

        S4EquiType(itemId, "I", "LSTN", "LSTNUT") :- 
            AibEquiType(itemId, "EQUIPMENT: ULTRASONIC LEVEL INSTRUMENT").


        S4EquiType(itemId, "H", "VEPR", "VEPRAW") :- 
            AibEquiType(itemId, "EQUIPMENT: WATER/AIR RECEIVER").

        S4EquiType(itemId, "H", "VEPR", "VEPRPD") :- 
            AibEquiType(itemId, "EQUIPMENT: PULSATION DAMPER").


        S4EquiType(itemId, "E", "MCCE", "MCCEPA") :- 
            AibEquiType(itemId, "EQUIPMENT: MCC UNIT").

        S4EquiType(itemId, "E", "PODE", "PODEUP") :- 
            AibEquiType(itemId, "EQUIPMENT: UPS SYSTEMS").

        S4EquiType(itemId, "E", "HEAT", "HEATIM") :- 
            AibEquiType(itemId, "EQUIPMENT: IMMERSION HEATER").

        S4EquiType(itemId, "E", "HEAT", "HEATTR") :- 
            AibEquiType(itemId, "EQUIPMENT: TRACE HEATERS").

        S4EquiType(itemId, "M", "STRN", "STRNER") :- 
            AibEquiType(itemId, "EQUIPMENT: STRAINER").

        S4EquiType(itemId, "E", "SLIP", "SLIPRA") :- 
            AibEquiType(itemId, "EQUIPMENT: SLIP RING ASSEMBLY").
            
    }

}