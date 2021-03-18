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

namespace DwfOverflow/Rules/TransferFileLoader {

    use AssetLib/S4/FileIO/TransferFile.RowEvaluator;
    use DwfOverflow/Relations.{ExistingFloc};


    pub def readFlocTransferFile[r](src: System.FilePath): Result[#{ExistingFloc | r}, String] & Impure = 
        use AssetLib/S4/FileIO/TransferFile/Evaluate.{readAllRows};
        let step = (ac, x) -> {
            match splitName(x) { 
                case Some((s, s1)) => {let x1 = #{ ExistingFloc(s, s1). }; x1 <+> ac }
                case None => ac
            }            
        };
        Result.map(xs -> solve List.foldLeft(step, #{}, xs), readAllRows(evalFuncLocRow(), src))

    def evalFuncLocRow(): RowEvaluator[String] = 
        AssetLib/S4/FileIO/TransferFile/RowEvaluator.getStringNamed("FUNCLOC")

    def splitName(s: String): Option[(String, String)] = 
        match String.splitOn(s, "-") {
            case s1 :: rs => Some((s1, String.intercalate("-", rs)))
            case _ => None
        }
        
}