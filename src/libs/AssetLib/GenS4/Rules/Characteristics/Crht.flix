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


namespace AssetLib/GenS4/Rules/Characteristics/Crht {

    use SheetIO/Reader.{XlsxSource};

    use AssetLib/S4Lite/Datatypes.{SLEquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String, S4Float};
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3, WorkLoad, TestCertNo, YWRef};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};
    


    pub type alias CrhtSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, WorkLoad, TestCertNo, YWRef, EquiCharacteristic | r1}


    pub def genCrht(workitems: #{EquiWorkItem3 | r1}, facts: CrhtSchema[r1]): GenMonad[Unit] =
        let workitems1 = workitems as CrhtSchema[r1];
        crht(workitems1 <+> facts)

    /// Note UNICLASS_CODE / UNICLASS_DESC / LOCATION_ON_SITE already created.
    pub def crht(input: CrhtSchema[r1]): GenMonad[Unit] = 
        let rules = #{
            EquiCharacteristic(equiId, s4Class, "STATUTORY_REFERENCE_NUMBER", 1, S4String(ywref)) :- 
                EquiWorkItem3(equiId, "CRHT", s4Class),
                YWRef(equiId, ywref).

            EquiCharacteristic(equiId, s4Class, "TEST_CERT_NO", 1, S4String(number)) :- 
                EquiWorkItem3(equiId, "CRHT", s4Class),
                TestCertNo(equiId, number).

            EquiCharacteristic(equiId, s4Class, "CRHT_SAFE_WORKING_LOAD", 1, S4Float(load)) :-
                EquiWorkItem3(equiId, "CRHT", s4Class),
                WorkLoad(equiId, load, units),
                if recognizedWorkLoadUnit(units).

            EquiCharacteristic(equiId, s4Class, "CRHT_SAFE_WORKING_LOAD_UNITS", 1, S4String(workLoadUnits(units))) :-
                EquiWorkItem3(equiId, "CRHT", s4Class),
                WorkLoad(equiId, _, units),
                if recognizedWorkLoadUnit(units).

        }; 
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(rules <+> input)

    /// This is local - recognized units may vary according to ObjectType/ClassType...
    def recognizedWorkLoadUnit(s: String): Bool = match s { 
        case "KILOGRAM" => true
        case "KILONEWTON" => true
        case "MAN" => true
        case "TON (UK)" => true
        case "TONNE" => true
        case _ => false
    }

    
    def workLoadUnits(s: String): String = match s { 
        case "KILOGRAM" => "KG"
        case "KILONEWTON" => "KN"
        case "MAN" => "MAN"
        case "TON (UK)" => "TON (UK)"
        case "TONNE" => "TON"
        case _ => ""
    }

}
