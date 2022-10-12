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


namespace AssetDS/ZTable {

    /// The LHS is generally between 2 and 4 cells wide, Array not really necessary...

    // pub enum RowEvaluator[r: Region, a: Type](Array[String, r] -> Result[a, String])

    pub enum RowEvaluator[r: Region, ka: Type, a: Type](MonadLib.Evaluator[r, ka, Array[String, r], a])


    instance Functor[RowEvaluator[r, ka]] { 
        pub def map(f: a -> b \ ef, x: RowEvaluator[r, ka, a]): RowEvaluator[r, ka, b] \ ef = 
            AssetDS/ZTable/RowEvaluator.map(f, x)
    }

    instance Applicative[RowEvaluator[r, ka]] { 
        pub def point(x: a): RowEvaluator[r, ka, a] = 
            AssetDS/ZTable/RowEvaluator.point(x)

        pub def ap(f: RowEvaluator[r, ka, a -> b \ ef], x: RowEvaluator[r, ka, a]): RowEvaluator[r, ka, b] \ ef = 
            AssetDS/ZTable/RowEvaluator.ap(f, x)
    }

    instance Monad[RowEvaluator[r, ka]] { 
        pub def flatMap(k: a -> RowEvaluator[r, ka, b] \ ef, x: RowEvaluator[r, ka, a]): RowEvaluator[r, ka, b] \ ef = 
            AssetDS/ZTable/RowEvaluator.flatMap(k, x)
    }

    instance MonadZero[RowEvaluator[r, ka]] {
        pub def empty(): RowEvaluator[r, ka, a] = 
            AssetDS/ZTable/RowEvaluator.empty()
    }

    instance MonadLib.MonadOr[RowEvaluator[r, ka]] {
        pub def orelse(a: RowEvaluator[r, ka, a], b: RowEvaluator[r, ka, a]): RowEvaluator[r, ka, a] =
            AssetDS/ZTable/RowEvaluator.orelse(a, b)
    }

    instance MonadLib.MonadError[RowEvaluator[r, ka]] { 
        pub def throwError(msg: String): RowEvaluator[r, ka, a] =
            AssetDS/ZTable/RowEvaluator.throwError(msg)

        pub def mapError(f: String -> String \ ef, ma: RowEvaluator[r, ka, a]): RowEvaluator[r, ka, a] \ ef = 
            AssetDS/ZTable/RowEvaluator.mapError(f, ma)

        pub def catchError(ma: RowEvaluator[r, ka, a], hdlr: String -> RowEvaluator[r, ka, a] \ ef): RowEvaluator[r, ka, a] \ ef = 
            AssetDS/ZTable/RowEvaluator.catchError(ma, hdlr)
    }  

}

namespace AssetDS/ZTable/RowEvaluator {

    use FromString.fromString;

    use Time/Format.DateTimeFormatter;
    
    use Text/RegexEval.MatchEvaluator;

    use AssetDS/ZTable.RowEvaluator;
    use AssetDS/ZTable.RowEvaluator.{RowEvaluator};


    
    pub def getRowEvaluator(x: RowEvaluator[r, ka, a]): MonadLib.Evaluator[r, ka, Array[String, r], a] = 
        let RowEvaluator(x1) = x;
        x1


    pub def runRowEvaluator(r: Region[r], 
                                ma: RowEvaluator[r, a, a], 
                                st: Array[String, r]): Result[a, String] \ r =
        MonadLib/Evaluator.runEvaluator(r, getRowEvaluator(ma), st)

    pub def evaluateString(r: Region[r], 
                            splitter: String -> Array[String, r] \ Write(r),
                            input: String,
                            eval: RowEvaluator[r, a, a]): Result[a, String] \ Write(r) =
        splitter(input) |> runRowEvaluator(r, eval)


    pub def point(x: a): RowEvaluator[r, ka, a] = RowEvaluator(MonadLib/Evaluator.point(x))


    pub def map(f: a -> b \ ef, x: RowEvaluator[r, ka, a]): RowEvaluator[r, ka, b] \ ef =
        RowEvaluator(MonadLib/Evaluator.map(f, getRowEvaluator(x)))

    pub def ap(mf: RowEvaluator[r, ka, a -> b \ ef], ma: RowEvaluator[r, ka, a]): RowEvaluator[r, ka, b] \ ef =
        RowEvaluator(MonadLib/Evaluator.ap(getRowEvaluator(mf), getRowEvaluator(ma)))

    
    pub def flatMap(k: a -> RowEvaluator[r, ka, b] \ ef, x: RowEvaluator[r, ka, a]): RowEvaluator[r, ka, b] \ ef =
        RowEvaluator(MonadLib/Evaluator.flatMap(k >> getRowEvaluator, getRowEvaluator(x)))

    pub def throwError(msg: String): RowEvaluator[r, ka, a] = 
        RowEvaluator(MonadLib/Evaluator.throwError(msg))
  
    // RowEvaluator can be MonadOr because it does not "step".
    // It is only runs on the current row.

    pub def empty(): RowEvaluator[r, ka, a] = throwError("empty")

    pub def orelse(ma: RowEvaluator[r, ka, a], mb: RowEvaluator[r, ka, a]): RowEvaluator[r, ka, a] =
        RowEvaluator(MonadLib/Evaluator.orelse(getRowEvaluator(ma), getRowEvaluator(mb)))


