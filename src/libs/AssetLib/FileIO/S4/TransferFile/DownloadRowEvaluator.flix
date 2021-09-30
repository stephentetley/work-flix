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



namespace AssetLib/FileIO/S4/TransferFile {

    pub opaque type DownloadRowEvaluator[a] = (Map[String,Int32], Array[String]) ~> Result[a, String]
}

namespace AssetLib/FileIO/S4/TransferFile/DownloadRowEvaluator {

    use FromString.fromString;

    use AssetLib/FileIO/S4/TransferFile.DownloadRowEvaluator;
    use AssetLib/FileIO/S4/TransferFile.DownloadRowEvaluator.{DownloadRowEvaluator};


    pub def evaluateString(splitter: String ~> Array[String],
                           headers: Map[String, Int32],
                           input: String,
                           eval: DownloadRowEvaluator[a]): Result[a, String] & Impure =
        use Result.{flatMap};
        let arr = splitter(input);
        apply1(eval, headers, arr)

    pub def makeHeaders(names: Array[String]): Map[String,Int32] & Impure =
        let step = (acc, x) -> { let (i, mx) = acc; (i + 1, Map.insert(x, i, mx)) };
        Array.foldLeft(step, (0, Map.empty()), names) |> snd


    pub def return(x: a): DownloadRowEvaluator[a] =
        DownloadRowEvaluator((_,_) -> Ok(x) as & Impure)

    def apply1(x: DownloadRowEvaluator[a], indices: Map[String, Int32], row: Array[String]): Result[a, String] & Impure =
        let DownloadRowEvaluator(f) = x;
        f(indices, row)

    pub def throwError(msg: String): DownloadRowEvaluator[a] =
        DownloadRowEvaluator((_,_) -> Err(msg) as & Impure)

    pub def swapError(ma: DownloadRowEvaluator[a], msg: String): DownloadRowEvaluator[a] =
        DownloadRowEvaluator((ixs, row) ->
            match apply1(ma, ixs, row) {
                case Ok(a) => Ok(a)
                case Err(_) => Err(msg)
            }
        )

    pub def map(f: a -> b & ef, x: DownloadRowEvaluator[a]): DownloadRowEvaluator[b] =
        DownloadRowEvaluator((ixs, row) ->
            match apply1(x, ixs, row) {
                case Ok(a) => {
                    let ans = f(a) as & Impure;
                    Ok(ans)
                }
                case Err(e) => Err(e)
            }
        )

    pub def ap(mf: DownloadRowEvaluator[a -> b & ef], ma: DownloadRowEvaluator[a]): DownloadRowEvaluator[b] =
        DownloadRowEvaluator((ixs, row) ->
            match apply1(mf, ixs, row) {
                case Ok(f) => {
                    match apply1(ma, ixs, row) {
                        case Ok(a) => Ok(f(a) as & Impure)
                        case Err(e2) => Err(e2)
                    }
                }
                case Err(e1) => Err(e1)
            }
        )

    
    pub def seqLeft(ma: DownloadRowEvaluator[a], mb: DownloadRowEvaluator[b]): DownloadRowEvaluator[a] = 
        DownloadRowEvaluator((ixs, row) ->
            match apply1(ma, ixs, row) { 
                case Ok(a) => match apply1(mb,ixs, row) {
                    case Ok(_) => Ok(a)
                    case Err(e) => Err(e)
                }
                case Err(e) => Err(e)
            }
        )

    pub def seqRight(ma: DownloadRowEvaluator[a], mb: DownloadRowEvaluator[b]): DownloadRowEvaluator[b] = 
        DownloadRowEvaluator((ixs, row) ->
            match apply1(ma, ixs, row) { 
                case Ok(_) => apply1(mb, ixs, row)
                case Err(e) => Err(e)
            }
        )

