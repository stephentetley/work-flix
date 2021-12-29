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



namespace AssetLib/FileIO/S4/TransferFile {

    pub opaque type UploadRowSetter[a] = (Map[String, Int32], Array[String]) -> Result[a, String] & Impure

    instance Functor[UploadRowSetter] { 
        pub def map(f: a -> b & ef, x: UploadRowSetter[a]): UploadRowSetter[b] & ef = 
            AssetLib/FileIO/S4/TransferFile/UploadRowSetter.map(f, x)
    }

    instance Applicative[UploadRowSetter] { 
        pub def point(x: a): UploadRowSetter[a] = 
            AssetLib/FileIO/S4/TransferFile/UploadRowSetter.point(x)

        pub def ap(f: UploadRowSetter[a -> b & ef], x: UploadRowSetter[a]): UploadRowSetter[b] & ef = 
            AssetLib/FileIO/S4/TransferFile/UploadRowSetter.ap(f, x)
    }

    instance Monad[UploadRowSetter] { 
        pub def flatMap(k: a -> UploadRowSetter[b] & ef, x: UploadRowSetter[a]): UploadRowSetter[b] & ef = 
            AssetLib/FileIO/S4/TransferFile/UploadRowSetter.flatMap(k, x)
    }
}

namespace AssetLib/FileIO/S4/TransferFile/UploadRowSetter {

    use ToString.toString;

    use AssetLib/FileIO/S4/TransferFile.UploadRowSetter;
    use AssetLib/FileIO/S4/TransferFile.UploadRowSetter.{UploadRowSetter};
    use AssetLib/FileIO/S4/TransferFile/Datatypes.{DataRow};

    /// size must equal Map.size(indices), it is supplied rather than calculated as this function is 
    /// intended to be used in a loop...
    pub def runUploadRowSetter(indices: Map[String, Int32],
                         size: Int32,
                         action: UploadRowSetter[a]): Result[(a, DataRow), String] & Impure =
        use Result.{flatMap};
        let arr = Array.new("", size);
        let* ans = apply1(action, indices, arr);
        Ok((ans, arr))

    /// size must equal Map.size(indices), it is supplied rather than calculated as this function is 
    /// intended to be used in a loop... 
    pub def execUploadRowSetter(indices: Map[String, Int32],
                          size: Int32,
                          action: UploadRowSetter[a]): Result[DataRow, String] & Impure =
        use Result.{flatMap};
        let* (_, arr) = runUploadRowSetter(indices, size, action);
        Ok(arr)

    pub def makeIndices(headers: Array[String]): Map[String,Int32] & Impure =
        let step = (acc, x) -> { let (i, mx) = acc; (i + 1, Map.insert(x, i, mx)) };
        Array.foldLeft(step, (0, Map.empty()), headers) |> snd


    pub def point(x: a): UploadRowSetter[a] =
        UploadRowSetter((_,_) -> Ok(x) as & Impure)

    def apply1(x: UploadRowSetter[a], indices: Map[String, Int32], row: Array[String]): Result[a, String] & Impure =
        let UploadRowSetter(f) = x;
        f(indices, row)

    pub def throwError(msg: String): UploadRowSetter[a] =
        UploadRowSetter((_,_) -> Err(msg) as & Impure)

    pub def swapError(ma: UploadRowSetter[a], msg: String): UploadRowSetter[a] =
        UploadRowSetter((ixs, row) ->
            match apply1(ma, ixs, row) {
                case Ok(a) => Ok(a)
                case Err(_) => Err(msg)
            }
        )

    pub def map(f: a -> b & ef, x: UploadRowSetter[a]): UploadRowSetter[b] & ef =
        UploadRowSetter((ixs, row) ->
            match apply1(x, ixs, row) {
                case Ok(a) => {
                    let ans = f(a) as & Impure;
                    Ok(ans)
                }
                case Err(e) => Err(e)
            }
        ) as & ef

