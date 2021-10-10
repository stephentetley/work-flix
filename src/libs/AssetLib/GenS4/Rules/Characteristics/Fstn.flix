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
    
    use AssetLib/S4Lite/Datatypes.{SLEquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String, S4Float};
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3, RangeMinMax, SignalMinMax};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{iEqual};



    type alias FstnFacts[r1: SchemaRow] = 
        #{EquiWorkItem3, RangeMinMax, SignalMinMax, EquiCharacteristic | r1}


    pub def genFstn(workitems: #{EquiWorkItem3 | r1}, facts: FstnFacts[r1]): GenMonad[Unit] =
        let workitems1 = workitems as FstnFacts[r1];
        fstn(workitems1 <+> facts)


    /// Note UNICLASS_CODE / UNICLASS_DESC / LOCATION_ON_SITE already created.
    pub def fstn(input: FstnFacts[r1]): GenMonad[Unit] = 
        let rules = #{
            EquiCharacteristic(equiId, s4Class, "FSTN_SIGNAL_TYPE", 1, S4String("4 - 20 MA")) :- 
                EquiWorkItem3(equiId, "FSTN", s4Class),
                SignalMinMax(equiId, smin, smax, "mA"),
                if iEqual(smin, 4) and iEqual(smax, 20).

            EquiCharacteristic(equiId, s4Class, "FSTN_SIGNAL_TYPE", 1, S4String("0 - 1 DIGITAL")) :- 
                EquiWorkItem3(equiId, "FSTN", s4Class),
                SignalMinMax(equiId, smin, smax, "Digital"),
                if iEqual(smin, 0) and iEqual(smax, 1).

           EquiCharacteristic(equiId, s4Class, "FSTN_RANGE_MIN", 1, S4Float(rmin)) :-
                EquiWorkItem3(equiId, "FSTN", s4Class),
                RangeMinMax(equiId, rmin, _, unit),
                if recognizedRangeUnit(unit).

            EquiCharacteristic(equiId, s4Class, "FSTN_RANGE_MAX", 1, S4Float(rmax)) :-
                EquiWorkItem3(equiId, "FSTN", s4Class),
                RangeMinMax(equiId, _, rmax,  units),
                if recognizedRangeUnit(units).

            EquiCharacteristic(equiId, s4Class, "FSTN_RANGE_UNITS", 1, S4String(rangeUnit(units))) :-
                EquiWorkItem3(equiId, "FSTN", s4Class),
                RangeMinMax(equiId, _, _, units),
                if recognizedRangeUnit(units).

        }; 
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(rules <+> input)

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
