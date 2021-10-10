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

    use AssetLib/S4Lite/Datatypes.{SLEquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String, S4Float};
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3, RangeMinMax, SignalMinMax};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{iEqual};
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};



    /// src should be instrument facts
    pub def genTstn(worklist: List[EquiWorkItem], src: XlsxSource): GenMonad[Unit] =
        use AssetLib/GenS4/GenMonad.{flatMap};
        let workitems   = AssetLib/GenS4/WorkLists.makeEquiWorkItem3(worklist);
        let* facts      = AssetLib/GenS4/AibFacts/Attributes/Instrument.readInstrumentFacts(src);
        tstn(workitems <+> facts)



    pub def tstn(input: #{EquiWorkItem3, RangeMinMax, SignalMinMax,
                            EquiCharacteristic | r1}): GenMonad[Unit] = 
        let rules = #{
            EquiCharacteristic(equiId, s4Class, "TSTN_SIGNAL_TYPE", 1, S4String("4 - 20 MA")) :- 
                EquiWorkItem3(equiId, "TSTN", s4Class),
                SignalMinMax(equiId, smin, smax, "mA"),
                if iEqual(smin, 4) and iEqual(smax, 20).

            EquiCharacteristic(equiId, s4Class, "TSTN_SIGNAL_TYPE", 1, S4String("0 - 1 DIGITAL")) :- 
                EquiWorkItem3(equiId, "TSTN", s4Class),
                SignalMinMax(equiId, smin, smax, "Digital"),
                if iEqual(smin, 0) and iEqual(smax, 1).

            EquiCharacteristic(equiId, s4Class, "TSTN_RANGE_MIN", 1, S4Float(rmin)) :- 
                EquiWorkItem3(equiId, "TSTN", s4Class),
                RangeMinMax(equiId, rmin, _, units),
                if recognizedRangeUnit(units).

            EquiCharacteristic(equiId, s4Class, "TSTN_RANGE_MAX", 1, S4Float(rmax)) :- 
                EquiWorkItem3(equiId, "TSTN", s4Class),
                RangeMinMax(equiId, _, rmax, units),
                if recognizedRangeUnit(units).

            EquiCharacteristic(equiId, s4Class, "TSTN_RANGE_UNITS", 1, S4String(rangeUnit(units))) :- 
                EquiWorkItem3(equiId, "TSTN", s4Class),
                RangeMinMax(equiId, _, _, units),
                if recognizedRangeUnit(units).
        };
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(rules <+> input)


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