    pub def ap(mf: UploadRowSetter[a -> b & ef], ma: UploadRowSetter[a]): UploadRowSetter[b] & ef =
        UploadRowSetter((ixs, row) ->
            match apply1(mf, ixs, row) {
                case Ok(f) => {
                    match apply1(ma, ixs, row) {
                        case Ok(a) => Ok(f(a) as & Impure)
                        case Err(e2) => Err(e2)
                    }
                }
                case Err(e1) => Err(e1)
            }
        ) as & ef


    pub def bind(x: UploadRowSetter[a], k: a -> UploadRowSetter[b] & ef): UploadRowSetter[b] & ef=
        UploadRowSetter((ixs, row) ->
            match apply1(x, ixs, row) {
                case Ok(a) => apply1(k(a), ixs, row)
                case Err(e) => Err(e)
            }
        ) as & ef

    pub def flatMap(k: a -> UploadRowSetter[b] & ef, x: UploadRowSetter[a]): UploadRowSetter[b] & ef = bind(x, k)


    pub def optional(x: UploadRowSetter[a]): UploadRowSetter[Option[a]] =
        UploadRowSetter((ixs, row) ->
            match apply1(x, ixs, row) {
                case Ok(a) => Ok(Some(a))
                case Err(_) => Ok(None)
            }
        )

    pub def liftAction(fn: Unit -> a & Impure): UploadRowSetter[a] =
        UploadRowSetter((_, _) -> let x = fn(); Ok(x))

    pub def liftOption(x: Option[a],  errMsg: String): UploadRowSetter[a] = match x { 
        case Some(x1) => point(x1)
        case None => throwError(errMsg)
    }
        

    pub def liftResult(x: Result[a, String]): UploadRowSetter[a] =
        UploadRowSetter((_,_) -> x as & Impure)

    pub def liftActionResult(fn: Unit -> Result[a, String] & Impure): UploadRowSetter[a] =
        UploadRowSetter((_,_) -> fn())

    // Cell setters, by label only

