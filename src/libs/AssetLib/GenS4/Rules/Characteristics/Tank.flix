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

    use SheetIO/Reader.{XlsxSource};
    use AssetLib/AibFacts/Attributes/Tank.{TankConstruction, TankLevel, TankShape,
        UnitCapacityCum, UnitCentreDepthM, UnitDiameterM, UnitLengthM, UnitSideDepthM, 
        UnitSideDepthMinM, UnitSideDepthMaxM};
    use AssetLib/S4Lite/Datatypes.{SLEquiCharacteristic};
    use AssetLib/GenS4/WorkLists.{EquiWorkItemRec, EquiWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{recognizedVoltageUnits, voltageUnits, 
        recognizedInsulationClass, insulationClass};
    


    /// src should be tank facts
    pub def genTank(worklist: List[EquiWorkItemRec], src: XlsxSource): Result[Chain[SLEquiCharacteristic], String] & Impure =
        use Result.{flatMap};
        let workitems   = AssetLib/GenS4/WorkLists.makeEquiWorkItems(worklist);
        let* facts      = AssetLib/AibFacts/Attributes/Tank.readTankData(src);
        let ans         = tank(workitems <+> facts) |> AssetLib/GenS4/S4LiteRelations.toSLEquiCharacteristic;
        Ok(ans) 

    pub def tank(input: #{EquiWorkItem, TankLevel, 
                            TankConstruction, EquiCharacteristic | r1}): #{EquiCharacteristic | r} = 
        let rules = #{
            EquiCharacteristic(equiId, "002", "TANK_TANK_LEVEL", 1, S4String(tankLevel(level))) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "TANK", s4Class),
                TankLevel(equiId, level),
                if recognizedTankLevel(level).
                
            EquiCharacteristic(equiId, "002", "TANK_TANK_CONSTRUCTION", 1, S4String(tankConstruction(ans))) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "TANK", s4Class),
                TankConstruction(equiId, ans),
                if recognizedTankConstruction(ans).                
        };
        solve (rules <+> input) project EquiCharacteristic

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
