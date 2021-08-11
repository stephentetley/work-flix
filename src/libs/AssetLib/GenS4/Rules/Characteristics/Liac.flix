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


namespace AssetLib/GenS4/Rules/Characteristics/Liac {

    use SheetIO/Reader.{XlsxSource};
    use AssetLib/AibFacts/Attributes/Lifting.{WorkLoad, WorkLoadUnits,
        TestCertNo, YWRef};
    use AssetLib/S4Lite/Datatypes.{SLEquiCharacteristic};
    use AssetLib/GenS4/WorkLists.{EquiWorkItemRec, EquiWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String, S4Float};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{iEqual};
    use AssetLib/GenS4/Rules/Characteristics/CommonRelations.{EquiWorkItem3};
    

    /// src should be lifting facts
    pub def genLiac(worklist: List[EquiWorkItemRec], src: XlsxSource): Result[Chain[SLEquiCharacteristic], String] & Impure =
        use Result.{flatMap};
        let workitems   = makeWorkItems(worklist);
        let* facts      = AssetLib/AibFacts/Attributes/Lifting.readLiftingData(src);
        let ans         = liac(workitems <+> facts) |> AssetLib/GenS4/S4LiteRelations.toSLEquiCharacteristic;
        Ok(ans) 


    /// Where to put this?
    def makeWorkItems(xs: List[EquiWorkItemRec]): #{EquiWorkItem3 | r}  = 
        List.foldLeft((ac, x) -> ac <+> #{ EquiWorkItem3(x.equipmentId, x.s4EquiType, x.s4EquiClass). }, #{}, xs)

    /// Note LOCATION_ON_SITE already created.
    pub def liac(input: #{EquiWorkItem3, WorkLoad, WorkLoadUnits, TestCertNo, YWRef, EquiCharacteristic | r1}): #{EquiCharacteristic | r} = 
        let rules = #{
            EquiCharacteristic(equiId, s4Class, "STATUTORY_REFERENCE_NUMBER", 1, S4String(ywref)) :- 
                EquiWorkItem3(equiId, "LIAC", s4Class),
                YWRef(equiId, ywref).

            EquiCharacteristic(equiId, s4Class, "TEST_CERT_NO", 1, S4String(number)) :- 
                EquiWorkItem3(equiId, "LIAC", s4Class),
                TestCertNo(equiId, number).

            EquiCharacteristic(equiId, s4Class, "LIAC_SAFE_WORKING_LOAD", 1, S4Float(load)) :-
                EquiWorkItem3(equiId, "LIAC", s4Class),
                WorkLoad(equiId, load),
                WorkLoadUnits(equiId,  units),
                if recognizedLoadUnit(units).

            EquiCharacteristic(equiId, s4Class, "LIAC_SAFE_WORKING_LOAD_UNITS", 1, S4String(loadUnit(units))) :-
                EquiWorkItem3(equiId, "LIAC", s4Class),
                WorkLoadUnits(equiId, units),
                if recognizedLoadUnit(units).

        }; 
        solve (rules <+> input) project EquiCharacteristic


    def recognizedLoadUnit(s: String): Bool = match s { 
        case "KILOGRAM" => true
        case "MAN" => true
        case _ => false
    }

    
    def loadUnit(s: String): String = match s { 
        case "KILOGRAM" => "KG"
        case "MAN" => "MAN"
        case _ => ""
    }


}
