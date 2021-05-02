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

namespace AssetLib/GenS4/EmitUpload {
    
    use AssetLib/FileIO/S4/TransferFile/Datatypes.{ClassEquiRow, ValuaEquiRow};
    use AssetLib/GenS4/UploadRelations.{ClassEqui, ValuaEquiText, ValuaEquiInt, ValuaEquiFloat};

    pub def outputUploads(userName: String,
                        solutions: #{ClassEqui, ValuaEquiText, ValuaEquiInt, ValuaEquiFloat | r},
                        nameRoot: String,
                        outdir: System.FilePath): Result[Unit, String] & Impure = 
        use Result.flatMap;
        let classEquiPath   = System/FilePath.append(outdir, System/FilePath.new("${nameRoot}-upload1-classequi.txt"));
        let _               = Console.printLine("Writing '${classEquiPath}'");
        let classEquiRows   = makeClassEquiRows(solutions);
        let* _              = AssetLib/FileIO/S4/TransferFile/UploadWriter.writeClassEquiFile(userName, classEquiRows, classEquiPath);        
        let valuaEquiPath   = System/FilePath.append(outdir, System/FilePath.new("${nameRoot}-upload2-valuaequi.txt"));
        let _               = Console.printLine("Writing '${valuaEquiPath}'");
        let valuaEquiRows   = makeValuaEquiRows(solutions);
        let* _              = AssetLib/FileIO/S4/TransferFile/UploadWriter.writeValuaEquiFile(userName, valuaEquiRows, valuaEquiPath);
        Ok()

    def makeClassEquiRows(relns: #{ClassEqui | r}): List[ClassEquiRow] = 
        let xs = AssetLib/GenS4/UploadRelations.toClassEquiRow(relns);
        let cmp = (x, y) -> match Order.compare(x.equi, y.equi) { 
            case EqualTo => Order.compare(x.className, y.className)
            case ord => ord
        } |> Order.toInt;
        List.sortWith(cmp, xs)

    def makeValuaEquiRows(relns: #{ValuaEquiText, ValuaEquiInt, ValuaEquiFloat | r}): List[ValuaEquiRow] = 
        let xs = AssetLib/GenS4/UploadRelations.textToValuaEquiRow(relns);
        let ys = AssetLib/GenS4/UploadRelations.intToValuaEquiRow(relns);
        let zs = AssetLib/GenS4/UploadRelations.floatToValuaEquiRow(relns);
        let cmp = (x, y) -> match Order.compare(x.equi, y.equi) { 
            case EqualTo => Order.compare(x.charId, y.charId)
            case ord => ord
        } |> Order.toInt;
        List.flatten(xs :: ys :: zs :: Nil) |> List.sortWith(cmp)
        



}
