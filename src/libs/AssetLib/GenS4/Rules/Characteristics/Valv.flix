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


namespace AssetLib/GenS4/Rules/Characteristics/Valv {

    use SheetIO/Reader.{XlsxSource};

    use AssetLib/S4Lite/Datatypes.{SLEquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4Int};
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3, ValveSize};
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};
    


    type alias ValvSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, ValveSize, EquiCharacteristic | r1}

    pub def genValv(workitems: #{EquiWorkItem3 | r1}, facts: ValvSchema[r1]): GenMonad[Unit] =
        let workitems1 = workitems as ValvSchema[r1];
        valv(workitems1 <+> facts)


    pub def valv(input: ValvSchema[r1]): GenMonad[Unit] = 
        let rules = #{
            EquiCharacteristic(equiId, s4Class, "VALV_INLET_SIZE_MM", 1, S4Int(sizeMM(size, units))) :- 
                EquiWorkItem3(equiId, "VALV", s4Class),
                ValveSize(equiId, size, units),
                if recognizedSizeUnits(units) and s4Class != "VALVRE".

            EquiCharacteristic(equiId, "VALVRE", "VALV_BORE_DIAMETER_MM", 1, S4Int(sizeMM(size, units))) :- 
                EquiWorkItem3(equiId, "VALV", "VALVRE"),
                ValveSize(equiId, size, units),
                if recognizedSizeUnits(units).

        };
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(rules <+> input)


    def recognizedSizeUnits(units: String): Bool = match units { 
        case "MILLIMETRES" => true
        case "INCH" => true
        case _ => false
    }

    def sizeMM(size: Float64, units: String): Int32 = 
        match units { 
            case "MILLIMETRES" => size
            case "INCH" => 25.4f64 * size
            case _ => -1.0f64
        } 
            |> round
            |> Float64.tryToInt32
            |> flip(Option.getWithDefault, 0)

    /// TODO make PR for Flix... with ceil and floor
    def round(x: Float64): Float64 =
        import java.lang.Math:rint(Float64);
        rint(x) as & Pure


}
