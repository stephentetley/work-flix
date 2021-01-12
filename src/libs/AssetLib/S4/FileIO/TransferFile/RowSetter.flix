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



namespace AssetLib/S4/FileIO/TransferFile {

    pub opaque type RowSetter[a] = (Map[String,Int32], Array[String]) ~> Result[a, String]
}

namespace AssetLib/S4/FileIO/TransferFile/RowSetter {

    use ToString.toString;

    use AssetLib/S4/FileIO/TransferFile.RowSetter;
    use AssetLib/S4/FileIO/TransferFile.RowSetter.{RowSetter};


    pub def evaluateString(splitter: String ~> Array[String],
                           headers: Map[String, Int32],
                           input: String,
                           eval: RowSetter[a]): Result[a, String] & Impure =
        use Result.{flatMap};
        let arr = splitter(input);
        apply1(eval, headers, arr)

    pub def makeHeaders(names: Array[String]): Map[String,Int32] & Impure =
        let step = (acc, x) -> { let (i, mx) = acc; (i + 1, Map.insert(x, i, mx)) };
        Array.foldLeft(step, (0, Map.empty()), names) |> snd


    pub def return(x: a): RowSetter[a] =
        RowSetter((_,_) -> Ok(x) as & Impure)

    def apply1(x: RowSetter[a], indices: Map[String, Int32], row: Array[String]): Result[a, String] & Impure =
        let RowSetter(f) = x;
        f(indices, row)

    pub def throwError(msg: String): RowSetter[a] =
        RowSetter((_,_) -> Err(msg) as & Impure)

    pub def swapError(ma: RowSetter[a], msg: String): RowSetter[a] =
        RowSetter((ixs, row) ->
            match apply1(ma, ixs, row) {
                case Ok(a) => Ok(a)
                case Err(_) => Err(msg)
            }
        )

    pub def map(f: a -> b & ef, x: RowSetter[a]): RowSetter[b] =
        RowSetter((ixs, row) ->
            match apply1(x, ixs, row) {
                case Ok(a) => {
                    let ans = f(a) as & Impure;
                    Ok(ans)
                }
                case Err(e) => Err(e)
            }
        )

