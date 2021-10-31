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


namespace AssetLib/GenS4/Rules/Characteristics/Statutory {

    use SheetIO/Reader.{XlsxSource};
    
    use AssetLib/S4Lite/Datatypes.{SLEquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String, S4Float};
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3, S4LoadUnit, WorkLoad, TestCertNo, YWRef};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{iEqual};
    


    pub def genStatutoryCharacteristics(workitems: #{EquiWorkItem3 | r1}, facts: #{|r2}): GenMonad[Unit] = 
        use AssetLib/GenS4/GenMonad.{flatMap, return};
        let* _ = genCrht(workitems, facts as CrhtSchema[r2]);
        let* _ = genLiac(workitems, facts as LiacSchema[r2]);
        let* _ = genLisl(workitems, facts as LislSchema[r2]);
        let* _ = genSfer(workitems, facts as SferSchema[r2]);
        return()

    /// # CRHT

    pub type alias CrhtSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, S4LoadUnit, WorkLoad, TestCertNo, YWRef, EquiCharacteristic | r1}


    pub def genCrht(workitems: #{EquiWorkItem3 | r1}, facts: CrhtSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as CrhtSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> crhtCharacteristics())

    /// Note UNICLASS_CODE / UNICLASS_DESC / LOCATION_ON_SITE already created.
    pub def crhtCharacteristics(): CrhtSchema[r1] = #{

        EquiCharacteristic(equiId, s4Class, "STATUTORY_REFERENCE_NUMBER", 1, S4String(ywref)) :- 
            EquiWorkItem3(equiId, "CRHT", s4Class),
            YWRef(equiId, ywref).

        EquiCharacteristic(equiId, s4Class, "TEST_CERT_NO", 1, S4String(number)) :- 
            EquiWorkItem3(equiId, "CRHT", s4Class),
            TestCertNo(equiId, number).

        EquiCharacteristic(equiId, s4Class, "CRHT_SAFE_WORKING_LOAD", 1, S4Float(load)) :-
            EquiWorkItem3(equiId, "CRHT", s4Class),
            WorkLoad(equiId, load, units),
            S4LoadUnit(units, _).

        EquiCharacteristic(equiId, s4Class, "CRHT_SAFE_WORKING_LOAD_UNITS", 1, S4String(s4Units)) :-
            EquiWorkItem3(equiId, "CRHT", s4Class),
            WorkLoad(equiId, _, units),
            S4LoadUnit(units, s4Units).

        S4LoadUnit("KILOGRAM", "KG").
        S4LoadUnit("KILONEWTON", "KN").
        S4LoadUnit("MAN", "MAN").
        S4LoadUnit("TON (UK)", "TON (UK)").
        S4LoadUnit("TONNE", "TON").
    }

    
    
    /// # LIAC

    pub type alias LiacSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, S4LoadUnit, WorkLoad, TestCertNo, YWRef, EquiCharacteristic  | r1}


    pub def genLiac(workitems: #{EquiWorkItem3 | r1}, facts: LiacSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as LiacSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> liacCharacteristics())


    /// Note UNICLASS_CODE / UNICLASS_DESC / LOCATION_ON_SITE already created.
    pub def liacCharacteristics(): LiacSchema[r1] = #{

        EquiCharacteristic(equiId, s4Class, "STATUTORY_REFERENCE_NUMBER", 1, S4String(ywref)) :- 
            EquiWorkItem3(equiId, "LIAC", s4Class),
            YWRef(equiId, ywref).

        EquiCharacteristic(equiId, s4Class, "TEST_CERT_NO", 1, S4String(number)) :- 
            EquiWorkItem3(equiId, "LIAC", s4Class),
            TestCertNo(equiId, number).

        EquiCharacteristic(equiId, s4Class, "LIAC_SAFE_WORKING_LOAD", 1, S4Float(load)) :-
            EquiWorkItem3(equiId, "LIAC", s4Class),
            WorkLoad(equiId, load, units),
            S4LoadUnit(units, _).

        EquiCharacteristic(equiId, s4Class, "LIAC_SAFE_WORKING_LOAD_UNITS", 1, S4String(s4Units)) :-
            EquiWorkItem3(equiId, "LIAC", s4Class),
            WorkLoad(equiId, _, units),
            S4LoadUnit(units, s4Units).
    
        S4LoadUnit("KILOGRAM", "KG").
        S4LoadUnit("MAN", "MAN").

    }


    

    /// # LISL

    pub type alias LislSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, S4LoadUnit, WorkLoad, TestCertNo, YWRef, EquiCharacteristic | r1}


    pub def genLisl(workitems: #{EquiWorkItem3 | r1}, facts: LislSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as LislSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> lislCharacteristics())


    /// Note UNICLASS_CODE / UNICLASS_DESC / LOCATION_ON_SITE already created.
    pub def lislCharacteristics(): LislSchema[r1] = #{

        EquiCharacteristic(equiId, s4Class, "STATUTORY_REFERENCE_NUMBER", 1, S4String(ywref)) :- 
            EquiWorkItem3(equiId, "LISL", s4Class),
            YWRef(equiId, ywref).

        EquiCharacteristic(equiId, s4Class, "TEST_CERT_NO", 1, S4String(number)) :- 
            EquiWorkItem3(equiId, "LISL", s4Class),
            TestCertNo(equiId, number).


        EquiCharacteristic(equiId, s4Class, "LISL_SAFE_WORKING_LOAD", 1, S4Float(load)) :-
            EquiWorkItem3(equiId, "LISL", s4Class),
            WorkLoad(equiId, load, units),
            S4LoadUnit(units, _).

        EquiCharacteristic(equiId, s4Class, "LISL_SAFE_WORKING_LOAD_UNITS", 1, S4String(s4Units)) :-
            EquiWorkItem3(equiId, "LISL", s4Class),
            WorkLoad(equiId, _, units),
            S4LoadUnit(units, s4Units).

        S4LoadUnit("KILOGRAM", "KG").
        S4LoadUnit("MAN", "MAN").

    }

   

    pub type alias SferSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, S4LoadUnit, WorkLoad, TestCertNo, YWRef, EquiCharacteristic | r1}

    pub def genSfer(workitems: #{EquiWorkItem3 | r1}, facts: SferSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as SferSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> sferCharacteristics())


    /// Note UNICLASS_CODE / UNICLASS_DESC / LOCATION_ON_SITE already created.
    pub def sferCharacteristics(): SferSchema[r1] = #{
    
        EquiCharacteristic(equiId, s4Class, "STATUTORY_REFERENCE_NUMBER", 1, S4String(ywref)) :- 
            EquiWorkItem3(equiId, "SFER", s4Class),
            YWRef(equiId, ywref).

        EquiCharacteristic(equiId, s4Class, "TEST_CERT_NO", 1, S4String(number)) :- 
            EquiWorkItem3(equiId, "SFER", s4Class),
            TestCertNo(equiId, number).

        /// Note every SFER__ class has "SFER_SAFE_WORKING_LOAD" but they should not
        /// have `WorkLoad` if they don't (need to check this assumption).
        EquiCharacteristic(equiId, s4Class, "SFER_SAFE_WORKING_LOAD", 1, S4Float(load)) :-
            EquiWorkItem3(equiId, "SFER", s4Class),
            WorkLoad(equiId, load, units),
            S4LoadUnit(units, _).

        EquiCharacteristic(equiId, s4Class, "SFER_SAFE_WORKING_LOAD_UNITS", 1, S4String(s4Units)) :-
            EquiWorkItem3(equiId, "SFER", s4Class),
            WorkLoad(equiId, _, units),
            S4LoadUnit(units, s4Units).

        S4LoadUnit("KILOGRAM", "KG").
        S4LoadUnit("MAN", "MAN").

    }   


}
