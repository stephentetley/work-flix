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

    /// The LHS is generally between 2 and 4 cells wide, Array not really necessary...

    pub enum RowEvaluator[r: Region, a: Type](Array[String, r] -> Result[a, String])

    instance Functor[RowEvaluator[r]] { 
        pub def map(f: a -> b & ef, x: RowEvaluator[r, a]): RowEvaluator[r, b] & ef = 
            AssetLib/FileIO/S4/ZTable/RowEvaluator.map(f, x)
    }

    instance Applicative[RowEvaluator[r]] { 
        pub def point(x: a): RowEvaluator[r, a] = 
            AssetLib/FileIO/S4/ZTable/RowEvaluator.point(x)

        pub def ap(f: RowEvaluator[r, a -> b & ef], x: RowEvaluator[r, a]): RowEvaluator[r, b] & ef = 
            AssetLib/FileIO/S4/ZTable/RowEvaluator.ap(f, x)
    }

    instance Monad[RowEvaluator[r]] { 
        pub def flatMap(k: a -> RowEvaluator[r, b] & ef, x: RowEvaluator[r, a]): RowEvaluator[r, b] & ef = 
            AssetLib/FileIO/S4/ZTable/RowEvaluator.flatMap(k, x)
    }
}

namespace AssetLib/FileIO/S4/ZTable/RowEvaluator {

    use FromString.fromString;

    use Time/Format.DateTimeFormatter;
    
    use Text/RegexEval.MatchEvaluator;

    use AssetLib/FileIO/S4/ZTable.RowEvaluator;
    use AssetLib/FileIO/S4/ZTable.RowEvaluator.{RowEvaluator};


    pub def evaluateString(r: Region[r], 
                            splitter: String -> Array[String, r] \ Write(r),
                            input: String,
                            eval: RowEvaluator[r, a]): Result[a, String] \ { Read(r), Write(r) } =
        use Result.{flatMap};
        let arr     = splitter(input);
        apply1(eval, arr)

    pub def point(x: a): RowEvaluator[r, a] =
        RowEvaluator(_ -> Ok(x))

    pub def throwError(msg: String): RowEvaluator[r, a] =
        RowEvaluator(_ -> Err(msg))

    def apply1(x: RowEvaluator[r, a], row: Array[String, r]): Result[a, String] =
        let RowEvaluator(f) = x;
        f(row)


    def getRegionOf(): RowEvaluator[r, Region[r]] = RowEvaluator(row -> Ok(Scoped.regionOf(row)))


    pub def map(f: a -> b & ef, x: RowEvaluator[r, a]): RowEvaluator[r, b] & ef =
        RowEvaluator(row ->
            match apply1(x, row) {
                case Ok(a) => {
                    let ans = f(a) as & Pure;
                    Ok(ans)
                }
                case Err(e) => Err(e)
            }
        ) as & ef

    pub def ap(mf: RowEvaluator[r, a -> b & ef], ma: RowEvaluator[r, a]): RowEvaluator[r, b] & ef =
        RowEvaluator(row ->
            match apply1(mf, row) {
                case Ok(f) => {
                    match apply1(ma, row) {
                        case Ok(a) => Ok(f(a) as & Pure)
                        case Err(e2) => Err(e2)
                    }
                }
                case Err(e1) => Err(e1)
            }
        ) as & ef

    pub def bind(x: RowEvaluator[r, a], k: a -> RowEvaluator[r, b] & ef): RowEvaluator[r, b] & ef =
        RowEvaluator(row ->
            match apply1(x, row) {
                case Ok(a) => apply1(k(a) as & Pure, row)
                case Err(e) => Err(e)
            }
        ) as & ef

    pub def flatMap(k: a -> RowEvaluator[r, b] & ef, x: RowEvaluator[r, a]): RowEvaluator[r, b] & ef = bind(x, k)

    pub def optional(x: RowEvaluator[r, a]): RowEvaluator[r, Option[a]] =
        RowEvaluator(r ->
            match apply1(x, r) {
                case Ok(a) => Ok(Some(a))
                case Err(_) => Ok(None)
            }
        )

