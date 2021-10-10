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


namespace AssetLib/GenS4/Rules/Characteristics/Fans {

    use SheetIO/Reader.{XlsxSource};
    
    use AssetLib/S4Lite/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4Int, S4Float, S4String};
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3, SpeedRPM, TypeOfFan, RatingPower};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};


    /// src should be Fan facts
    pub def genFans(worklist: List[EquiWorkItem], src: XlsxSource): GenMonad[Unit] =
        use AssetLib/GenS4/GenMonad.{flatMap};
        let workitems   = AssetLib/GenS4/WorkLists.makeEquiWorkItem3(worklist);
        let* facts      = AssetLib/GenS4/AibFacts/Attributes/Fan.readFanFacts(src);
        fans(workitems <+> facts) 

    rel S4FanType(aibType: String, s4Type: String)

    pub def fans(input: #{EquiWorkItem3, SpeedRPM, RatingPower, TypeOfFan, S4FanType, EquiCharacteristic | r1}): GenMonad[Unit] = 
        let rules = #{
            EquiCharacteristic(equiId, s4Class, "FANS_RATED_SPEED_RPM", 1, S4Int(speed)) :- 
                EquiWorkItem3(equiId, "FANS", s4Class),
                SpeedRPM(equiId, speed).

            EquiCharacteristic(equiId, s4Class, "FANS_TYPE", 1, S4String(s4type)) :- 
                EquiWorkItem3(equiId, "FANS", s4Class),
                TypeOfFan(equiId, aibtype),
                S4FanType(aibtype, s4type).

            S4FanType("EXTRACTOR FAN", "EXTRACTOR"). 
            S4FanType("FORCED AIR FAN", "FORCED AIR"). 

            EquiCharacteristic(equiId, s4Class, "FANS_RATED_POWER_KW", 1, S4Float(power)) :- 
                EquiWorkItem3(equiId, "FANS", s4Class),
                RatingPower(equiId, power, "KILOWATTS").
                
        }; 
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(rules <+> input)


}
