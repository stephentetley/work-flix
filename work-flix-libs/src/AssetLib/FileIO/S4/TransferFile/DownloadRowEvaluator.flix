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

    pub enum DownloadRowEvaluator[r: Region, a: Type]((Map[String,Int32], Array[String, r]) -> Result[a, String])

    instance Functor[DownloadRowEvaluator[r]] { 
        pub def map(f: a -> b & ef, x: DownloadRowEvaluator[r, a]): DownloadRowEvaluator[r, b] & ef = 
            AssetLib/FileIO/S4/TransferFile/DownloadRowEvaluator.map(f, x)
    }

    instance Applicative[DownloadRowEvaluator[r]] { 
        pub def point(x: a): DownloadRowEvaluator[r, a] = 
            AssetLib/FileIO/S4/TransferFile/DownloadRowEvaluator.point(x)

        pub def ap(f: DownloadRowEvaluator[r, a -> b & ef], x: DownloadRowEvaluator[r, a]): DownloadRowEvaluator[r, b] & ef = 
            AssetLib/FileIO/S4/TransferFile/DownloadRowEvaluator.ap(f, x)
    }

    instance Monad[DownloadRowEvaluator[r]] { 
        pub def flatMap(k: a -> DownloadRowEvaluator[r, b] & ef, x: DownloadRowEvaluator[r, a]): DownloadRowEvaluator[r, b] & ef = 
            AssetLib/FileIO/S4/TransferFile/DownloadRowEvaluator.flatMap(k, x)
    }

}

namespace AssetLib/FileIO/S4/TransferFile/DownloadRowEvaluator {

    use FromString.fromString;

    use Time/Format.DateTimeFormatter;
    use Text/RegexEval.MatchEvaluator;

    use AssetLib/FileIO/S4/TransferFile.DownloadRowEvaluator;
    use AssetLib/FileIO/S4/TransferFile.DownloadRowEvaluator.{DownloadRowEvaluator};


    pub def evaluateString(r: Region[r], 
                            splitter: String -> Array[String, r] \ Write(r),
                            headers: Map[String, Int32],
                            input: String,
                            eval: DownloadRowEvaluator[r, a]): Result[a, String] \ { Read(r), Write(r) } =
        use Result.{flatMap};
        let arr = splitter(input);
        apply1(eval, headers, arr)

    pub def makeHeaders(names: List[String]): Map[String,Int32] =
        let step = (acc, x) -> { let (i, mx) = acc; (i + 1, Map.insert(x, i, mx)) };
        List.foldLeft(step, (0, Map.empty()), names) |> snd


    pub def point(x: a): DownloadRowEvaluator[r, a] =
        DownloadRowEvaluator((_,_) -> Ok(x))

    def apply1(x: DownloadRowEvaluator[r, a], indices: Map[String, Int32], row: Array[String, r]): Result[a, String] =
        let DownloadRowEvaluator(f) = x;
        f(indices, row)

    def getRegionOf(): DownloadRowEvaluator[r, Region[r]] = 
        DownloadRowEvaluator((_, row) -> Ok(Scoped.regionOf(row)))

    pub def throwError(msg: String): DownloadRowEvaluator[r, a] =
        DownloadRowEvaluator((_,_) -> Err(msg))

    pub def swapError(ma: DownloadRowEvaluator[r, a], msg: String): DownloadRowEvaluator[r, a] =
        DownloadRowEvaluator((ixs, row) ->
            match apply1(ma, ixs, row) {
                case Ok(a) => Ok(a)
                case Err(_) => Err(msg)
            }
        )

    pub def map(f: a -> b & ef, x: DownloadRowEvaluator[r, a]): DownloadRowEvaluator[r, b] & ef =
        DownloadRowEvaluator((ixs, row) ->
            match apply1(x, ixs, row) {
                case Ok(a) => {
                    let ans = f(a) as & Pure;
                    Ok(ans)
                }
                case Err(e) => Err(e)
            }
        ) as & ef

    pub def ap(mf: DownloadRowEvaluator[r, a -> b & ef], ma: DownloadRowEvaluator[r, a]): DownloadRowEvaluator[r, b] & ef =
        DownloadRowEvaluator((ixs, row) ->
            match apply1(mf, ixs, row) {
                case Ok(f) => {
                    match apply1(ma, ixs, row) {
                        case Ok(a) => Ok(f(a) as & Pure)
                        case Err(e2) => Err(e2)
                    }
                }
                case Err(e1) => Err(e1)
            }
        ) as & ef


    pub def bind(x: DownloadRowEvaluator[r, a], k: a -> DownloadRowEvaluator[r, b] & ef): DownloadRowEvaluator[r, b] & ef =
        DownloadRowEvaluator((ixs, row) ->
            match apply1(x, ixs, row) {
                case Ok(a) => apply1(k(a) as & Pure, ixs, row)
                case Err(e) => Err(e)
            }
        ) as & ef

    pub def flatMap(k: a -> DownloadRowEvaluator[r, b] & ef, x: DownloadRowEvaluator[r, a]): DownloadRowEvaluator[r, b] & ef = bind(x, k)


    pub def optional(x: DownloadRowEvaluator[r, a]): DownloadRowEvaluator[r, Option[a]] =
        DownloadRowEvaluator((ixs, row) ->
            match apply1(x, ixs, row) {
                case Ok(a) => Ok(Some(a))
                case Err(_) => Ok(None)
            }
        )