    pub def liftOption(x: Option[a], errMsg: String): RowEvaluator[r, a] = match x {
        case Some(x1) => point(x1)
        case None => throwError(errMsg)
    }

    pub def liftResult(x: Result[a, String]): RowEvaluator[r, a] =
        RowEvaluator(_ -> x)

    pub def liftOperation(fn: Unit -> Result[a, String] & ef): RowEvaluator[r, a] & ef =
        RowEvaluator(_ -> fn() as & Pure) as & ef

    // Cell readers, by index only

    /// Note - answer is trimmed, use `getCell` if you need exact contents
    pub def getStringAt(ix: Int32): RowEvaluator[r, String] \ Read(r) =
        map(String.trim, getCell(ix))

    pub def getCell(ix: Int32): RowEvaluator[r, String] \ Read(r) =
        RowEvaluator(row ->
            if (ix >= 0 and ix < Array.length(row)) {
                let s = Array.get(ix, row) as & Pure;
                Ok(s)
            } else {
                Err("getCell(${Int32.toString(ix)})")
            } 
        ) as \ Read(r)


    pub def evalMatchesAt(ix: Int32, patt: Text/Regex.Pattern, eval: MatchEvaluator[r, a]): RowEvaluator[r, a] \ Read(r) =
        let* input = getStringAt(ix);
        let* r1    = getRegionOf();
        let* ans = liftOperation(_ -> Text/RegexEval/Regex.matchAll(r1, eval, patt, input));
        point(ans)

    pub def evalContainsAt(ix: Int32, patt: Text/Regex.Pattern, eval: MatchEvaluator[r, a]): RowEvaluator[r, a] \ Read(r) =
        let* input  = getStringAt(ix);
        let* r1     = getRegionOf();
        let* ans    = liftOperation(_ -> Text/RegexEval/Regex.firstSubmatch(r1, eval, patt, input));
        point(ans)

    pub def getInt8At(ix: Int32): RowEvaluator[r, Int8] \ Read(r) =
        let* s = getStringAt(ix);
        liftOption(fromString(s), "getInt8At(${ix})")

    pub def getInt16At(ix: Int32): RowEvaluator[r, Int16] \ Read(r) =
        let* s = getStringAt(ix);
        liftOption(fromString(s), "getInt16At(${ix})")

    pub def getInt32At(ix: Int32): RowEvaluator[r, Int32] \ Read(r) =
        let* s = getStringAt(ix);
        liftOption(fromString(s), "getInt32At(${ix})")

    pub def getInt64At(ix: Int32): RowEvaluator[r, Int64] \ Read(r) =
        let* s = getStringAt(ix);
        liftOption(fromString(s), "getInt64At(${ix})")

    pub def getFloat32At(ix: Int32): RowEvaluator[r, Float32] \ Read(r) =
        let* s = getStringAt(ix);
        liftOption(fromString(s), "getFloat32At(${ix})")

    pub def getFloat64At(ix: Int32): RowEvaluator[r, Float64] \ Read(r) =
        let* s = getStringAt(ix);
        liftOption(fromString(s), "getFloat64At('${ix})")

    pub def getLocalDateAt(ix: Int32, formatter: DateTimeFormatter[Time/Format.DateFormat]): RowEvaluator[r, Time.LocalDate] \ Read(r) =
        let* input = getStringAt(ix);
        liftResult(Time/LocalDate.parse(formatter, input))


    pub def getLocalDateTimeAt(ix: Int32, formatter: DateTimeFormatter[Time/Format.DateTimeFormat]): RowEvaluator[r, Time.LocalDateTime] \ Read(r) =
        let* input = getStringAt(ix);
        liftResult(Time/LocalDateTime.parse(formatter, input))


    pub def getLocalTimeAt(ix: Int32, formatter: DateTimeFormatter[Time/Format.TimeFormat]): RowEvaluator[r, Time.LocalTime] \ Read(r) =
        let* input = getStringAt(ix);
        liftResult(Time/LocalTime.parse(formatter, input))



}