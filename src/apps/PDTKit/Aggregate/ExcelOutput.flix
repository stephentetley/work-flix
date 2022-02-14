/*
 * Copyright 2022 Stephen Tetley
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

namespace PDTKit/Aggregate/ExcelOutput {
    
    use SheetIO.RowSetter;
    use RelLib/Lattice/StringAttributes.{StringAttributes};

    use PDTKit/Aggregate/Schema.{TabSpec};

    pub def makeHeaders(relns: #{TabSpec | r}): Map[String, Array[String]] & Impure = 
        query relns select (x1; x2) from TabSpec(x1; x2)
            |> Array.map(makeHeaders1)
            |> Array.toMap

    def makeHeaders1(x: (String, StringAttributes)): (String, Array[String]) & Impure = 
        let (name, attrs) = x;
        let headers = 
            attrs
                |> RelLib/Lattice/StringAttributes.getAttributes1
                |> Map.toList
                |> List.map(snd)
                |> List.toArray;
        (name, headers)

    pub def makeRows(relns: #{TabSpec | r}): Map[String, Array[String]] & Impure = 
        query relns select (x1; x2) from TabSpec(x1; x2)
            |> Array.map(makeHeaders1)
            |> Array.toMap
}
