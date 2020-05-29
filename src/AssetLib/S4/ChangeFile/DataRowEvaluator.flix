/*
 * Copyright 2020 Stephen Tetley
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

use System.Error.{IllegalArgumentException, InputMismatchException};

use AssetLib/S4/ChangeFile.DataRowEvaluator;
use AssetLib/S4/ChangeFile.DataRowEvaluator.{DataRowEvaluator};

namespace AssetLib/S4/ChangeFile {

    pub opaque type DataRowEvaluator[a] = (Map[String,Int32], Array[String]) ~> Result[a, System.Error]
}

namespace AssetLib/S4/ChangeFile/DataRowEvaluator {

pub opaque type DataRowEvaluator[a] = (Map[String,Int32], Array[String]) ~> Result[a, System.Error]
    
    pub def return(x: a): DataRowEvaluator[a] = 
        DataRowEvaluator((_,_) -> Ok(x) as & Impure)

    def apply1(x: DataRowEvaluator[a], indices: Map[String, Int32], row: Array[String]): Result[a, System.Error] & Impure =
        let DataRowEvaluator(f) = x;
        f(indices, row)

    pub def map(f: a -> b & e, x: DataRowEvaluator[a]): DataRowEvaluator[b] =
        DataRowEvaluator((ixs, row) -> 
            match apply1(x, ixs, row) {
                case Ok(a) => {
                    let ans = f(a) as & Impure;
                    Ok(ans)
                }
                case Err(e) => Err(e)
            }
        )        

    pub def ap(mf: DataRowEvaluator[a -> b], ma: DataRowEvaluator[a]): DataRowEvaluator[b] =
        DataRowEvaluator((ixs, row) -> 
            match apply1(mf, ixs, row) {
                case Ok(f) => { 
                    match apply1(ma, ixs, row) {
                        case Ok(a) => Ok(f(a))
                        case Err(e2) => Err(e2)
                    }
                }
                case Err(e1) => Err(e1)
            }
        )

    pub def bind(x: DataRowEvaluator[a], k: a -> DataRowEvaluator[b]): DataRowEvaluator[b] = 
        DataRowEvaluator((ixs, row) -> 
            match apply1(x, ixs, row) { 
                case Ok(a) => apply1(k(a), ixs, row)
                case Err(e) => Err(e)
            }
        )

    pub def flatMap(k: a -> DataRowEvaluator[b], x: DataRowEvaluator[a]): DataRowEvaluator[b] = bind(x, k)

    def liftResult(x: Result[a, System.Error]): DataRowEvaluator[a] = 
        DataRowEvaluator((_,_) -> x as & Impure)

     // Cell readers, by label only

    pub def getString(label: String): DataRowEvaluator[String] = 
        DataRowEvaluator((ixs, row) -> match Map.get(label, ixs) { 
            case None => Err(IllegalArgumentException)
            case Some(ix) => {
                if (ix >= 0 && ix < Array.length(row)) {
                    let s = row[ix];
                    Ok(s)
                } else {
                    Err(IllegalArgumentException)
                }
            }
        })

    pub def getInt8(label: String): DataRowEvaluator[Int8] = 
        let* s = getString(label);
        liftResult(Int8.fromString(s) |> Result.mapErr(_ -> IllegalArgumentException))
        
    pub def getInt16(label: String): DataRowEvaluator[Int16] = 
        let* s = getString(label);
        liftResult(Int16.fromString(s) |> Result.mapErr(_ -> IllegalArgumentException))
    
    pub def getInt32(label: String): DataRowEvaluator[Int32] =
        let* s = getString(label);
        liftResult(Int32.fromString(s) |> Result.mapErr(_ -> IllegalArgumentException))
    
    pub def getInt64(label: String): DataRowEvaluator[Int64] =
        let* s = getString(label);
        liftResult(Int64.fromString(s) |> Result.mapErr(_ -> IllegalArgumentException))

    pub def getFloat32(label: String): DataRowEvaluator[Float32] =
        let* s = getString(label);
        liftResult(Float32.fromString(s) |> Result.mapErr(_ -> IllegalArgumentException))

    pub def getFloat64(label: String): DataRowEvaluator[Float64] =
        let* s = getString(label);
        liftResult(Float64.fromString(s) |> Result.mapErr(_ -> IllegalArgumentException))


}