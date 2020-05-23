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



use FactIO.LineEvaluator;
use FactIO.LinesImporter;

use S4Lib/ChangeFile.DataRowEvaluator;
use S4Lib/ChangeFile.DataRowEvaluator.{DataRowEvaluator};

namespace S4Lib/ChangeFile/FactImport {



    def makeIndices(x: Array[String]): Map[String, Int32] & Impure = 
        Array.foldLeft((st, s) -> { let (ac,i) = st; (Map.insert(s, i, ac), i+1) }, (Map.empty(), 0), x) |> fst


    def headerRow(): LineEvaluator[Map[String, Int32]] = 
        use Text/Regex/MatchEvaluator.{getCaptureByName, map};
        use FactIO/LineEvaluator.{matchRegex};
        let pattern = "^\*(?<rest>[A-Z]+.*)";
        let eval = getCaptureByName("rest") |> map(s -> makeIndices(String.split(s, "\t")));
        matchRegex(pattern, eval)

    def makeLineEvaluator(ixs: Map[String, Int32], eval: DataRowEvaluator[reln]): LineEvaluator[reln] = 
        use FactIO/LineEvaluator.{flatMap, map, content, return, liftAction};
        let DataRowEvaluator(f1) = eval;
        let* cells = content() |> map(s -> String.split(s, "\t"));        
        let* ans = liftAction(_ -> f1(ixs, cells));
        return(ans)

    def importRowsHelper(eval: DataRowEvaluator[reln]): LinesImporter[reln] = 
        use FactIO/LinesImporter.{flatMap, return, skipTill, lines};
        use FactIO/LineEvaluator.{choice};
        let* headers = skipTill(headerRow());
        let eval1 = makeLineEvaluator(headers, eval);
        let* rows = lines(eval1);
        return(solve rows)

    pub def importRows(eval: DataRowEvaluator[reln], path: String): Result[reln, System.Error] & Impure = 
        use Result.flatMap;
        let* relns = FactIO/LinesImporter.runLinesImporter(importRowsHelper(eval), path, Text/Charset.utf_8());
        Ok(solve relns)

    // ///
    // /// Process all rows of the input.
    // ///
    // /// Note - a `relation` is naturally monoidal - a `rowreader` can generate zero, one or many facts from a `row`.
    // ///
    // pub def importRows(eval: DataRowEvaluator[reln], path: String): Result[reln, System.Error] & Impure = 
    //     let Headers(arr) = x.headers;
    //     let ixs = makeIndices(arr);
    //     let DataRowEvaluator(f1) = eval;
    //     let f2 = f1(ixs);
    //     importRowsHelper(f2, x.dataRows, #{ })




    // def importRowsHelper(eval1: DataRow ~> Result[reln, System.Error], rows: List[DataRow], ac: reln): Result[reln, System.Error] & Impure = 
    //     match rows { 
    //         case Nil => Ok(ac)
    //         case r1 :: rs => match eval1(r1) {
    //             case Ok(a1) => importRowsHelper(eval1, rs, ac <+> a1)
    //             case Err(e) => Err(e)
    //         }
    //     }

    // ///
    // /// Process all rows of the input with a zero indexed row count.
    // ///
    // /// Note - a `relation` is naturally monoidal - a row can generate zero, one or many facts.
    // ///
    // pub def importRowsWithCount(eval: Int32 -> DataRowEvaluator[reln], x: ChangeFile): Result[reln, System.Error] & Impure = 
    //     let Headers(arr) = x.headers;
    //     let ixs = makeIndices(arr);
    //     let eval1 = (n,r) -> { let eval2 = eval(n); let DataRowEvaluator(f) = eval2; f(ixs, r) };
    //     importRowsWithCountHelper(eval1, x.dataRows, 0, #{ })

    // def importRowsWithCountHelper(eval1: (Int32, DataRow) ~> Result[reln, System.Error], rows: List[DataRow], n: Int32, ac: reln): Result[reln, System.Error] & Impure = 
    //     match rows { 
    //         case Nil => Ok(ac)
    //         case r1 :: rs => match eval1(n, r1) {
    //             case Ok(a1) => importRowsWithCountHelper(eval1, rs, n+1, ac <+> a1)
    //             case Err(e) => Err(e)
    //         }
    //     }

    // ///
    // /// Process all rows of the input with a threaded state.
    // ///
    // /// Note - a `relation` is naturally monoidal - a row can generate zero, one or many facts.
    // ///
    // pub def importRowsWithAccum(eval: st -> DataRowEvaluator[(reln, st)], s: st, x: ChangeFile): Result[(reln, st), System.Error] & Impure = 
    //     let Headers(arr) = x.headers;
    //     let ixs = makeIndices(arr);
    //     let eval1 = (st,r) -> { let eval2 = eval(st); let DataRowEvaluator(f) = eval2; f(ixs, r) };
    //     importRowsWithAccumHelper(eval1, x.dataRows, s, #{ })

    // def importRowsWithAccumHelper(eval1: (st, DataRow) ~> Result[(reln, st), System.Error], rows: List[DataRow], s: st, ac: reln): Result[(reln, st), System.Error] & Impure = 
    //     match rows { 
    //         case Nil => Ok((ac, s))
    //         case r1 :: rs => match eval1(s, r1) {
    //             case Ok((a1, s1)) => importRowsWithAccumHelper(eval1, rs, s1, ac <+> a1)
    //             case Err(e) => Err(e)
    //         }
    //     }
     
    // ///
    // /// Process all rows of the input with threaded state and a zero indexed row count.
    // ///
    // /// Note - a `relation` is naturally monoidal - a row can generate zero, one or many facts.
    // ///
    // pub def importRowsWithCountAndAccum(eval: (Int32, st) -> DataRowEvaluator[(reln, st)], s: st, x: ChangeFile): Result[(reln, st), System.Error] & Impure = 
    //     let Headers(arr) = x.headers;
    //     let ixs = makeIndices(arr);
    //     let eval1 = (n, st, r) -> { let eval2 = eval(n, st); let DataRowEvaluator(f) = eval2; f(ixs, r) };
    //     importRowsWithCountAndAccumHelper(eval1, x.dataRows, 0, s, #{ })

    // def importRowsWithCountAndAccumHelper(eval1: (Int32, st, DataRow) ~> Result[(reln, st), System.Error], rows: List[DataRow], n: Int32, s: st, ac: reln): Result[(reln, st), System.Error] & Impure = 
    //     match rows { 
    //         case Nil => Ok((ac, s))
    //         case r1 :: rs => match eval1(n, s, r1) {
    //             case Ok((a1, s1)) => importRowsWithCountAndAccumHelper(eval1, rs, n + 1, s1, ac <+> a1)
    //             case Err(e) => Err(e)
    //         }
    //     }

    
}