    pub def bind(x: DownloadRowEvaluator[a], k: a -> DownloadRowEvaluator[b]): DownloadRowEvaluator[b] =
        DownloadRowEvaluator((ixs, row) ->
            match apply1(x, ixs, row) {
                case Ok(a) => apply1(k(a), ixs, row)
                case Err(e) => Err(e)
            }
        )

    pub def flatMap(k: a -> DownloadRowEvaluator[b], x: DownloadRowEvaluator[a]): DownloadRowEvaluator[b] = bind(x, k)


    pub def kleisliLeft(f1: a -> DownloadRowEvaluator[b], f2: b -> DownloadRowEvaluator[c], x: a): DownloadRowEvaluator[c] =
        DownloadRowEvaluator((ixs, row) -> 
            match apply1(f1(x), ixs, row) { 
                case Ok(b) => apply1(f2(b), ixs, row)
                case Err(e) => Err(e)
            }
        )

    pub def kleisliRight(f1: b -> DownloadRowEvaluator[c], f2: a -> DownloadRowEvaluator[b], x: a): DownloadRowEvaluator[c] =
        kleisliLeft(f2, f1, x)

    pub def optional(x: DownloadRowEvaluator[a]): DownloadRowEvaluator[Option[a]] =
        DownloadRowEvaluator((ixs, row) ->
            match apply1(x, ixs, row) {
                case Ok(a) => Ok(Some(a))
                case Err(_) => Ok(None)
            }
        )

    pub def liftAction(fn: Unit ~> a): DownloadRowEvaluator[a] =
        DownloadRowEvaluator((_, _) -> let x = fn(); Ok(x))

    pub def liftOption(x: Option[a],  errMsg: String): DownloadRowEvaluator[a] = match x { 
        case Some(x1) => return(x1)
        case None => throwError(errMsg)
    }
        

    pub def liftResult(x: Result[a, String]): DownloadRowEvaluator[a] =
        DownloadRowEvaluator((_,_) -> x as & Impure)

    pub def liftActionResult(fn: Unit ~> Result[a, String] ): DownloadRowEvaluator[a] =
        DownloadRowEvaluator((_,_) -> fn())

    // Cell readers, by label only

    /// Note - answer is trimmed, use `getCell` if you need exact contents
    pub def getStringNamed(label: String): DownloadRowEvaluator[String] =
        map(String.trim, getCell(label))

    pub def getCell(label: String): DownloadRowEvaluator[String] =
        DownloadRowEvaluator((ixs, row) -> match Map.get(label, ixs) {
            case None => Err("getCell('${label}')")
            case Some(ix) => {
                if (ix >= 0 and ix < Array.length(row)) {
                    let s = row[ix];
                    Ok(s)
                } else {
                    Err("getCell('${label}')")
                }
            }
        })

    pub def evalMatchesNamed(label: String, patt: Text/Regex.Pattern, eval: Text/Regex.MatchEvaluator[a]): DownloadRowEvaluator[a] =
        let* input = getStringNamed(label);
        let* ans = liftActionResult(_ -> Text/Regex.evalMatches(patt, eval, input));
        return(ans)

    pub def evalContainsNamed(label: String, patt: Text/Regex.Pattern, eval: Text/Regex.MatchEvaluator[a]): DownloadRowEvaluator[a] =
        let* input = getStringNamed(label);
        let* ans = liftActionResult(_ -> Text/Regex.evalContains(patt, eval, input));
        return(ans)

    pub def getInt8Named(label: String): DownloadRowEvaluator[Int8] =
        let* s = getStringNamed(label);
        liftOption(fromString(s): Option[Int8], "getInt8Named('${label}')")

    pub def getInt16Named(label: String): DownloadRowEvaluator[Int16] =
        let* s = getStringNamed(label);
        liftOption(fromString(s): Option[Int16], "getInt16Named('${label}')")

    pub def getInt32Named(label: String): DownloadRowEvaluator[Int32] =
        let* s = getStringNamed(label);
        liftOption(fromString(s): Option[Int32], "getInt32Named('${label}')")