    /// 
    pub def putStringNamed!(label: String, x: String): UploadRowSetter[Unit] =
        UploadRowSetter((ixs, row) -> match Map.get(label, ixs) {
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


    pub def putInt8Named!(label: String, x: Int8): UploadRowSetter[Unit] =
        putStringNamed!(label, toString(x)) `swapError` "putInt8Named!('${label}')"

    pub def putInt16Named!(label: String, x: Int16): UploadRowSetter[Unit] =
        putStringNamed!(label, toString(x)) `swapError` "putInt16Named!('${label}')"

    pub def putInt32Named!(label: String, x: Int32): UploadRowSetter[Unit] =
        putStringNamed!(label, toString(x)) `swapError` "putInt32Named!('${label}')"

    pub def putInt64Named!(label: String, x: Int64): UploadRowSetter[Unit] =
        putStringNamed!(label, toString(x)) `swapError` "putInt64Named!('${label}')"

    pub def putFloat32Named!(label: String, x: Float32): UploadRowSetter[Unit] =
        putStringNamed!(label, toString(x)) `swapError` "putFloat32Named!('${label}')"

    pub def putFloat64Named!(label: String, x: Float64): UploadRowSetter[Unit] =
        putStringNamed!(label, toString(x)) `swapError` "putFloat64Named!('${label}')"

    pub def putS4DateNamed!(label: String, x: Time.LocalDate): UploadRowSetter[Unit] =
        let* fmt = liftOption(Time/Format/DateFormatter.ofPattern("dd.MM.yyyy"), "putS4DateNamed!('${label}')");
        putStringNamed!(label, Time/LocalDate.format(fmt, x)) `swapError` "putS4DateNamed!('${label}')"

    pub def putS4BoolNamed!(label: String, x: Bool): UploadRowSetter[Unit] = 
        if (x) 
            putStringNamed!(label, "X")
        else 
            putStringNamed!(label, "")

    /// Pads from left with '0'
    pub def putPaddedInt32Named!(label: String, width: Int32, x: Int32): UploadRowSetter[Unit] =
        putStringNamed!(label, String.padLeft(width, '0', toString(x))) `swapError` "putInt32Named!('${label}')"
    ///
    /// Applies the binary function `f` to the values in `o1` and `o2`.
    ///
    /// Returns an error if either `o1` or `o2` are errors.
    ///
    pub def lift2(f: (t1, t2) -> u & ef, 
                    o1: UploadRowSetter[t1],
                    o2: UploadRowSetter[t2]): UploadRowSetter[u] & ef =
        ap(map(f, o1), o2)

    ///
    /// Applies the ternary function `f` to the values in `o1`, `o2` and `o3`.
    ///
    /// Returns an error if any of `o1`, `o2` and `o3` are errors.
    ///
    pub def lift3(f: (t1, t2, t3) -> u & ef, 
                    o1: UploadRowSetter[t1], 
                    o2: UploadRowSetter[t2],
                    o3: UploadRowSetter[t3]): UploadRowSetter[u] & ef =
        ap(lift2(f, o1, o2), o3)

    ///
    /// Applies the 4-ary function `f` to the values in `o1`, `o2`, `o3` and `o4`.
    ///
    /// Returns an error if any of `o1`, `o2`, `o3` and `o4` are errors.
    ///
    pub def lift4(f: (t1, t2, t3, t4) -> u & ef,
                    o1: UploadRowSetter[t1],
                    o2: UploadRowSetter[t2],
                    o3: UploadRowSetter[t3],
                    o4: UploadRowSetter[t4]): UploadRowSetter[u] & ef =
        ap(lift3(f, o1, o2, o3), o4)

    ///
    /// Applies the 5-ary function `f` to the values in `o1`, `o2`, ... `o5`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o5` are errors.
    ///
    pub def lift5(f: (t1, t2, t3, t4, t5) -> u & ef,
                    o1: UploadRowSetter[t1],
                    o2: UploadRowSetter[t2],
                    o3: UploadRowSetter[t3],
                    o4: UploadRowSetter[t4],
                    o5: UploadRowSetter[t5]): UploadRowSetter[u] & ef =
        ap(lift4(f, o1, o2, o3, o4), o5)

    ///
    /// Applies the 6-ary function `f` to the values in `o1`, `o2`, ... `o6`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o6` are errors.
    ///
    pub def lift6(f: (t1, t2, t3, t4, t5, t6) -> u & ef,
                    o1: UploadRowSetter[t1], 
                    o2: UploadRowSetter[t2],
                    o3: UploadRowSetter[t3],
                    o4: UploadRowSetter[t4],
                    o5: UploadRowSetter[t5],
                    o6: UploadRowSetter[t6]): UploadRowSetter[u] & ef =
        ap(lift5(f, o1, o2, o3, o4, o5), o6)

    ///
    /// Applies the 7-ary function `f` to the values in `o1`, `o2`, ... `o7`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o7` are errors.
    ///
    pub def lift7(f: (t1, t2, t3, t4, t5, t6, t7) -> u & ef,
                    o1: UploadRowSetter[t1],
                    o2: UploadRowSetter[t2],
                    o3: UploadRowSetter[t3],
                    o4: UploadRowSetter[t4],
                    o5: UploadRowSetter[t5],
                    o6: UploadRowSetter[t6],
                    o7: UploadRowSetter[t7]): UploadRowSetter[u] & ef =
        ap(lift6(f, o1, o2, o3, o4, o5, o6), o7)

    ///
    /// Applies the 8-ary function `f` to the values in `o1`, `o2`, ... `o8`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o8` are errors.
    ///
    pub def lift8(f: (t1, t2, t3, t4, t5, t6, t7, t8) -> u & ef,
                    o1: UploadRowSetter[t1],
                    o2: UploadRowSetter[t2],
                    o3: UploadRowSetter[t3],
                    o4: UploadRowSetter[t4],
                    o5: UploadRowSetter[t5],
                    o6: UploadRowSetter[t6],
                    o7: UploadRowSetter[t7],
                    o8: UploadRowSetter[t8]): UploadRowSetter[u] & ef =
        ap(lift7(f, o1, o2, o3, o4, o5, o6, o7), o8)

    ///
    /// Applies the 9-ary function `f` to the values in `o1`, `o2`, ... `o9`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o9` are errors.
    ///
    pub def lift9(f: (t1, t2, t3, t4, t5, t6, t7, t8, t9) -> u & ef, 
                    o1: UploadRowSetter[t1],
                    o2: UploadRowSetter[t2],
                    o3: UploadRowSetter[t3],
                    o4: UploadRowSetter[t4],
                    o5: UploadRowSetter[t5],
                    o6: UploadRowSetter[t6],
                    o7: UploadRowSetter[t7],
                    o8: UploadRowSetter[t8],
                    o9: UploadRowSetter[t9]): UploadRowSetter[u] & ef =
        ap(lift8(f, o1, o2, o3, o4, o5, o6, o7, o8), o9)

    ///
    /// Applies the 10-ary function `f` to the values in `o1`, `o2`, ... `o10`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o10` are errors.
    ///
    pub def lift10(f: (t1, t2, t3, t4, t5, t6, t7, t8, t9, t10) -> u & ef,
                    o1: UploadRowSetter[t1],
                    o2: UploadRowSetter[t2],
                    o3: UploadRowSetter[t3],
                    o4: UploadRowSetter[t4],
                    o5: UploadRowSetter[t5],
                    o6: UploadRowSetter[t6],
                    o7: UploadRowSetter[t7],
                    o8: UploadRowSetter[t8],
                    o9: UploadRowSetter[t9],
                    o10: UploadRowSetter[t10]): UploadRowSetter[u] & ef =
        ap(lift9(f, o1, o2, o3, o4, o5, o6, o7, o8, o9), o10)

    ///
    /// Returns a 2 element tuple with the results of applying the parsers `o1` and `o2`.
    ///
    /// Returns an error if evaluating either `o1` or `o2` is an error.
    ///
    pub def tuple2(o1: UploadRowSetter[t1], o2: UploadRowSetter[t2]): UploadRowSetter[(t1, t2)] =
        lift2((x,y) -> (x,y), o1, o2)

    ///
    /// Returns a 3 element tuple with the results of applying the parsers `o1`, `o2` and `o3`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2` and `o3` is an error.
    ///
    pub def tuple3(o1: UploadRowSetter[t1], o2: UploadRowSetter[t2], o3: UploadRowSetter[t3]): UploadRowSetter[(t1, t2, t3)] =
        lift3((x1, x2, x3) -> (x1, x2, x3), o1, o2, o3)

    ///
    /// Returns a 4 element tuple with the results of applying the parsers `o1`, `o2`, `o3` and `o4`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, `o3` and `o4` is an error.
    ///
    pub def tuple4(o1: UploadRowSetter[t1], o2: UploadRowSetter[t2], o3: UploadRowSetter[t3], o4: UploadRowSetter[t4]): UploadRowSetter[(t1, t2, t3, t4)]  =
        lift4((x1, x2, x3, x4) -> (x1, x2, x3, x4), o1, o2, o3, o4)

    ///
    /// Returns a 5 element tuple with the results of applying the parsers `o1`, `o2`, ... `o5`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o5` is an error.
    ///
    pub def tuple5(o1: UploadRowSetter[t1], o2: UploadRowSetter[t2], o3: UploadRowSetter[t3], o4: UploadRowSetter[t4], o5: UploadRowSetter[t5]): UploadRowSetter[(t1, t2, t3, t4, t5)]  =
        lift5((x1, x2, x3, x4, x5) -> (x1, x2, x3, x4, x5), o1, o2, o3, o4, o5)

    ///
    /// Returns a 6 element tuple with the results of applying the parsers `o1`, `o2`, ... `o6`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o6` is an error.
    ///
    pub def tuple6(o1: UploadRowSetter[t1], o2: UploadRowSetter[t2], o3: UploadRowSetter[t3], o4: UploadRowSetter[t4], o5: UploadRowSetter[t5], o6: UploadRowSetter[t6]): UploadRowSetter[(t1, t2, t3, t4, t5, t6)]  =
        lift6((x1, x2, x3, x4, x5, x6) -> (x1, x2, x3, x4, x5, x6), o1, o2, o3, o4, o5, o6)

    ///
    /// Returns a 7 element tuple with the results of applying the parsers `o1`, `o2`, ... `o7`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o7` is an error.
    ///
    pub def tuple7(o1: UploadRowSetter[t1], o2: UploadRowSetter[t2], o3: UploadRowSetter[t3], o4: UploadRowSetter[t4], o5: UploadRowSetter[t5], o6: UploadRowSetter[t6], o7: UploadRowSetter[t7]): UploadRowSetter[(t1, t2, t3, t4, t5, t6, t7)]  =
        lift7((x1, x2, x3, x4, x5, x6, x7) -> (x1, x2, x3, x4, x5, x6, x7), o1, o2, o3, o4, o5, o6, o7)

    ///
    /// Returns a 8 element tuple with the results of applying the parsers `o1`, `o2`, ... `o8`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o8` is an error.
    ///
    pub def tuple8(o1: UploadRowSetter[t1], o2: UploadRowSetter[t2], o3: UploadRowSetter[t3], o4: UploadRowSetter[t4], o5: UploadRowSetter[t5], o6: UploadRowSetter[t6], o7: UploadRowSetter[t7], o8: UploadRowSetter[t8]): UploadRowSetter[(t1, t2, t3, t4, t5, t6, t7, t8)]  =
        lift8((x1, x2, x3, x4, x5, x6, x7, x8) -> (x1, x2, x3, x4, x5, x6, x7, x8), o1, o2, o3, o4, o5, o6, o7, o8)

    ///
    /// Returns a 9 element tuple with the results of applying the parsers `o1`, `o2`, ... `o9`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o9` is an error.
    ///
    pub def tuple9(o1: UploadRowSetter[t1], o2: UploadRowSetter[t2], o3: UploadRowSetter[t3], o4: UploadRowSetter[t4], o5: UploadRowSetter[t5], o6: UploadRowSetter[t6], o7: UploadRowSetter[t7], o8: UploadRowSetter[t8], o9: UploadRowSetter[t9]): UploadRowSetter[(t1, t2, t3, t4, t5, t6, t7, t8, t9)]  =
        lift9((x1, x2, x3, x4, x5, x6, x7, x8, x9) -> (x1, x2, x3, x4, x5, x6, x7, x8, x9), o1, o2, o3, o4, o5, o6, o7, o8, o9)

    ///
    /// Returns a 10 element tuple with the results of applying the parsers `o1`, `o2`, ... `o10`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o10` is an error.
    ///
    pub def tuple10(o1: UploadRowSetter[t1], o2: UploadRowSetter[t2], o3: UploadRowSetter[t3], o4: UploadRowSetter[t4], o5: UploadRowSetter[t5], o6: UploadRowSetter[t6], o7: UploadRowSetter[t7], o8: UploadRowSetter[t8], o9: UploadRowSetter[t9], o10: UploadRowSetter[t10]): UploadRowSetter[(t1, t2, t3, t4, t5, t6, t7, t8, t9, t10)]  =
        lift10((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10) -> (x1, x2, x3, x4, x5, x6, x7, x8, x9, x10), o1, o2, o3, o4, o5, o6, o7, o8, o9, o10)

}