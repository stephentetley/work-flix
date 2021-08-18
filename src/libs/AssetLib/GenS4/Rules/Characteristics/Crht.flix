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
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3, WorkLoad, TestCertNo, YWRef};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};
    

    /// src should be lifting facts
    pub def genCrht(worklist: List[EquiWorkItem], src: XlsxSource): Result[Chain[SLEquiCharacteristic], String] & Impure =
        use Result.{flatMap};
        let workitems   = AssetLib/GenS4/WorkLists.makeEquiWorkItem3(worklist);
        let* facts      = AssetLib/GenS4/AibFacts/Attributes/Lifting.readLiftingData(src);
        let ans         = crht(workitems <+> facts);
        Ok(ans) 



    /// Note LOCATION_ON_SITE already created.
    pub def crht(input: #{EquiWorkItem3, WorkLoad, TestCertNo, YWRef, 
                            EquiCharacteristic | r1}): Chain[SLEquiCharacteristic] & Impure = 
        use AssetLib/GenS4/Rules/Characteristics/Utils.{recognizedWorkLoadUnit, workLoadUnits};
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
        solve (rules <+> input) project EquiCharacteristic
            |> AssetLib/S4Lite/S4LiteRelations.toSLEquiCharacteristic



}