    pub def getInt64Named(label: String): DownloadRowEvaluator[Int64] =
        let* s = getStringNamed(label);
        liftOption(fromString(s): Option[Int64], "getInt64Named('${label}')")

    pub def getFloat32Named(label: String): DownloadRowEvaluator[Float32] =
        let* s = getStringNamed(label);
        liftOption(fromString(s): Option[Float32], "getFloat32Named('${label}')")

    pub def getFloat64Named(label: String): DownloadRowEvaluator[Float64] =
        let* s = getStringNamed(label);
        liftOption(fromString(s): Option[Float64], "getFloat64Named('${label}')")

    pub def getLocalDateNamed(label: String, formatter: Time/Format.DateFormatter): DownloadRowEvaluator[Time.LocalDate] =
        let* input = getStringNamed(label);
        liftOption(Time/LocalDate.parse(formatter, input), "getLocalDateNamed('${label}')")

    pub def getLocalDateTimeNamed(label: String, formatter: Time/Format.DateTimeFormatter): DownloadRowEvaluator[Time.LocalDateTime] =
        let* input = getStringNamed(label);
        liftOption(Time/LocalDateTime.parse(formatter, input), "getLocalDateTimeNamed('${label}')")

    pub def getLocalTime(label: String, formatter: Time/Format.TimeFormatter): DownloadRowEvaluator[Time.LocalTime] =
        let* input = getStringNamed(label);
        liftOption(Time/LocalTime.parse(formatter, input), "getLocalTime('${label}')")

    pub def getS4DateNamed(label: String): DownloadRowEvaluator[Time.LocalDate] =
        let* fmt = liftOption(Time/Format/DateFormatter.ofPattern("dd.MM.yyyy"), "getS4DateNamed('${label}')");
        getLocalDateNamed(label, fmt)

    pub def getS4BoolNamed(label: String): DownloadRowEvaluator[Bool] =
        bind( getStringNamed(label)
            , x -> match x { 
                case ""     => return(false)
                case "X"    => return(true)
                case _      => throwError("getS4BoolNamed('${x}')")
            })


    ///
    /// Applies the binary function `f` to the values in `o1` and `o2`.
    ///
    /// Returns an error if either `o1` or `o2` are errors.
    ///
    pub def lift2(f: (t1, t2) -> u & ef, o1: DownloadRowEvaluator[t1], o2: DownloadRowEvaluator[t2]): DownloadRowEvaluator[u] =
        ap(map(f, o1), o2)

    ///
    /// Applies the ternary function `f` to the values in `o1`, `o2` and `o3`.
    ///
    /// Returns an error if any of `o1`, `o2` and `o3` are errors.
    ///
    pub def lift3(f: (t1, t2, t3) -> u & ef, o1: DownloadRowEvaluator[t1], o2: DownloadRowEvaluator[t2], o3: DownloadRowEvaluator[t3]): DownloadRowEvaluator[u] =
        ap(lift2(f, o1, o2), o3)

    ///
    /// Applies the 4-ary function `f` to the values in `o1`, `o2`, `o3` and `o4`.
    ///
    /// Returns an error if any of `o1`, `o2`, `o3` and `o4` are errors.
    ///
    pub def lift4(f: (t1, t2, t3, t4) -> u & ef, o1: DownloadRowEvaluator[t1], o2: DownloadRowEvaluator[t2], o3: DownloadRowEvaluator[t3], o4: DownloadRowEvaluator[t4]): DownloadRowEvaluator[u] =
        ap(lift3(f, o1, o2, o3), o4)

    ///
    /// Applies the 5-ary function `f` to the values in `o1`, `o2`, ... `o5`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o5` are errors.
    ///
    pub def lift5(f: (t1, t2, t3, t4, t5) -> u & ef, o1: DownloadRowEvaluator[t1], o2: DownloadRowEvaluator[t2], o3: DownloadRowEvaluator[t3], o4: DownloadRowEvaluator[t4], o5: DownloadRowEvaluator[t5]): DownloadRowEvaluator[u] =
        ap(lift4(f, o1, o2, o3, o4), o5)

