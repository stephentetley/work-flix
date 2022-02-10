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

namespace S4Loader/Uxl/GenUxl {

    use AssetLib/S4Lite/Datatypes.{UxlOutput};
    use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};

    pub def emitUxl(args: UxlOutputArgs, batches: Map[Int32, UxlOutput]): Result[Unit, String] & Impure = 
        let xs = batches |> Map.toList |> List.map(xy -> let (x, y) = xy; {batchNumber = x, uxl = y });
        AssetLib/S4Lite/EmitUxl.outputMocrUxlBatches(args, xs)

    /// pub def emitRenumberedUxl(args: UxlOutputArgs, batches: Map[Int32, UxlOutput]): Result[Unit, String] & Impure = 
    ///     let xs = batches |> Map.toList |> List.map(xy -> let (x, y) = xy; {batchNumber = x, uxl = y });
    ///     AssetLib/S4Lite/EmitUxl.outputMocrUxlBatches(args, xs)


    pub def combineBatches(b1: Map[Int32, UxlOutput], b2: Map[Int32, UxlOutput]): Map[Int32, UxlOutput] = 
        Map.unionWith(AssetLib/S4Lite/Datatypes.combineUxlOutput, b1, b2)

    pub def combineBatchesAll(xs: f[Map[Int32, UxlOutput]]): Map[Int32, UxlOutput] with Foldable[f] = 
        Foldable.foldLeft(combineBatches, Map.empty(), xs)


}
