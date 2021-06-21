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


namespace AssetLib/GenS4/Rules/Characteristics/Pums {

    use AssetLib/AibFacts/Attributes/Pump.{DiaphragmMaterial, DutyHead, DutyHeadUnits,
        Flow, FlowUnits, ImpellerType, LiftingType, RatingPower, RatingUnits};
    use AssetLib/S4Lite/Datatypes.{SLEquiCharacteristic};
    use AssetLib/GenS4/WorkLists.{EquipmentWorkItem, EquiWorkItem};
    use AssetLib/GenS4/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/GenS4/S4LiteRelations.CharValue.{S4String, S4Float};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{iEqual};
    use AssetLib/GenS4/XlsxSource.{XlsxSource};


    /// src should be pump facts
    pub def genPums(worklist: List[EquipmentWorkItem], src: XlsxSource): Result[Chain[SLEquiCharacteristic], String] & Impure =
        use Result.{flatMap};
        let workitems   = AssetLib/GenS4/WorkLists.makeEquiWorkItems(worklist);
        let* facts      = AssetLib/AibFacts/Attributes/Pump.readPumpData(src.sheet, src.file);
        let ans         = pums(workitems <+> facts) |> AssetLib/GenS4/S4LiteRelations.toSLEquiCharacteristic;
        Ok(ans) 


    pub def pums(input: #{EquiWorkItem, DiaphragmMaterial, DutyHead, DutyHeadUnits,
                            Flow, FlowUnits, ImpellerType, LiftingType, 
                            RatingPower, RatingUnits, EquiCharacteristic | r1}): #{EquiCharacteristic | r} = 
        let rules = #{
            EquiCharacteristic(equiId, s4Class, "PUMS_FLOW_LITRES_PER_SEC", 1, S4Float(flowLitresPerSecond(flow, units))) :- 
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "PUMS", s4Class),
                Flow(equiId, flow),
                FlowUnits(equiId, units),
                if recognizedFlowUnits(units).

            EquiCharacteristic(equiId, s4Class, "PUMS_INSTALLED_DESIGN_HEAD_M", 1, S4Float(ans)) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "PUMS", s4Class),
                DutyHead(equiId, ans),
                DutyHeadUnits(equiId, "METRES").

            /// TODO may have to limit pump-classes here...
            EquiCharacteristic(equiId, s4Class, "PUMS_IMPELLER_TYPE", 1, S4String(ans)) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "PUMS", s4Class),
                ImpellerType(equiId, ans).

            EquiCharacteristic(equiId, s4Class, "PUMS_LIFTING_TYPE", 1, S4String(ans)) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "PUMS", s4Class),
                LiftingType(equiId, ans).


            EquiCharacteristic(equiId, s4Class, "PUMS_RATED_POWER_KW", 1, S4Float(ans)) :-
                EquiWorkItem(equiId, _, _,  _, _, _,  _, "PUMS", s4Class),
                RatingPower(equiId, ans),
                RatingUnits(equiId, "KILOWATTS").
        };
        solve (rules <+> input) project EquiCharacteristic


    def recognizedFlowUnits(units: String): Bool = match units { 
        case "LITRE PER HOUR" => true
        case "LITRE PER MINUTE" => true
        case "LITRES PER SECOND" => true
        case _ => false
    }

    
    def flowLitresPerSecond(flow: Float64, units: String): Float64 = match units { 
        case "LITRE PER HOUR" => flow / 3600.0f64
        case "LITRE PER MINUTE" => flow / 60.0f64
        case "LITRES PER SECOND" => flow
        case _ => -1.0f64
    }

}