    ///
    /// Applies the 6-ary function `f` to the values in `o1`, `o2`, ... `o6`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o6` are errors.
    ///
    pub def lift6(f: (t1, t2, t3, t4, t5, t6) -> u & ef, o1: DownloadRowEvaluator[t1], o2: DownloadRowEvaluator[t2], o3: DownloadRowEvaluator[t3], o4: DownloadRowEvaluator[t4], o5: DownloadRowEvaluator[t5], o6: DownloadRowEvaluator[t6]): DownloadRowEvaluator[u] =
        ap(lift5(f, o1, o2, o3, o4, o5), o6)

    ///
    /// Applies the 7-ary function `f` to the values in `o1`, `o2`, ... `o7`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o7` are errors.
    ///
    pub def lift7(f: (t1, t2, t3, t4, t5, t6, t7) -> u & ef, o1: DownloadRowEvaluator[t1], o2: DownloadRowEvaluator[t2], o3: DownloadRowEvaluator[t3], o4: DownloadRowEvaluator[t4], o5: DownloadRowEvaluator[t5], o6: DownloadRowEvaluator[t6], o7: DownloadRowEvaluator[t7]): DownloadRowEvaluator[u] =
        ap(lift6(f, o1, o2, o3, o4, o5, o6), o7)

    ///
    /// Applies the 8-ary function `f` to the values in `o1`, `o2`, ... `o8`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o8` are errors.
    ///
    pub def lift8(f: (t1, t2, t3, t4, t5, t6, t7, t8) -> u & ef, o1: DownloadRowEvaluator[t1], o2: DownloadRowEvaluator[t2], o3: DownloadRowEvaluator[t3], o4: DownloadRowEvaluator[t4], o5: DownloadRowEvaluator[t5], o6: DownloadRowEvaluator[t6], o7: DownloadRowEvaluator[t7], o8: DownloadRowEvaluator[t8]): DownloadRowEvaluator[u] =
        ap(lift7(f, o1, o2, o3, o4, o5, o6, o7), o8)

    ///
    /// Applies the 9-ary function `f` to the values in `o1`, `o2`, ... `o9`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o9` are errors.
    ///
    pub def lift9(f: (t1, t2, t3, t4, t5, t6, t7, t8, t9) -> u & ef, o1: DownloadRowEvaluator[t1], o2: DownloadRowEvaluator[t2], o3: DownloadRowEvaluator[t3], o4: DownloadRowEvaluator[t4], o5: DownloadRowEvaluator[t5], o6: DownloadRowEvaluator[t6], o7: DownloadRowEvaluator[t7], o8: DownloadRowEvaluator[t8], o9: DownloadRowEvaluator[t9]): DownloadRowEvaluator[u] =
        ap(lift8(f, o1, o2, o3, o4, o5, o6, o7, o8), o9)

    ///
    /// Applies the 10-ary function `f` to the values in `o1`, `o2`, ... `o10`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o10` are errors.
    ///
    pub def lift10(f: (t1, t2, t3, t4, t5, t6, t7, t8, t9, t10) -> u & ef, o1: DownloadRowEvaluator[t1], o2: DownloadRowEvaluator[t2], o3: DownloadRowEvaluator[t3], o4: DownloadRowEvaluator[t4], o5: DownloadRowEvaluator[t5], o6: DownloadRowEvaluator[t6], o7: DownloadRowEvaluator[t7], o8: DownloadRowEvaluator[t8], o9: DownloadRowEvaluator[t9], o10: DownloadRowEvaluator[t10]): DownloadRowEvaluator[u] =
        ap(lift9(f, o1, o2, o3, o4, o5, o6, o7, o8, o9), o10)

    ///
    /// Returns a 2 element tuple with the results of applying the parsers `o1` and `o2`.
    ///
    /// Returns an error if evaluating either `o1` or `o2` is an error.
    ///
    pub def tuple2(o1: DownloadRowEvaluator[t1], o2: DownloadRowEvaluator[t2]): DownloadRowEvaluator[(t1, t2)] =
        lift2((x,y) -> (x,y), o1, o2)

