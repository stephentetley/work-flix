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


namespace AssetLib/GenS4/Rules/Characteristics/Tstn {

    use SheetIO/Reader.{XlsxSource};
    use AssetLib/AibFacts/Attributes/Instrument.{RangeMin, RangeMax, RangeUnit,
        SignalMin, SignalMax, SignalUnit};
    use AssetLib/S4Lite/Datatypes.{SLEquiCharacteristic};
    use AssetLib/GenS4/WorkLists.{EquipmentWorkItem, EquiWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String, S4Float};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{iEqual};



    /// src should be instrument facts
    pub def genTstn(worklist: List[EquipmentWorkItem], src: XlsxSource): Result[Chain[SLEquiCharacteristic], String] & Impure =
        use Result.{flatMap};
        let workitems   = AssetLib/GenS4/WorkLists.makeEquiWorkItems(worklist);
        let* facts      = AssetLib/AibFacts/Attributes/Instrument.readInstrumentData(src);
        let ans         = tstn(workitems <+> facts) |> AssetLib/GenS4/S4LiteRelations.toSLEquiCharacteristic;
        Ok(ans) 


    pub def tstn(input: #{EquiWorkItem, RangeMin, RangeMax, RangeUnit,
                            SignalMin, SignalMax, SignalUnit, EquiCharacteristic | r1}): #{EquiCharacteristic | r} = 
        let rules = #{
            EquiCharacteristic(equiId, s4Class, "TSTN_SIGNAL_TYPE", 1, S4String("4 - 20 MA")) :- 
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "TSTN", s4Class),
                SignalMin(equiId, smin),
                SignalMax(equiId, smax),
                SignalUnit(equiId, "mA"),
                if iEqual(smin, 4) and iEqual(smax, 20).

            EquiCharacteristic(equiId, s4Class, "TSTN_SIGNAL_TYPE", 1, S4String("0 - 1 DIGITAL")) :- 
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "TSTN", s4Class),
                SignalMin(equiId, smin),
                SignalMax(equiId, smax),
                SignalUnit(equiId, "Digital"),
                if iEqual(smin, 0) and iEqual(smax, 1).

            EquiCharacteristic(equiId, s4Class, "TSTN_RANGE_MIN", 1, S4Float(rmin)) :- 
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "TSTN", s4Class),
                RangeMin(equiId, rmin),
                RangeUnit(equiId, units),
                if recognizedRangeUnit(units).

            EquiCharacteristic(equiId, s4Class, "TSTN_RANGE_MAX", 1, S4Float(rmax)) :- 
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "TSTN", s4Class),
                RangeMax(equiId, rmax),
                RangeUnit(equiId, units),
                if recognizedRangeUnit(units).

            EquiCharacteristic(equiId, s4Class, "TSTN_RANGE_UNITS", 1, S4String(rangeUnit(units))) :- 
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "TSTN", s4Class),
                RangeUnit(equiId, units),
                if recognizedRangeUnit(units).
        };
        solve (rules <+> input) project EquiCharacteristic

    def recognizedRangeUnit(s: String): Bool = match s { 
        case "Deg C" => true
        case "Deg F" => true
        case _ => false
    }

    
    def rangeUnit(s: String): String = match s { 
        case "Deg C" => "DEG C"
        case "Deg F" => "DEG F"
        case _ => ""
    }




}
