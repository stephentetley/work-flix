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


namespace AssetLib/GenS4/Rules/Characteristics/Instrument {

    use Compatibility.{XlsxSource};

    use AssetLib/S4Lite/Datatypes.{SLEquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String, S4Float};
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3, S4RangeUnit, RangeMinMax, SignalMinMax, Transducer};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{iEqual};
    
    /// Note - we shouldn't concatenate rulesets (fstn, lstn, ...) together as they will 
    /// produce invalid combinations of S4RangeUnit.

    pub def genInstrumentCharacteristics(workitems: #{EquiWorkItem3 | r1}, facts: #{|r2}): GenMonad[Unit] = 
        use AssetLib/GenS4/GenMonad.{flatMap, point};
        let* _ = genFstn(workitems, facts as FstnSchema[r2]);
        let* _ = genLstn(workitems, facts as LstnSchema[r2]);
        let* _ = genPstn(workitems, facts as PstnSchema[r2]);
        let* _ = genTstn(workitems, facts as TstnSchema[r2]);
        point()



    /// # FSTN

    pub type alias FstnSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, S4RangeUnit, RangeMinMax, SignalMinMax, EquiCharacteristic | r1}


    pub def genFstn(workitems: #{EquiWorkItem3 | r1}, facts: FstnSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as FstnSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> fstnCharacteristics())


    /// Note UNICLASS_CODE / UNICLASS_DESC / LOCATION_ON_SITE already created.
    pub def fstnCharacteristics(): FstnSchema[r1] =  #{

        EquiCharacteristic(equiId, s4Class, "FSTN_SIGNAL_TYPE", S4String("4 - 20 MA")) :- 
            EquiWorkItem3(equiId, "FSTN", s4Class),
            SignalMinMax(equiId, smin, smax, "mA"),
            if iEqual(smin, 4) and iEqual(smax, 20).

        EquiCharacteristic(equiId, s4Class, "FSTN_SIGNAL_TYPE", S4String("0 - 1 DIGITAL")) :- 
            EquiWorkItem3(equiId, "FSTN", s4Class),
            SignalMinMax(equiId, smin, smax, "Digital"),
            if iEqual(smin, 0) and iEqual(smax, 1).

        EquiCharacteristic(equiId, s4Class, "FSTN_RANGE_MIN", S4Float(rmin)) :-
            EquiWorkItem3(equiId, "FSTN", s4Class),
            RangeMinMax(equiId, rmin, _, unit),
            S4RangeUnit(unit, _).

        EquiCharacteristic(equiId, s4Class, "FSTN_RANGE_MAX", S4Float(rmax)) :-
            EquiWorkItem3(equiId, "FSTN", s4Class),
            RangeMinMax(equiId, _, rmax,  units),
            S4RangeUnit(units, _).

        EquiCharacteristic(equiId, s4Class, "FSTN_RANGE_UNITS", S4String(s4Units)) :-
            EquiWorkItem3(equiId, "FSTN", s4Class),
            RangeMinMax(equiId, _, _, units),
            S4RangeUnit(units, s4Units).
        
        S4RangeUnit("cm/s", "CM/S").
        S4RangeUnit("l/h", "L/H").
        S4RangeUnit("l/s",  "L/S").

    }

    

    /// # LSTN

    pub type alias LstnSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, S4RangeUnit, RangeMinMax, SignalMinMax, Transducer, EquiCharacteristic | r1}


    pub def genLstn(workitems: #{EquiWorkItem3 | r1}, facts: LstnSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as LstnSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> lstnCharacteristics())


    pub def lstnCharacteristics(): LstnSchema[r1] = #{

        EquiCharacteristic(equiId, s4Class, "LSTN_SIGNAL_TYPE", S4String("4 - 20 MA")) :- 
            EquiWorkItem3(equiId, "LSTN", s4Class),
            SignalMinMax(equiId, smin, smax, "mA"),
            if iEqual(smin, 4) and iEqual(smax, 20).

        EquiCharacteristic(equiId, s4Class, "LSTN_SIGNAL_TYPE", S4String("0 - 1 DIGITAL")) :- 
            EquiWorkItem3(equiId, "LSTN", s4Class),
            SignalMinMax(equiId, smin, smax, "Digital"),
            if iEqual(smin, 0) and iEqual(smax, 1).

        EquiCharacteristic(equiId, s4Class, "LSTN_RANGE_MIN", S4Float(rmin)) :- 
            EquiWorkItem3(equiId, "LSTN", s4Class),
            RangeMinMax(equiId, rmin, _, units),
            S4RangeUnit(units, _).

        EquiCharacteristic(equiId, s4Class, "LSTN_RANGE_MAX", S4Float(rmax)) :- 
            EquiWorkItem3(equiId, "LSTN", s4Class),
            RangeMinMax(equiId, _, rmax, units),
            S4RangeUnit(units, _).

        EquiCharacteristic(equiId, s4Class, "LSTN_RANGE_UNITS", S4String(s4Units)) :- 
            EquiWorkItem3(equiId, "LSTN", s4Class),
            RangeMinMax(equiId, _, _, units),
            S4RangeUnit(units, s4Units).

        EquiCharacteristic(equiId, s4Class, "LSTN_TRANSDUCER_MODEL", S4String(model)) :- 
            EquiWorkItem3(equiId, "LSTN", s4Class),
            Transducer(equiId, model, _).

        EquiCharacteristic(equiId, s4Class, "LSTN_TRANSDUCER_SERIAL_NO", S4String(snum)) :- 
            EquiWorkItem3(equiId, "LSTN", s4Class),
            Transducer(equiId, _, snum), 
            if not String.isEmpty(snum).


        S4RangeUnit("m", "M").
        S4RangeUnit("cm/s", "CM/S"). 
        S4RangeUnit("l/h",  "L/H"). 
        S4RangeUnit("l/s", "L/S").

    }

    /// # PSTN

    pub type alias PstnSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, S4RangeUnit, RangeMinMax, SignalMinMax, EquiCharacteristic | r1}


    pub def genPstn(workitems: #{EquiWorkItem3 | r1}, facts: PstnSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as PstnSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> pstnCharacteristics())

    pub def pstnCharacteristics(): PstnSchema[r1] = #{

        EquiCharacteristic(equiId, s4Class, "PSTN_SIGNAL_TYPE", S4String("4 - 20 MA")) :- 
            EquiWorkItem3(equiId, "PSTN", s4Class),
            SignalMinMax(equiId, smin, smax, "mA"),
            if iEqual(smin, 4) and iEqual(smax, 20).

        EquiCharacteristic(equiId, s4Class, "PSTN_SIGNAL_TYPE", S4String("0 - 1 DIGITAL")) :- 
            EquiWorkItem3(equiId, "PSTN", s4Class),
            SignalMinMax(equiId, smin, smax, "Digital"),
            if iEqual(smin, 0) and iEqual(smax, 1).

        EquiCharacteristic(equiId, s4Class, "PSTN_RANGE_MIN", S4Float(rmin)) :- 
            EquiWorkItem3(equiId, "PSTN", s4Class),
            RangeMinMax(equiId, rmin, _, units),
            S4RangeUnit(units, _).

        EquiCharacteristic(equiId, s4Class, "PSTN_RANGE_MAX", S4Float(rmax)) :- 
            EquiWorkItem3(equiId, "PSTN", s4Class),
            RangeMinMax(equiId, _, rmax, units),
            S4RangeUnit(units, _).

        EquiCharacteristic(equiId, s4Class, "PSTN_RANGE_UNITS", S4String(s4Units)) :- 
            EquiWorkItem3(equiId, "PSTN", s4Class),
            RangeMinMax(equiId, _, _, units),
            S4RangeUnit(units, s4Units).

        S4RangeUnit("Bar", "BAR").

    }
   
    


    /// # TSTN


    pub type alias TstnSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, S4RangeUnit, RangeMinMax, SignalMinMax, EquiCharacteristic | r1}

    pub def genTstn(workitems: #{EquiWorkItem3 | r1}, facts: TstnSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as TstnSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> tstnCharacteristics())

    pub def tstnCharacteristics(): TstnSchema[r1] = #{
        EquiCharacteristic(equiId, s4Class, "TSTN_SIGNAL_TYPE", S4String("4 - 20 MA")) :- 
            EquiWorkItem3(equiId, "TSTN", s4Class),
            SignalMinMax(equiId, smin, smax, "mA"),
            if iEqual(smin, 4) and iEqual(smax, 20).

        EquiCharacteristic(equiId, s4Class, "TSTN_SIGNAL_TYPE", S4String("0 - 1 DIGITAL")) :- 
            EquiWorkItem3(equiId, "TSTN", s4Class),
            SignalMinMax(equiId, smin, smax, "Digital"),
            if iEqual(smin, 0) and iEqual(smax, 1).

        EquiCharacteristic(equiId, s4Class, "TSTN_RANGE_MIN", S4Float(rmin)) :- 
            EquiWorkItem3(equiId, "TSTN", s4Class),
            RangeMinMax(equiId, rmin, _, units),
            S4RangeUnit(units, _).

        EquiCharacteristic(equiId, s4Class, "TSTN_RANGE_MAX", S4Float(rmax)) :- 
            EquiWorkItem3(equiId, "TSTN", s4Class),
            RangeMinMax(equiId, _, rmax, units),
            S4RangeUnit(units, _).

        EquiCharacteristic(equiId, s4Class, "TSTN_RANGE_UNITS", S4String(s4units)) :- 
            EquiWorkItem3(equiId, "TSTN", s4Class),
            RangeMinMax(equiId, _, _, units),
            S4RangeUnit(units, s4units).

    
        S4RangeUnit("Deg C", "DEG C").
        S4RangeUnit("Deg F", "DEG F").

    }





}