    ///
    /// Returns a 3 element tuple with the results of applying the parsers `o1`, `o2` and `o3`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2` and `o3` is an error.
    ///
    pub def tuple3(o1: DownloadRowEvaluator[t1], o2: DownloadRowEvaluator[t2], o3: DownloadRowEvaluator[t3]): DownloadRowEvaluator[(t1, t2, t3)] =
        lift3((x1, x2, x3) -> (x1, x2, x3), o1, o2, o3)

    ///
    /// Returns a 4 element tuple with the results of applying the parsers `o1`, `o2`, `o3` and `o4`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, `o3` and `o4` is an error.
    ///
    pub def tuple4(o1: DownloadRowEvaluator[t1], o2: DownloadRowEvaluator[t2], o3: DownloadRowEvaluator[t3], o4: DownloadRowEvaluator[t4]): DownloadRowEvaluator[(t1, t2, t3, t4)]  =
        lift4((x1, x2, x3, x4) -> (x1, x2, x3, x4), o1, o2, o3, o4)

    ///
    /// Returns a 5 element tuple with the results of applying the parsers `o1`, `o2`, ... `o5`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o5` is an error.
    ///
    pub def tuple5(o1: DownloadRowEvaluator[t1], o2: DownloadRowEvaluator[t2], o3: DownloadRowEvaluator[t3], o4: DownloadRowEvaluator[t4], o5: DownloadRowEvaluator[t5]): DownloadRowEvaluator[(t1, t2, t3, t4, t5)]  =
        lift5((x1, x2, x3, x4, x5) -> (x1, x2, x3, x4, x5), o1, o2, o3, o4, o5)

    ///
    /// Returns a 6 element tuple with the results of applying the parsers `o1`, `o2`, ... `o6`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o6` is an error.
    ///
    pub def tuple6(o1: DownloadRowEvaluator[t1], o2: DownloadRowEvaluator[t2], o3: DownloadRowEvaluator[t3], o4: DownloadRowEvaluator[t4], o5: DownloadRowEvaluator[t5], o6: DownloadRowEvaluator[t6]): DownloadRowEvaluator[(t1, t2, t3, t4, t5, t6)]  =
        lift6((x1, x2, x3, x4, x5, x6) -> (x1, x2, x3, x4, x5, x6), o1, o2, o3, o4, o5, o6)

    ///
    /// Returns a 7 element tuple with the results of applying the parsers `o1`, `o2`, ... `o7`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o7` is an error.
    ///
    pub def tuple7(o1: DownloadRowEvaluator[t1], o2: DownloadRowEvaluator[t2], o3: DownloadRowEvaluator[t3], o4: DownloadRowEvaluator[t4], o5: DownloadRowEvaluator[t5], o6: DownloadRowEvaluator[t6], o7: DownloadRowEvaluator[t7]): DownloadRowEvaluator[(t1, t2, t3, t4, t5, t6, t7)]  =
        lift7((x1, x2, x3, x4, x5, x6, x7) -> (x1, x2, x3, x4, x5, x6, x7), o1, o2, o3, o4, o5, o6, o7)

    ///
    /// Returns a 8 element tuple with the results of applying the parsers `o1`, `o2`, ... `o8`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o8` is an error.
    ///
    pub def tuple8(o1: DownloadRowEvaluator[t1], o2: DownloadRowEvaluator[t2], o3: DownloadRowEvaluator[t3], o4: DownloadRowEvaluator[t4], o5: DownloadRowEvaluator[t5], o6: DownloadRowEvaluator[t6], o7: DownloadRowEvaluator[t7], o8: DownloadRowEvaluator[t8]): DownloadRowEvaluator[(t1, t2, t3, t4, t5, t6, t7, t8)]  =
        lift8((x1, x2, x3, x4, x5, x6, x7, x8) -> (x1, x2, x3, x4, x5, x6, x7, x8), o1, o2, o3, o4, o5, o6, o7, o8)