    pub def liftAction(fn: Unit -> a & ef): DownloadRowEvaluator[r, a] & ef =
        DownloadRowEvaluator((_, _) -> let x = fn() as & Pure; Ok(x)) as & ef

    pub def liftActionResult(fn: Unit -> Result[a, String] & ef): DownloadRowEvaluator[r, a] & ef =
        DownloadRowEvaluator((_,_) -> fn() as & Pure) as & ef


    pub def liftOption(x: Option[a],  errMsg: String): DownloadRowEvaluator[r, a] = match x { 
        case Some(x1) => point(x1)
        case None => throwError(errMsg)
    }
        

    pub def liftResult(x: Result[a, String]): DownloadRowEvaluator[r, a] =
        DownloadRowEvaluator((_,_) -> x)

    
    // Cell readers, by label only

    /// Note - answer is trimmed, use `getCell` if you need exact contents
    pub def getStringNamed(label: String): DownloadRowEvaluator[r, String] \ Read(r) =
        map(String.trim, getCell(label))

    pub def getCell(label: String): DownloadRowEvaluator[r, String] \ Read(r) =
        DownloadRowEvaluator((ixs, row) -> match Map.get(label, ixs) {
            case None => Err("getCell('${label}')")
            case Some(ix) => {
                if (ix >= 0 and ix < Array.length(row)) {
                    let s = Array.get(ix, row) as & Pure;
                    Ok(s)
                } else {
                    Err("getCell('${label}')")
                }
            }
        }) as \ Read(r)

    pub def evalMatchesNamed(label: String, patt: Text/Regex.Pattern, eval: MatchEvaluator[r, a]): DownloadRowEvaluator[r, a] \ Read(r) =
        let* input = getStringNamed(label);
        let* r    = getRegionOf();
        let* ans = liftActionResult(_ -> Text/RegexEval/Regex.matchAll(r, eval, patt, input));
        point(ans)

    pub def evalContainsNamed(label: String, patt: Text/Regex.Pattern, eval: MatchEvaluator[r, a]): DownloadRowEvaluator[r, a] \ Read(r) =
        let* input = getStringNamed(label);
        let* r    = getRegionOf();
        let* ans = liftActionResult(_ -> Text/RegexEval/Regex.firstSubmatch(r, eval, patt,input));
        point(ans)

    pub def getInt8Named(label: String): DownloadRowEvaluator[r, Int8] \ Read(r) =
        let* s = getStringNamed(label);
        liftOption(fromString(s): Option[Int8], "getInt8Named('${label}')")

    pub def getInt16Named(label: String): DownloadRowEvaluator[r, Int16] \ Read(r) =
        let* s = getStringNamed(label);
        liftOption(fromString(s): Option[Int16], "getInt16Named('${label}')")

    pub def getInt32Named(label: String): DownloadRowEvaluator[r, Int32] \ Read(r) =
        let* s = getStringNamed(label);
        liftOption(fromString(s): Option[Int32], "getInt32Named('${label}')")

    pub def getInt64Named(label: String): DownloadRowEvaluator[r, Int64] \ Read(r) =
        let* s = getStringNamed(label);
        liftOption(fromString(s): Option[Int64], "getInt64Named('${label}')")

    pub def getFloat32Named(label: String): DownloadRowEvaluator[r, Float32] \ Read(r) =
        let* s = getStringNamed(label);
        liftOption(fromString(s): Option[Float32], "getFloat32Named('${label}')")

    pub def getFloat64Named(label: String): DownloadRowEvaluator[r, Float64] \ Read(r) =
        let* s = getStringNamed(label);
        liftOption(fromString(s): Option[Float64], "getFloat64Named('${label}')")

    pub def getLocalDateNamed(label: String, formatter: DateTimeFormatter[Time/Format.DateFormat]): DownloadRowEvaluator[r, Time.LocalDate] \ Read(r) =
        let* input = getStringNamed(label);
        liftResult(Time/LocalDate.parse(formatter, input))

    pub def getLocalDateTimeNamed(label: String, formatter: DateTimeFormatter[Time/Format.DateTimeFormat]): DownloadRowEvaluator[r, Time.LocalDateTime] \ Read(r) =
        let* input = getStringNamed(label);
        liftResult(Time/LocalDateTime.parse(formatter, input))

    pub def getLocalTime(label: String, formatter: DateTimeFormatter[Time/Format.TimeFormat]): DownloadRowEvaluator[r, Time.LocalTime] \ Read(r) =
        let* input = getStringNamed(label);
        liftResult(Time/LocalTime.parse(formatter, input))

    pub def getS4DateNamed(label: String): DownloadRowEvaluator[r, Time.LocalDate] \ Read(r) =
        let* fmt = liftResult(Time/Format/DateTimeFormatter.fromPattern("dd.MM.yyyy"));
        getLocalDateNamed(label, fmt)

    pub def getS4BoolNamed(label: String): DownloadRowEvaluator[r, Bool] \ Read(r) =
        bind( getStringNamed(label)
            , x -> match x { 
                case ""     => point(false)
                case "X"    => point(true)
                case _      => throwError("getS4BoolNamed('${x}')")
            })

}
