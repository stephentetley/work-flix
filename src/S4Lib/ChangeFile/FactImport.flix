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

use S4Lib/ChangeFile/Datatypes.{ChangeFile, DataRow};
use S4Lib/ChangeFile/Datatypes.DataRow.{DataRow};
use S4Lib/ChangeFile/Datatypes.Headers.{Headers};

namespace S4Lib/ChangeFile/FactImport {

    pub opaque type DataRowEvaluator[a] = (Map[String,Int32], DataRow) ~> Result[a, System.Error]
    
    pub def return(x: a): DataRowEvaluator[a] = 
        DataRowEvaluator((_,_) -> Ok(x) as & Impure)

    def apply1(x: DataRowEvaluator[a], indices: Map[String, Int32], row: DataRow): Result[a, System.Error] & Impure =
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

    def makeIndices(x: Array[String]): Map[String, Int] & Impure = 
        Array.foldLeft((st, s) -> { let (ac,i) = st; (Map.insert(s, i, ac), i+1) }, (Map.empty(), 0), x) |> fst

    ///
    /// Process all rows of the input.
    ///
    /// Note - a `relation` is naturally monoidal - a `rowreader` can generate zero, one or many facts from a `row`.
    ///
    pub def importRows(eval: DataRowEvaluator[reln], x: ChangeFile): Result[reln, System.Error] & Impure = 
        let Headers(arr) = x.headers;
        let ixs = makeIndices(arr);
        let DataRowEvaluator(f1) = eval;
        let f2 = f1(ixs);
        importRowsHelper(f2, x.dataRows, #{ })

    def importRowsHelper(eval1: DataRow ~> Result[reln, System.Error], rows: List[DataRow], ac: reln): Result[reln, System.Error] & Impure = 
        match rows { 
            case Nil => Ok(ac)
            case r1 :: rs => match eval1(r1) {
                case Ok(a1) => importRowsHelper(eval1, rs, ac <+> a1)
                case Err(e) => Err(e)
            }
        }

    ///
    /// Process all rows of the input with a zero indexed row count.
    ///
    /// Note - a `relation` is naturally monoidal - a row can generate zero, one or many facts.
    ///
    pub def importRowsWithCount(eval: Int32 -> DataRowEvaluator[reln], x: ChangeFile): Result[reln, System.Error] & Impure = 
        let Headers(arr) = x.headers;
        let ixs = makeIndices(arr);
        let eval1 = (n,r) -> { let eval2 = eval(n); let DataRowEvaluator(f) = eval2; f(ixs, r) };
        importRowsWithCountHelper(eval1, x.dataRows, 0, #{ })

    def importRowsWithCountHelper(eval1: (Int32, DataRow) ~> Result[reln, System.Error], rows: List[DataRow], n: Int32, ac: reln): Result[reln, System.Error] & Impure = 
        match rows { 
            case Nil => Ok(ac)
            case r1 :: rs => match eval1(n, r1) {
                case Ok(a1) => importRowsWithCountHelper(eval1, rs, n+1, ac <+> a1)
                case Err(e) => Err(e)
            }
        }

    ///
    /// Process all rows of the input with a threaded state.
    ///
    /// Note - a `relation` is naturally monoidal - a row can generate zero, one or many facts.
    ///
    pub def importRowsWithAccum(eval: st -> DataRowEvaluator[(reln, st)], s: st, x: ChangeFile): Result[(reln, st), System.Error] & Impure = 
        let Headers(arr) = x.headers;
        let ixs = makeIndices(arr);
        let eval1 = (st,r) -> { let eval2 = eval(st); let DataRowEvaluator(f) = eval2; f(ixs, r) };
        importRowsWithAccumHelper(eval1, x.dataRows, s, #{ })

    def importRowsWithAccumHelper(eval1: (st, DataRow) ~> Result[(reln, st), System.Error], rows: List[DataRow], s: st, ac: reln): Result[(reln, st), System.Error] & Impure = 
        match rows { 
            case Nil => Ok((ac, s))
            case r1 :: rs => match eval1(s, r1) {
                case Ok((a1, s1)) => importRowsWithAccumHelper(eval1, rs, s1, ac <+> a1)
                case Err(e) => Err(e)
            }
        }
     
    ///
    /// Process all rows of the input with threaded state and a zero indexed row count.
    ///
    /// Note - a `relation` is naturally monoidal - a row can generate zero, one or many facts.
    ///
    pub def importRowsWithCountAndAccum(eval: (Int32, st) -> DataRowEvaluator[(reln, st)], s: st, x: ChangeFile): Result[(reln, st), System.Error] & Impure = 
        let Headers(arr) = x.headers;
        let ixs = makeIndices(arr);
        let eval1 = (n, st, r) -> { let eval2 = eval(n, st); let DataRowEvaluator(f) = eval2; f(ixs, r) };
        importRowsWithCountAndAccumHelper(eval1, x.dataRows, 0, s, #{ })

    def importRowsWithCountAndAccumHelper(eval1: (Int32, st, DataRow) ~> Result[(reln, st), System.Error], rows: List[DataRow], n: Int32, s: st, ac: reln): Result[(reln, st), System.Error] & Impure = 
        match rows { 
            case Nil => Ok((ac, s))
            case r1 :: rs => 
                match eval1(n, s, r1) {
                    case Ok((a1, s1)) => importRowsWithCountAndAccumHelper(eval1, rs, n + 1, s1, ac <+> a1)
                    case Err(e) => Err(e)
                }
        }

    // Cell readers, by label only

    pub def getString(label: String): DataRowEvaluator[String] = 
        DataRowEvaluator((ixs, row) -> match Map.get(label, ixs) { 
            case None => Err(IllegalArgumentException)
            case Some(ix) => {
                let DataRow(arr) = row;
                if (ix >= 0 && ix < Array.length(arr)) {
                    let s = arr[ix];
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