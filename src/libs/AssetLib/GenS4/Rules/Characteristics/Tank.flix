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


namespace AssetLib/GenS4/Rules/Characteristics/Tank {

    use AssetLib/AibFacts/Relations.{AibStringValue, AibIntValue, AibFloatValue};
    use AssetLib/GenS4/UploadRelations.{ValuaEquiString, ValuaEquiInt, ValuaEquiFloat};
    use AssetLib/GenS4/WorkListRelations.{Phase2EquiItem, Phase1EquiItem};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{recognizedVoltageUnits, voltageUnits, 
        recognizedInsulationClass, insulationClass};


    pub def tank(): #{ValuaEquiString, ValuaEquiInt, ValuaEquiFloat, 
                        Phase2EquiItem, Phase1EquiItem, 
                        AibStringValue, AibIntValue, AibFloatValue | r} = 
        #{
            ValuaEquiString(equiId, "002", "TANK_TANK_LEVEL", tankLevel(level), 1) :- 
                Phase2EquiItem(equiId, name, floc,  "TANK", _),
                Phase1EquiItem(aibref, name, floc,  _, _, _,  _, _, _),
                AibStringValue(aibref, "TANK_LEVEL", level),
                if recognizedTankLevel(level).

                
            ValuaEquiString(equiId, "002", "TANK_TANK_CONSTRUCTION", tankConstruction(ans), 1) :- 
                Phase2EquiItem(equiId, name, floc,  "TANK", _),
                Phase1EquiItem(aibref, name, floc,  _, _, _,  _, _, _),
                AibStringValue(aibref, "TANK_CONSTRUCTION", ans),
                if recognizedTankConstruction(level).                
        }

    def recognizedTankLevel(level: String): Bool = match level { 
        case "ABOVE GROUND" => true
        case "BELOW GROUND" => true
        case _ => false
    }

    def tankLevel(level: String): String = match level { 
        case "ABOVE GROUND" => "ABOVE GROUND"
        case "BELOW GROUND" => "BELOW GROUND"
        case _ => ""
    }

    def recognizedTankConstruction(s: String): Bool = match s { 
        case "CONCRETE" => true
        case "G.R.P." => true
        case "PLASTIC" => true
        case "STAINLESS STEEL" => true
        case "STEEL" => true
        case _ => false
    }

    def tankConstruction(s: String): String = match s { 
        case "CONCRETE" => "CONCRETE"
        case "G.R.P." => "GLASS REINFORCED PLASTIC"
        case "PLASTIC" => "PLASTIC"
        case "STAINLESS STEEL" => "STAINLESS STEEL"
        case "STEEL" => "STEEL"
        case _ => ""
    }

}