    pub def ap(mf: RowSetter[a -> b & ef], ma: RowSetter[a]): RowSetter[b] =
        RowSetter((ixs, row) ->
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

    
    pub def seqLeft(ma: RowSetter[a], mb: RowSetter[b]): RowSetter[a] = 
        RowSetter((ixs, row) ->
            match apply1(ma, ixs, row) { 
                case Ok(a) => match apply1(mb,ixs, row) {
                    case Ok(_) => Ok(a)
                    case Err(e) => Err(e)
                }
                case Err(e) => Err(e)
            }
        )

    pub def seqRight(ma: RowSetter[a], mb: RowSetter[b]): RowSetter[b] = 
        RowSetter((ixs, row) ->
            match apply1(ma, ixs, row) { 
                case Ok(_) => apply1(mb, ixs, row)
                case Err(e) => Err(e)
            }
        )

    pub def bind(x: RowSetter[a], k: a -> RowSetter[b]): RowSetter[b] =
        RowSetter((ixs, row) ->
            match apply1(x, ixs, row) {
                case Ok(a) => apply1(k(a), ixs, row)
                case Err(e) => Err(e)
            }
        )

    pub def flatMap(k: a -> RowSetter[b], x: RowSetter[a]): RowSetter[b] = bind(x, k)


    pub def kleisliLeft(f1: a -> RowSetter[b], f2: b -> RowSetter[c], x: a): RowSetter[c] =
        RowSetter((ixs, row) -> 
            match apply1(f1(x), ixs, row) { 
                case Ok(b) => apply1(f2(b), ixs, row)
                case Err(e) => Err(e)
            }
        )

    pub def kleisliRight(f1: b -> RowSetter[c], f2: a -> RowSetter[b], x: a): RowSetter[c] =
        kleisliLeft(f2, f1, x)

    pub def optional(x: RowSetter[a]): RowSetter[Option[a]] =
        RowSetter((ixs, row) ->
            match apply1(x, ixs, row) {
                case Ok(a) => Ok(Some(a))
                case Err(_) => Ok(None)
            }
        )

    pub def liftAction(fn: Unit ~> a): RowSetter[a] =
        RowSetter((_, _) -> let x = fn(); Ok(x))

    pub def liftOption(x: Option[a],  errMsg: String): RowSetter[a] = match x { 
        case Some(x1) => return(x1)
        case None => throwError(errMsg)
    }
        

    pub def liftResult(x: Result[a, String]): RowSetter[a] =
        RowSetter((_,_) -> x as & Impure)

    pub def liftActionResult(fn: Unit ~> Result[a, String] ): RowSetter[a] =
        RowSetter((_,_) -> fn())

    // Cell setters, by label only

    /// 
    pub def putStringNamed!(label: String, x: String): RowSetter[Unit] =
        RowSetter((ixs, row) -> match Map.get(label, ixs) {
            case None => Err("putStringNamed!('${label}')")
            case Some(ix) => {
                if (ix >= 0 and ix < Array.length(row)) {
                    row[ix] = x;
                    Ok()
                } else {
                    Err("putStringNamed!('${label}')")
                }
            }
        })


    pub def putInt8Named!(label: String, x: Int8): RowSetter[Unit] =
        putStringNamed!(label, toString(x)) `swapError` "putInt8Named!('${label}')"

    pub def putInt16Named!(label: String, x: Int16): RowSetter[Unit] =
        putStringNamed!(label, toString(x)) `swapError` "putInt16Named!('${label}')"

    pub def putInt32Named!(label: String, x: Int32): RowSetter[Unit] =
        putStringNamed!(label, toString(x)) `swapError` "putInt32Named!('${label}')"

    pub def putInt64Named!(label: String, x: Int64): RowSetter[Unit] =
        putStringNamed!(label, toString(x)) `swapError` "putInt64Named!('${label}')"

    pub def putFloat32Named!(label: String, x: Float32): RowSetter[Unit] =
        putStringNamed!(label, toString(x)) `swapError` "putFloat32Named!('${label}')"

    pub def putFloat64Named!(label: String, x: Float64): RowSetter[Unit] =
        putStringNamed!(label, toString(x)) `swapError` "putFloat64Named!('${label}')"

    pub def putS4DateNamed!(label: String, x: Time.LocalDate): RowSetter[Unit] =
        let* formatter = liftOption(Time/Format/DateFormatter.fromPattern("dd.MM.yyyy"), "putS4DateNamed!('${label}')");
        putStringNamed!(label, Time/LocalDate.format(x, formatter)) `swapError` "putS4DateNamed!('${label}')"

    pub def putS4BoolNamed!(label: String, x: Bool): RowSetter[Unit] = 
        if (x) 
            putStringNamed!(label, "X")
        else 
            putStringNamed!(label, "")

    ///
    /// Applies the binary function `f` to the values in `o1` and `o2`.
    ///
    /// Returns an error if either `o1` or `o2` are errors.
    ///
    pub def lift2(f: (t1, t2) -> u & ef, o1: RowSetter[t1], o2: RowSetter[t2]): RowSetter[u] =
        ap(map(f, o1), o2)

    ///
    /// Applies the ternary function `f` to the values in `o1`, `o2` and `o3`.
    ///
    /// Returns an error if any of `o1`, `o2` and `o3` are errors.
    ///
    pub def lift3(f: (t1, t2, t3) -> u & ef, o1: RowSetter[t1], o2: RowSetter[t2], o3: RowSetter[t3]): RowSetter[u] =
        ap(lift2(f, o1, o2), o3)

    ///
    /// Applies the 4-ary function `f` to the values in `o1`, `o2`, `o3` and `o4`.
    ///
    /// Returns an error if any of `o1`, `o2`, `o3` and `o4` are errors.
    ///
    pub def lift4(f: (t1, t2, t3, t4) -> u & ef, o1: RowSetter[t1], o2: RowSetter[t2], o3: RowSetter[t3], o4: RowSetter[t4]): RowSetter[u] =
        ap(lift3(f, o1, o2, o3), o4)

    ///
    /// Applies the 5-ary function `f` to the values in `o1`, `o2`, ... `o5`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o5` are errors.
    ///
    pub def lift5(f: (t1, t2, t3, t4, t5) -> u & ef, o1: RowSetter[t1], o2: RowSetter[t2], o3: RowSetter[t3], o4: RowSetter[t4], o5: RowSetter[t5]): RowSetter[u] =
        ap(lift4(f, o1, o2, o3, o4), o5)

    ///
    /// Applies the 6-ary function `f` to the values in `o1`, `o2`, ... `o6`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o6` are errors.
    ///
    pub def lift6(f: (t1, t2, t3, t4, t5, t6) -> u & ef, o1: RowSetter[t1], o2: RowSetter[t2], o3: RowSetter[t3], o4: RowSetter[t4], o5: RowSetter[t5], o6: RowSetter[t6]): RowSetter[u] =
        ap(lift5(f, o1, o2, o3, o4, o5), o6)

    ///
    /// Applies the 7-ary function `f` to the values in `o1`, `o2`, ... `o7`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o7` are errors.
    ///
    pub def lift7(f: (t1, t2, t3, t4, t5, t6, t7) -> u & ef, o1: RowSetter[t1], o2: RowSetter[t2], o3: RowSetter[t3], o4: RowSetter[t4], o5: RowSetter[t5], o6: RowSetter[t6], o7: RowSetter[t7]): RowSetter[u] =
        ap(lift6(f, o1, o2, o3, o4, o5, o6), o7)

    ///
    /// Applies the 8-ary function `f` to the values in `o1`, `o2`, ... `o8`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o8` are errors.
    ///
    pub def lift8(f: (t1, t2, t3, t4, t5, t6, t7, t8) -> u & ef, o1: RowSetter[t1], o2: RowSetter[t2], o3: RowSetter[t3], o4: RowSetter[t4], o5: RowSetter[t5], o6: RowSetter[t6], o7: RowSetter[t7], o8: RowSetter[t8]): RowSetter[u] =
        ap(lift7(f, o1, o2, o3, o4, o5, o6, o7), o8)

    ///
    /// Applies the 9-ary function `f` to the values in `o1`, `o2`, ... `o9`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o9` are errors.
    ///
    pub def lift9(f: (t1, t2, t3, t4, t5, t6, t7, t8, t9) -> u & ef, o1: RowSetter[t1], o2: RowSetter[t2], o3: RowSetter[t3], o4: RowSetter[t4], o5: RowSetter[t5], o6: RowSetter[t6], o7: RowSetter[t7], o8: RowSetter[t8], o9: RowSetter[t9]): RowSetter[u] =
        ap(lift8(f, o1, o2, o3, o4, o5, o6, o7, o8), o9)

    ///
    /// Applies the 10-ary function `f` to the values in `o1`, `o2`, ... `o10`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o10` are errors.
    ///
    pub def lift10(f: (t1, t2, t3, t4, t5, t6, t7, t8, t9, t10) -> u & ef, o1: RowSetter[t1], o2: RowSetter[t2], o3: RowSetter[t3], o4: RowSetter[t4], o5: RowSetter[t5], o6: RowSetter[t6], o7: RowSetter[t7], o8: RowSetter[t8], o9: RowSetter[t9], o10: RowSetter[t10]): RowSetter[u] =
        ap(lift9(f, o1, o2, o3, o4, o5, o6, o7, o8, o9), o10)

    ///
    /// Returns a 2 element tuple with the results of applying the parsers `o1` and `o2`.
    ///
    /// Returns an error if evaluating either `o1` or `o2` is an error.
    ///
    pub def tuple2(o1: RowSetter[t1], o2: RowSetter[t2]): RowSetter[(t1, t2)] =
        lift2((x,y) -> (x,y), o1, o2)

    ///
    /// Returns a 3 element tuple with the results of applying the parsers `o1`, `o2` and `o3`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2` and `o3` is an error.
    ///
    pub def tuple3(o1: RowSetter[t1], o2: RowSetter[t2], o3: RowSetter[t3]): RowSetter[(t1, t2, t3)] =
        lift3((x1, x2, x3) -> (x1, x2, x3), o1, o2, o3)

    ///
    /// Returns a 4 element tuple with the results of applying the parsers `o1`, `o2`, `o3` and `o4`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, `o3` and `o4` is an error.
    ///
    pub def tuple4(o1: RowSetter[t1], o2: RowSetter[t2], o3: RowSetter[t3], o4: RowSetter[t4]): RowSetter[(t1, t2, t3, t4)]  =
        lift4((x1, x2, x3, x4) -> (x1, x2, x3, x4), o1, o2, o3, o4)

    ///
    /// Returns a 5 element tuple with the results of applying the parsers `o1`, `o2`, ... `o5`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o5` is an error.
    ///
    pub def tuple5(o1: RowSetter[t1], o2: RowSetter[t2], o3: RowSetter[t3], o4: RowSetter[t4], o5: RowSetter[t5]): RowSetter[(t1, t2, t3, t4, t5)]  =
        lift5((x1, x2, x3, x4, x5) -> (x1, x2, x3, x4, x5), o1, o2, o3, o4, o5)

    ///
    /// Returns a 6 element tuple with the results of applying the parsers `o1`, `o2`, ... `o6`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o6` is an error.
    ///
    pub def tuple6(o1: RowSetter[t1], o2: RowSetter[t2], o3: RowSetter[t3], o4: RowSetter[t4], o5: RowSetter[t5], o6: RowSetter[t6]): RowSetter[(t1, t2, t3, t4, t5, t6)]  =
        lift6((x1, x2, x3, x4, x5, x6) -> (x1, x2, x3, x4, x5, x6), o1, o2, o3, o4, o5, o6)

    ///
    /// Returns a 7 element tuple with the results of applying the parsers `o1`, `o2`, ... `o7`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o7` is an error.
    ///
    pub def tuple7(o1: RowSetter[t1], o2: RowSetter[t2], o3: RowSetter[t3], o4: RowSetter[t4], o5: RowSetter[t5], o6: RowSetter[t6], o7: RowSetter[t7]): RowSetter[(t1, t2, t3, t4, t5, t6, t7)]  =
        lift7((x1, x2, x3, x4, x5, x6, x7) -> (x1, x2, x3, x4, x5, x6, x7), o1, o2, o3, o4, o5, o6, o7)

    ///
    /// Returns a 8 element tuple with the results of applying the parsers `o1`, `o2`, ... `o8`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o8` is an error.
    ///
    pub def tuple8(o1: RowSetter[t1], o2: RowSetter[t2], o3: RowSetter[t3], o4: RowSetter[t4], o5: RowSetter[t5], o6: RowSetter[t6], o7: RowSetter[t7], o8: RowSetter[t8]): RowSetter[(t1, t2, t3, t4, t5, t6, t7, t8)]  =
        lift8((x1, x2, x3, x4, x5, x6, x7, x8) -> (x1, x2, x3, x4, x5, x6, x7, x8), o1, o2, o3, o4, o5, o6, o7, o8)

    ///
    /// Returns a 9 element tuple with the results of applying the parsers `o1`, `o2`, ... `o9`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o9` is an error.
    ///
    pub def tuple9(o1: RowSetter[t1], o2: RowSetter[t2], o3: RowSetter[t3], o4: RowSetter[t4], o5: RowSetter[t5], o6: RowSetter[t6], o7: RowSetter[t7], o8: RowSetter[t8], o9: RowSetter[t9]): RowSetter[(t1, t2, t3, t4, t5, t6, t7, t8, t9)]  =
        lift9((x1, x2, x3, x4, x5, x6, x7, x8, x9) -> (x1, x2, x3, x4, x5, x6, x7, x8, x9), o1, o2, o3, o4, o5, o6, o7, o8, o9)

    ///
    /// Returns a 10 element tuple with the results of applying the parsers `o1`, `o2`, ... `o10`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o10` is an error.
    ///
    pub def tuple10(o1: RowSetter[t1], o2: RowSetter[t2], o3: RowSetter[t3], o4: RowSetter[t4], o5: RowSetter[t5], o6: RowSetter[t6], o7: RowSetter[t7], o8: RowSetter[t8], o9: RowSetter[t9], o10: RowSetter[t10]): RowSetter[(t1, t2, t3, t4, t5, t6, t7, t8, t9, t10)]  =
        lift10((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10) -> (x1, x2, x3, x4, x5, x6, x7, x8, x9, x10), o1, o2, o3, o4, o5, o6, o7, o8, o9, o10)


    /// Alias for `seqRight`
    pub def *>(p1: RowSetter[a], p2: RowSetter[b]): RowSetter[b] = seqRight(p1, p2)

    /// Alias for `seqLeft`
    pub def <*(p1: RowSetter[a], p2: RowSetter[b]): RowSetter[a] = seqLeft(p1, p2)

    // Haskell's <$>
    pub def <&>(f: a -> b, p2: RowSetter[a]): RowSetter[b] =
        map(f, p2)

    pub def <&(x: b, p2: RowSetter[a]): RowSetter[b] =
        p2 *> return(x)

    /// Alias for `bind`
    pub def >>=(ma: RowSetter[a], k: a -> RowSetter[b]): RowSetter[b] = 
        bind(ma, k)

    /// Alias for `flatMap` (flipped `bind`)
    pub def =<<(k: a -> RowSetter[b], ma: RowSetter[a]): RowSetter[b] = 
        flatMap(k, ma)


    // Haskell's ap <*>
    pub def <*>(mf: RowSetter[a -> b], p2: RowSetter[a]): RowSetter[b] =
        ap(mf, p2)

    /// Alias for `kleisliLeft`
    pub def >=>(f1: a -> RowSetter[b], f2: b -> RowSetter[c]): a -> RowSetter[c] = 
        x -> kleisliLeft(f1, f2, x)

    /// Alias for `kleisliRight`
    pub def <=<(f1: b -> RowSetter[c], f2: a -> RowSetter[b]): a -> RowSetter[c] = 
        x -> kleisliRight(f1, f2, x)

}