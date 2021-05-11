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


namespace AssetLib/GenS4/Rules/Characteristics/Utils {

    pub def iEqual(x: Float64, y: Int32): Bool = 
        let y1 = Int32.toFloat64(y);
        tEqual(0.01f64, x, y1)


    pub def tEqual(threshold: Float64, x: Float64, y: Float64): Bool = 
        abs(x - y) < threshold


    def abs(x: Float64): Float64 = 
        import java.lang.Math:abs(Float64);
        abs(x) as & Pure


}
