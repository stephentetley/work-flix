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


namespace AssetLib/FileIO/S4/ZTable {

    pub enum RowEvaluator[a](Array[String] -> Result[a, String] & Impure)

    instance Functor[RowEvaluator] { 
        pub def map(f: a -> b & ef, x: RowEvaluator[a]): RowEvaluator[b] & ef = 
            AssetLib/FileIO/S4/ZTable/RowEvaluator.map(f, x)
    }

    instance Applicative[RowEvaluator] { 
        pub def point(x: a): RowEvaluator[a] = 
            AssetLib/FileIO/S4/ZTable/RowEvaluator.point(x)

        pub def ap(f: RowEvaluator[a -> b & ef], x: RowEvaluator[a]): RowEvaluator[b] & ef = 
            AssetLib/FileIO/S4/ZTable/RowEvaluator.ap(f, x)
    }

    instance Monad[RowEvaluator] { 
        pub def flatMap(k: a -> RowEvaluator[b] & ef, x: RowEvaluator[a]): RowEvaluator[b] & ef = 
            AssetLib/FileIO/S4/ZTable/RowEvaluator.flatMap(k, x)
    }
}

namespace AssetLib/FileIO/S4/ZTable/RowEvaluator {

    use FromString.fromString;

    use Time/Format.DateTimeFormatter;
    
    use Text/RegexEval.MatchEvaluator;

    use AssetLib/FileIO/S4/ZTable.RowEvaluator;
    use AssetLib/FileIO/S4/ZTable.RowEvaluator.{RowEvaluator};


    pub def evaluateString(splitter: String -> Array[String] & Impure,
                           input: String,
                           eval: RowEvaluator[a]): Result[a, String] & Impure =
        use Result.{flatMap};
        let arr     = splitter(input);
        apply1(eval, arr)

    pub def point(x: a): RowEvaluator[a] =
        RowEvaluator(_ -> Ok(x) as & Impure)

    pub def throwError(msg: String): RowEvaluator[a] =
        RowEvaluator(_ -> Err(msg) as & Impure)

    def apply1(x: RowEvaluator[a], row: Array[String]): Result[a, String] & Impure =
        let RowEvaluator(f) = x;
        f(row)

    pub def map(f: a -> b & ef, x: RowEvaluator[a]): RowEvaluator[b] & ef =
        RowEvaluator(row ->
            match apply1(x, row) {
                case Ok(a) => {
                    let ans = f(a) as & Impure;
                    Ok(ans)
                }
                case Err(e) => Err(e)
            }
        ) as & ef

    pub def ap(mf: RowEvaluator[a -> b & ef], ma: RowEvaluator[a]): RowEvaluator[b] & ef =
        RowEvaluator(row ->
            match apply1(mf, row) {
                case Ok(f) => {
                    match apply1(ma, row) {
                        case Ok(a) => Ok(f(a) as & Impure)
                        case Err(e2) => Err(e2)
                    }
                }
                case Err(e1) => Err(e1)
            }
        ) as & ef

    pub def bind(x: RowEvaluator[a], k: a -> RowEvaluator[b] & ef): RowEvaluator[b] & ef =
        RowEvaluator(row ->
            match apply1(x, row) {
                case Ok(a) => apply1(k(a), row)
                case Err(e) => Err(e)
            }
        ) as & ef

    pub def flatMap(k: a -> RowEvaluator[b] & ef, x: RowEvaluator[a]): RowEvaluator[b] & ef = bind(x, k)

    pub def optional(x: RowEvaluator[a]): RowEvaluator[Option[a]] =
        RowEvaluator(r ->
            match apply1(x, r) {
                case Ok(a) => Ok(Some(a))
                case Err(_) => Ok(None)
            }
        )

    pub def liftOption(x: Option[a], errMsg: String): RowEvaluator[a] = match x {
        case Some(x1) => point(x1)
        case None => throwError(errMsg)
    }

    pub def liftResult(x: Result[a, String]): RowEvaluator[a] =
        RowEvaluator(_ -> x as & Impure)

    pub def liftOperation(fn: Unit -> Result[a, String] & Impure): RowEvaluator[a] =
        RowEvaluator(_ -> fn())

    // Cell readers, by index only

    /// Note - answer is trimmed, use `getCell` if you need exact contents
    pub def getStringAt(ix: Int32): RowEvaluator[String] =
        map(String.trim, getCell(ix))

    pub def getCell(ix: Int32): RowEvaluator[String] =
        RowEvaluator(row ->
            if (ix >= 0 and ix < Array.length(row)) {
                let s = row[ix];
                Ok(s)
            } else {
                Err("getCell(${Int32.toString(ix)})")
            }
        )


    pub def evalMatchesAt(ix: Int32, patt: Text/Regex.Pattern, eval: MatchEvaluator[a]): RowEvaluator[a] =
        let* input = getStringAt(ix);
        let* ans = liftOperation(_ -> Text/RegexEval/Regex.matchAll(patt, eval, input));
        point(ans)

    pub def evalContainsAt(ix: Int32, patt: Text/Regex.Pattern, eval: MatchEvaluator[a]): RowEvaluator[a] =
        let* input = getStringAt(ix);
        let* ans = liftOperation(_ -> Text/RegexEval/Regex.firstSubmatch(patt, eval, input));
        point(ans)

    pub def getInt8At(ix: Int32): RowEvaluator[Int8] =
        let* s = getStringAt(ix);
        liftOption(fromString(s), "getInt8At(${ix})")

    pub def getInt16At(ix: Int32): RowEvaluator[Int16] =
        let* s = getStringAt(ix);
        liftOption(fromString(s), "getInt16At(${ix})")

    pub def getInt32At(ix: Int32): RowEvaluator[Int32] =
        let* s = getStringAt(ix);
        liftOption(fromString(s), "getInt32At(${ix})")

    pub def getInt64At(ix: Int32): RowEvaluator[Int64] =
        let* s = getStringAt(ix);
        liftOption(fromString(s), "getInt64At(${ix})")

    pub def getFloat32At(ix: Int32): RowEvaluator[Float32] =
        let* s = getStringAt(ix);
        liftOption(fromString(s), "getFloat32At(${ix})")

    pub def getFloat64At(ix: Int32): RowEvaluator[Float64] =
        let* s = getStringAt(ix);
        liftOption(fromString(s), "getFloat64At('${ix})")

    pub def getLocalDateAt(ix: Int32, formatter: DateTimeFormatter[Time/Format.DateFormat]): RowEvaluator[Time.LocalDate] =
        let* input = getStringAt(ix);
        liftResult(Time/LocalDate.parse(formatter, input))


    pub def getLocalDateTimeAt(ix: Int32, formatter: DateTimeFormatter[Time/Format.DateTimeFormat]): RowEvaluator[Time.LocalDateTime] =
        let* input = getStringAt(ix);
        liftResult(Time/LocalDateTime.parse(formatter, input))


    pub def getLocalTimeAt(ix: Int32, formatter: DateTimeFormatter[Time/Format.TimeFormat]): RowEvaluator[Time.LocalTime] =
        let* input = getStringAt(ix);
        liftResult(Time/LocalTime.parse(formatter, input))



}