    ///
    /// Returns a 9 element tuple with the results of applying the parsers `o1`, `o2`, ... `o9`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o9` is an error.
    ///
    pub def tuple9(o1: DownloadRowEvaluator[t1], o2: DownloadRowEvaluator[t2], o3: DownloadRowEvaluator[t3], o4: DownloadRowEvaluator[t4], o5: DownloadRowEvaluator[t5], o6: DownloadRowEvaluator[t6], o7: DownloadRowEvaluator[t7], o8: DownloadRowEvaluator[t8], o9: DownloadRowEvaluator[t9]): DownloadRowEvaluator[(t1, t2, t3, t4, t5, t6, t7, t8, t9)]  =
        lift9((x1, x2, x3, x4, x5, x6, x7, x8, x9) -> (x1, x2, x3, x4, x5, x6, x7, x8, x9), o1, o2, o3, o4, o5, o6, o7, o8, o9)

    ///
    /// Returns a 10 element tuple with the results of applying the parsers `o1`, `o2`, ... `o10`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o10` is an error.
    ///
    pub def tuple10(o1: DownloadRowEvaluator[t1], o2: DownloadRowEvaluator[t2], o3: DownloadRowEvaluator[t3], o4: DownloadRowEvaluator[t4], o5: DownloadRowEvaluator[t5], o6: DownloadRowEvaluator[t6], o7: DownloadRowEvaluator[t7], o8: DownloadRowEvaluator[t8], o9: DownloadRowEvaluator[t9], o10: DownloadRowEvaluator[t10]): DownloadRowEvaluator[(t1, t2, t3, t4, t5, t6, t7, t8, t9, t10)]  =
        lift10((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10) -> (x1, x2, x3, x4, x5, x6, x7, x8, x9, x10), o1, o2, o3, o4, o5, o6, o7, o8, o9, o10)


    /// Alias for `seqRight`
    pub def *>(p1: DownloadRowEvaluator[a], p2: DownloadRowEvaluator[b]): DownloadRowEvaluator[b] = seqRight(p1, p2)

    /// Alias for `seqLeft`
    pub def <*(p1: DownloadRowEvaluator[a], p2: DownloadRowEvaluator[b]): DownloadRowEvaluator[a] = seqLeft(p1, p2)

    // Haskell's <$>
    pub def <&>(f: a -> b, p2: DownloadRowEvaluator[a]): DownloadRowEvaluator[b] =
        map(f, p2)

    pub def <&(x: b, p2: DownloadRowEvaluator[a]): DownloadRowEvaluator[b] =
        p2 *> return(x)

    /// Alias for `bind`
    pub def >>=(ma: DownloadRowEvaluator[a], k: a -> DownloadRowEvaluator[b]): DownloadRowEvaluator[b] = 
        bind(ma, k)

    /// Alias for `flatMap` (flipped `bind`)
    pub def =<<(k: a -> DownloadRowEvaluator[b], ma: DownloadRowEvaluator[a]): DownloadRowEvaluator[b] = 
        flatMap(k, ma)


    // Haskell's ap <*>
    pub def <*>(mf: DownloadRowEvaluator[a -> b], p2: DownloadRowEvaluator[a]): DownloadRowEvaluator[b] =
        ap(mf, p2)

    /// Alias for `kleisliLeft`
    pub def >=>(f1: a -> DownloadRowEvaluator[b], f2: b -> DownloadRowEvaluator[c]): a -> DownloadRowEvaluator[c] = 
        x -> kleisliLeft(f1, f2, x)

    /// Alias for `kleisliRight`
    pub def <=<(f1: b -> DownloadRowEvaluator[c], f2: a -> DownloadRowEvaluator[b]): a -> DownloadRowEvaluator[c] = 
        x -> kleisliRight(f1, f2, x)

}