    pub def mapError(f: String -> String \ ef, ma: RowEvaluator[r, ka, a]): RowEvaluator[r, ka, a] \ ef = 
        RowEvaluator(MonadLib/Evaluator.mapError(f, getRowEvaluator(ma)))

    pub def catchError(ma: RowEvaluator[r, ka, a], hdlr: String -> RowEvaluator[r, ka, a] \ ef): RowEvaluator[r, ka, a] \ ef = 
        RowEvaluator(MonadLib/Evaluator.catchError(getRowEvaluator(ma), hdlr >> getRowEvaluator))


    pub def liftAction(f: Unit -> a \ ef): RowEvaluator[r, ka, a] \ ef =
        RowEvaluator(MonadLib/Evaluator.liftAction(f))
    
        
    pub def liftActionResult(f: Unit -> Result[a, err] \ ef): RowEvaluator[r, ka, a] \ ef with ToString[err] =
        RowEvaluator(MonadLib/Evaluator.liftActionResult(f))

    // def liftGetter(f: Array[String, r] -> a \ ef): RowEvaluator[r, ka, a] \ ef =
    //     RowEvaluator(MonadLib/Evaluator.liftGetter(f))

    def liftGetterResult(f: Array[String, r] -> Result[a, err] \ ef): RowEvaluator[r, ka, a] \ ef with ToString[err] =
        RowEvaluator(MonadLib/Evaluator.liftGetterResult(f))


    // Cell readers, by index only

    /// Note - answer is trimmed, use `getCell` if you need exact contents
    pub def getStringAt(ix: Int32): RowEvaluator[r, ka, String] \ Read(r) =
        map(String.trim, getCell(ix))

    pub def getCell(ix: Int32): RowEvaluator[r, ka, String] \ Read(r) =
        liftGetterResult(row ->
            if (ix >= 0 and ix < Array.length(row)) {
                let s = row[ix];
                Ok(s)
            } else {
                Err("getCell(${Int32.toString(ix)})")
            } 
        )


    pub def evalMatchesAt(ix: Int32, patt: Text/Regex.Pattern, eval: MatchEvaluator[r, a, a]): RowEvaluator[r, ka, a] \ Read(r) =
        let* input  = getStringAt(ix);
        let r1      = () as Region[r];
        liftActionResult(_ -> Text/RegexEval/Regex.matchAll(r1, eval, patt, input))

    pub def evalContainsAt(ix: Int32, patt: Text/Regex.Pattern, eval: MatchEvaluator[r, a, a]): RowEvaluator[r, ka, a] \ Read(r) =
        let* input  = getStringAt(ix);
        let r1      = () as Region[r];
        liftActionResult(_ -> Text/RegexEval/Regex.firstSubmatch(r1, eval, patt, input))

    pub def getInt8At(ix: Int32): RowEvaluator[r, ka, Int8] \ Read(r) =
        let* s = getStringAt(ix);
        MonadLib/MonadError.liftOption("getInt8At(${ix})", fromString(s))

    pub def getInt16At(ix: Int32): RowEvaluator[r, ka, Int16] \ Read(r) =
        let* s = getStringAt(ix);
        MonadLib/MonadError.liftOption("getInt16At(${ix})", fromString(s))

    pub def getInt32At(ix: Int32): RowEvaluator[r, ka, Int32] \ Read(r) =
        let* s = getStringAt(ix);
        MonadLib/MonadError.liftOption("getInt32At(${ix})", fromString(s))

    pub def getInt64At(ix: Int32): RowEvaluator[r, ka, Int64] \ Read(r) =
        let* s = getStringAt(ix);
        MonadLib/MonadError.liftOption("getInt64At(${ix})", fromString(s))

    pub def getFloat32At(ix: Int32): RowEvaluator[r, ka, Float32] \ Read(r) =
        let* s = getStringAt(ix);
        MonadLib/MonadError.liftOption("getFloat32At(${ix})", fromString(s))

    pub def getFloat64At(ix: Int32): RowEvaluator[r, ka, Float64] \ Read(r) =
        let* s = getStringAt(ix);
        MonadLib/MonadError.liftOption("getFloat64At('${ix})", fromString(s))

    pub def getLocalDateAt(ix: Int32, formatter: DateTimeFormatter[Time/Format.DateFormat]): RowEvaluator[r, ka, Time.LocalDate] \ Read(r) =
        let* input = getStringAt(ix);
        MonadLib/MonadError.liftResult(Time/LocalDate.parse(formatter, input))


    pub def getLocalDateTimeAt(ix: Int32, formatter: DateTimeFormatter[Time/Format.DateTimeFormat]): RowEvaluator[r, ka, Time.LocalDateTime] \ Read(r) =
        let* input = getStringAt(ix);
        MonadLib/MonadError.liftResult(Time/LocalDateTime.parse(formatter, input))


    pub def getLocalTimeAt(ix: Int32, formatter: DateTimeFormatter[Time/Format.TimeFormat]): RowEvaluator[r, ka, Time.LocalTime] \ Read(r) =
        let* input = getStringAt(ix);
        MonadLib/MonadError.liftResult(Time/LocalTime.parse(formatter, input))



}