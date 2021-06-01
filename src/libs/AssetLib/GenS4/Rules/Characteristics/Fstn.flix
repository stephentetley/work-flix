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


namespace AssetLib/GenS4/Rules/Characteristics/Fstn {

    use AssetLib/AibFacts/Relations.{AibStringValue, AibFloatValue};
    use AssetLib/GenS4/WorkListRelations.{EquiWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String, S4Float};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{iEqual};



    /// Note LOCATION_ON_SITE already created.
    pub def fstn(input: #{EquiWorkItem, AibStringValue, 
                            AibFloatValue, EquiCharacteristic | r}): #{EquiCharacteristic | r} = 
        let rules = #{
            EquiCharacteristic(equiId, s4Class, "FSTN_SIGNAL_TYPE", 1, S4String("4 - 20 MA")) :- 
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "FSTN", s4Class),
                AibFloatValue(equiId, "SIGNAL_MIN", min),
                AibFloatValue(equiId, "SIGNAL_MAX", max),
                AibStringValue(equiId, "SIGNAL_UNIT", "mA"),
                if iEqual(min, 4) and iEqual(max, 20).

            EquiCharacteristic(equiId, s4Class, "FSTN_SIGNAL_TYPE", 1, S4String("0 - 1 DIGITAL")) :- 
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "FSTN", s4Class),
                AibFloatValue(equiId, "SIGNAL_MIN", min),
                AibFloatValue(equiId, "SIGNAL_MAX", max),
                AibStringValue(equiId, "SIGNAL_UNIT", "Digital"),
                if iEqual(min, 0) and iEqual(max, 1).

           EquiCharacteristic(equiId, s4Class, "FSTN_RANGE_MIN", 1, S4Float(min)) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "FSTN", s4Class),
                AibFloatValue(equiId, "RANGE_MIN", min),
                AibStringValue(equiId, "RANGE_UNIT", unit),
                if recognizedRangeUnit(unit).

            EquiCharacteristic(equiId, s4Class, "FSTN_RANGE_MAX", 1, S4Float(max)) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "FSTN", s4Class),
                AibFloatValue(equiId, "RANGE_MAX", max),
                AibStringValue(equiId, "RANGE_UNIT", unit),
                if recognizedRangeUnit(unit).

            EquiCharacteristic(equiId, s4Class, "FSTN_RANGE_UNITS", 1, S4String(rangeUnit(unit))) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "FSTN", s4Class),
                AibStringValue(equiId, "RANGE_UNIT", unit),
                if recognizedRangeUnit(unit).

        }; 
        solve (rules <+> input) project EquiCharacteristic


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
