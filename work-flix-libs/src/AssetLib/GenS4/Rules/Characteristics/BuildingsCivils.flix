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


namespace AssetLib/GenS4/Rules/Characteristics/BuildingsCivils {

    use Compatibility.{XlsxSource};

    use AssetLib/S4Lite/Datatypes.{SLEquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String};
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3, 
        TankConstruction, TankLevel, TankShape, UnitCapacityCum, UnitCentreDepthM, UnitDiameterM, 
        UnitLengthM, UnitSideDepthM, UnitSideDepthMaxM, UnitSideDepthMinM};
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};
    
    pub def genBuildingsCivilsCharacteristics(workitems: #{EquiWorkItem3 | r1}, facts: #{|r2}): GenMonad[Unit] = 
        use AssetLib/GenS4/GenMonad.{flatMap, point};
        let* _ = genKisk(workitems, facts as KiskSchema[r2]);
        let* _ = genTank(workitems, facts as TankSchema[r2]);
        point()

    /// # KISK

    pub type alias KiskSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, EquiCharacteristic | r1}

    pub def genKisk(workitems: #{EquiWorkItem3 | r1}, facts: KiskSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as KiskSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> kiskCharacteristics())


    pub def kiskCharacteristics(): KiskSchema[r1] = #{

        /// EquiCharacteristic(equiId, "002", "TANK_TANK_LEVEL", S4String(s4Level)) :-
        ///     EquiWorkItem3(equiId, "TANK", _),
        ///     TankLevel(equiId, level),
        ///     S4TankLevel(level, s4Level).

    }


    /// # TANK

    pub type alias TankSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, S4TankConstruction, S4TankLevel, TankLevel, TankConstruction, EquiCharacteristic | r1}

    pub def genTank(workitems: #{EquiWorkItem3 | r1}, facts: TankSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as TankSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> tankCharacteristics())

    pub rel S4TankLevel(aibLevel: String, s4Level: String)
    pub rel S4TankConstruction(aibConstr: String, s4Constr: String)

    pub def tankCharacteristics(): TankSchema[r1] = #{

        EquiCharacteristic(equiId, "002", "TANK_TANK_LEVEL", S4String(s4Level)) :-
            EquiWorkItem3(equiId, "TANK", _),
            TankLevel(equiId, level),
            S4TankLevel(level, s4Level).
            
        EquiCharacteristic(equiId, "002", "TANK_TANK_CONSTRUCTION", S4String(s4Constr)) :-
            EquiWorkItem3(equiId, "TANK", _),
            TankConstruction(equiId, constr),
            S4TankConstruction(constr, s4Constr).

        S4TankLevel("ABOVE GROUND", "ABOVE GROUND").
        S4TankLevel("BELOW GROUND", "BELOW GROUND").

        S4TankConstruction("CONCRETE", "CONCRETE").
        S4TankConstruction("G.R.P.", "GLASS REINFORCED PLASTIC").
        S4TankConstruction("PLASTIC", "PLASTIC").
        S4TankConstruction("STAINLESS STEEL", "STAINLESS STEEL").
        S4TankConstruction("STEEL", "STEEL").


    }


    

}
