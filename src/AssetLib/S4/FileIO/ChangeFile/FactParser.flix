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



use FactIO/FlatFile.LineEvaluator;
use FactIO/FlatFile.SimpleParser;
use FactIO/FlatFile.RowWithHeadersEvaluator;
use FactIO/FlatFile.RowWithHeadersEvaluator.{RowWithHeadersEvaluator};

/// This is a generic library for making ChangeFile loaders and
/// not an actual change file loader.


/// TODO - call this FactReader?
namespace AssetLib/S4/FileIO/ChangeFile/FactParser {


    pub def importRows(eval: RowWithHeadersEvaluator[reln], path: String): Result[reln, System.Error] & Impure = 
        use Result.flatMap;
        let* relns = FactIO/FlatFile/SimpleParser.runSimpleParser(importRowsParser(eval), path, Text/Charset.utf_8());
        Ok(solve relns)


    def importRowsParser(eval: RowWithHeadersEvaluator[reln]): SimpleParser[reln] = 
        use FactIO/FlatFile/SimpleParser.{flatMap, return, skipLinesTill, linesTillEnd};
        use FactIO/FlatFile/LineEvaluator.{choice};
        let* headers = skipLinesTill(headerRow());
        let eval1 = makeLineEvaluator(headers, eval);
        let* rows = linesTillEnd(eval1);
        return(solve rows)

    def headerRow(): LineEvaluator[Map[String, Int32]] = 
        use Text/Regex/MatchEvaluator.{getNamedCapture, map};
        use FactIO/FlatFile/RowWithHeadersEvaluator.{makeHeaders};
        use FactIO/FlatFile/LineEvaluator.{matchesRegex};
        let regex = "^\*(?<rest>[A-Z]+.*)";
        let eval = getNamedCapture("rest") |> map(s -> makeHeaders(String.split(s, "\t")));
        matchesRegex(regex, eval)

    def makeLineEvaluator(columnHeadings: Map[String, Int32], eval: RowWithHeadersEvaluator[reln]): LineEvaluator[reln] = 
        use FactIO/FlatFile/RowWithHeadersEvaluator.{toLineEvaluator};
        toLineEvaluator(s -> String.split(s, "\t"), columnHeadings, eval)



    // ///
    // /// Process all rows of the input with a zero indexed row count.
    // ///
    // /// Note - a `relation` is naturally monoidal - a row can generate zero, one or many facts.
    // ///
    // pub def importRowsWithCount(eval: Int32 -> RowEvaluator[reln], x: ChangeFile): Result[reln, System.Error] & Impure = 
    //     let Headers(arr) = x.headers;
    //     let ixs = makeIndices(arr);
    //     let eval1 = (n,r) -> { let eval2 = eval(n); let RowEvaluator(f) = eval2; f(ixs, r) };
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
    // pub def importRowsWithAccum(eval: st -> RowEvaluator[(reln, st)], s: st, x: ChangeFile): Result[(reln, st), System.Error] & Impure = 
    //     let Headers(arr) = x.headers;
    //     let ixs = makeIndices(arr);
    //     let eval1 = (st,r) -> { let eval2 = eval(st); let RowEvaluator(f) = eval2; f(ixs, r) };
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
    // pub def importRowsWithCountAndAccum(eval: (Int32, st) -> RowEvaluator[(reln, st)], s: st, x: ChangeFile): Result[(reln, st), System.Error] & Impure = 
    //     let Headers(arr) = x.headers;
    //     let ixs = makeIndices(arr);
    //     let eval1 = (n, st, r) -> { let eval2 = eval(n, st); let RowEvaluator(f) = eval2; f(ixs, r) };
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