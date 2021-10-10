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


namespace AssetLib/GenS4/Rules/Characteristics/Scrf {

    use SheetIO/Reader.{XlsxSource};
    
    use AssetLib/S4Lite/Datatypes.{SLEquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String, S4Int, S4Float};
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3, 
        Flow};
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{iEqual};
    


    type alias ScrfFacts[r1: SchemaRow] = 
        #{EquiWorkItem3, Flow, EquiCharacteristic | r1}

    pub def genScrf(workitems: #{EquiWorkItem3 | r1}, facts: ScrfFacts[r1]): GenMonad[Unit] =
        let workitems1 = workitems as ScrfFacts[r1];
        scrf(workitems1 <+> facts)


    /// Note UNICLASS_CODE / UNICLASS_DESC / LOCATION_ON_SITE already created.
    pub def scrf(input: ScrfFacts[r1]): GenMonad[Unit] = 
        use AssetLib/GenS4/Rules/Characteristics/Utils.{flowLitresPerSecond, recognizedFlowUnits};
                            
        let rules = #{

            /// All fine screens
            EquiCharacteristic(equiId, s4Class, "SCRF_FLOW_LITRES_PER_SEC", 1, S4Float(flowLitresPerSecond(flow, units))) :- 
                EquiWorkItem3(equiId, "SCRF", s4Class),
                Flow(equiId, flow, units),
                if recognizedFlowUnits(units).

            /// /// Not generated for static mixer
            /// EquiCharacteristic(equiId, s4Class, "MIXR_RATED_SPEED_RPM", 1, S4Int(ans)) :-
            ///     EquiWorkItem3(equiId, "MIXR", s4Class),
            ///     SpeedRPM(equiId, ans).

        }; 
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(rules <+> input)



}
