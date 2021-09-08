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


    pub def recognizedFlowUnits(units: String): Bool = match units { 
        case "LITRE PER HOUR" => true
        case "LITRE PER MINUTE" => true
        case "LITRES PER SECOND" => true
        case _ => false
    }

    
    pub def flowLitresPerSecond(flow: Float64, units: String): Float64 = match units { 
        case "LITRE PER HOUR" => flow / 3600.0f64
        case "LITRE PER MINUTE" => flow / 60.0f64
        case "LITRES PER SECOND" => flow
        case _ => -1.0f64
    }




    pub def iEqual(x: Float64, y: Int32): Bool = 
        let y1 = Int32.toFloat64(y);
        tEqual(0.01f64, x, y1)


    pub def tEqual(threshold: Float64, x: Float64, y: Float64): Bool = 
        abs(x - y) < threshold


    def abs(x: Float64): Float64 = 
        import java.lang.Math:abs(Float64);
        abs(x) as & Pure

    pub def recognizedVoltageUnits(s: String): Bool = match s { 
        case "ALTERNATING CURRENT" => true
        case "DIRECT CURRENT" => true
        case _ => false
    }

    
    pub def voltageUnits(units: String): String = match units { 
        case "ALTERNATING CURRENT" => "VAC"
        case "DIRECT CURRENT" => "VDC"
        case _ => ""
    }


    pub rel S4InsulationClass(aib: String, s4: String)

    pub def s4InsulationClassRules(): #{S4InsulationClass | r} = #{
        S4InsulationClass("200 (CLASS K)",      "200 (CLASS K)").
        S4InsulationClass("180 (CLASS H)",      "180 (CLASS H)").
        S4InsulationClass("155 (CLASS F)",      "155 (CLASS F)").
        S4InsulationClass("130 (CLASS B)",      "130 (CLASS B)").
        S4InsulationClass("120 (CLASS E)",      "120 (CLASS E)").
        S4InsulationClass("105 (CLASS A)",      "105 (CLASS A)").
    }


}
