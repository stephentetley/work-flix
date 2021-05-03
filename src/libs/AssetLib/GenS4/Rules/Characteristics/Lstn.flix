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


namespace AssetLib/GenS4/Rules/Characteristics/Lstn {

    use AssetLib/AibFacts/Relations.{AibStringValue};
    use AssetLib/GenS4/UploadRelations.{ValuaEquiFloat};
    use AssetLib/GenS4/WorkListRelations.{Phase2EquiItem, Phase1EquiItem};



    /// Note LOCATION_ON_SITE already created.
    pub def lstn(): #{ValuaEquiFloat, Phase2EquiItem, Phase1EquiItem, AibStringValue | r} = 
        #{
            ValuaEquiText(equiId, "002", "LSTN_SIGNAL_TYPE", "4 - 20 MA", 1) :- 
                Phase2EquiItem(equiId, name, floc,  "LSTN", _),
                Phase1EquiItem(aibref, name, floc,  _, _, _,  _),
                AibFloatValue(aibref, "SIGNAL_MIN", min),
                AibFloatValue(aibref, "SIGNAL_MAX", max),
                AibStringValue(aibref, "SIGNAL_UNIT", "mA"),
                if thresholdEq(0.1f64, min, 4.0f64) and thresholdEq(0.1f64, max, 20.0f64).
        }



    def abs(x: Float64): Float64 = 
        import java.lang.Math:abs(Float64);
        abs(x) as & Pure

    def thresholdEq(threshold: Float64, x: Float64, y: Float64): Bool = 
        abs(x - y) < threshold

}
