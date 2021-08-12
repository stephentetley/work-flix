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

    use SheetIO/Reader.{XlsxSource};
    use AssetLib/GenS4/AibFacts/Attributes/Instrument.{RangeMin, RangeMax, RangeUnit,
        SignalMin, SignalMax, SignalUnit};
    use AssetLib/S4Lite/Datatypes.{SLEquiCharacteristic};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String, S4Float};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{iEqual};
    use AssetLib/GenS4/Rules/Characteristics/CommonRelations.{EquiWorkItem3};


    /// src should be instrument facts
    pub def genFstn(worklist: List[EquiWorkItem], src: XlsxSource): Result[Chain[SLEquiCharacteristic], String] & Impure =
        use Result.{flatMap};
        let workitems   = AssetLib/GenS4/WorkLists.makeEquiWorkItem3(worklist);
        let* facts      = AssetLib/GenS4/AibFacts/Attributes/Instrument.readInstrumentData(src);
        let ans         = fstn(workitems <+> facts);
        Ok(ans) 


    /// Note LOCATION_ON_SITE already created.
    pub def fstn(input: #{EquiWorkItem3, RangeMin, RangeMax, RangeUnit,
                            SignalMin, SignalMax, SignalUnit, EquiCharacteristic | r1}): Chain[SLEquiCharacteristic] & Impure = 
        let rules = #{
            EquiCharacteristic(equiId, s4Class, "FSTN_SIGNAL_TYPE", 1, S4String("4 - 20 MA")) :- 
                EquiWorkItem3(equiId, "FSTN", s4Class),
                SignalMin(equiId, smin),
                SignalMax(equiId, smax),
                SignalUnit(equiId, "mA"),
                if iEqual(smin, 4) and iEqual(smax, 20).

            EquiCharacteristic(equiId, s4Class, "FSTN_SIGNAL_TYPE", 1, S4String("0 - 1 DIGITAL")) :- 
                EquiWorkItem3(equiId, "FSTN", s4Class),
                SignalMin(equiId, smin),
                SignalMax(equiId, smax),
                SignalUnit(equiId, "Digital"),
                if iEqual(smin, 0) and iEqual(smax, 1).

           EquiCharacteristic(equiId, s4Class, "FSTN_RANGE_MIN", 1, S4Float(rmin)) :-
                EquiWorkItem3(equiId, "FSTN", s4Class),
                RangeMin(equiId, rmin),
                RangeUnit(equiId, unit),
                if recognizedRangeUnit(unit).

            EquiCharacteristic(equiId, s4Class, "FSTN_RANGE_MAX", 1, S4Float(rmax)) :-
                EquiWorkItem3(equiId, "FSTN", s4Class),
                RangeMax(equiId, rmax),
                RangeUnit(equiId,  units),
                if recognizedRangeUnit(units).

            EquiCharacteristic(equiId, s4Class, "FSTN_RANGE_UNITS", 1, S4String(rangeUnit(units))) :-
                EquiWorkItem3(equiId, "FSTN", s4Class),
                RangeUnit(equiId, units),
                if recognizedRangeUnit(units).

        }; 
        solve (rules <+> input) project EquiCharacteristic
            |> AssetLib/GenS4/S4LiteRelations.toSLEquiCharacteristic

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
