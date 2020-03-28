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


namespace Common/Utils {



    /// 
    /// Get a year from a date string that includes "YYYY".
    ///
    /// The year "YYYY" must be the only four digit sequence in the input.
    ///
    pub def getYear(s: String): Result[Int32, String] = 
        getYearHelper(s) as & Pure

    /// 
    /// Helper function for `getYear`.
    ///
    def getYearHelper(s: String): Result[Int32, String] & Impure = 
        let patt = Regex.compile("(?<year>\d{4})");
        let m = Regex.matcher(patt, s);
        if (Regex.find(m)) {
            Regex.namedGroup(m, "year") |> Int32.fromString
        } else Err("read year")


    // pub def apR(rf: Result[a -> b & f, e], r: Result[a, e]) : Result[b, e] & f = 
    //     match rf { 
    //         case Err(x) => Err(x)
    //         case Ok(f) => match r {
    //             case Err(x) => Err(x)
    //             case Ok(a) => Ok(f(a))
    //         }
    //     }

    // pub def liftR2(fn: (t1,t2) -> t3 & f, r1: Result[t1, e], r2: Result[t2, e]): Result[t3, e] & f =
    //     apR(Result.map(fn, r1), r2)

    // pub def liftR3(fn: (t1,t2,t3) -> t4 & f, r1: Result[t1, e], r2: Result[t2, e], r3: Result[t3, e]): Result[t4, e] & f =
    //     apR(liftR2(fn, r1, r2), r3)

    // pub def liftR4(f: (t1,t2,t3,t4) -> t5 & f, r1: Result[t1, e], r2: Result[t2, e], r3: Result[t3, e], r4: Result[t4, e]): Result[t5, e] & f=
    //     apR(liftR3(f, r1, r2, r3), r4)

    // pub def liftR5(f: (t1,t2,t3,t4,t5) -> t6 & f, r1: Result[t1, e], r2: Result[t2, e], r3: Result[t3, e], r4: Result[t4, e], r5: Result[t5, e]): Result[t6, e] & f=
    //     apR(liftR4(f, r1, r2, r3, r4), r5)

    // pub def liftR6(f: (t1,t2,t3,t4,t5,t6) -> t7 & f, r1: Result[t1, e], r2: Result[t2, e], r3: Result[t3, e], r4: Result[t4, e], r5: Result[t5, e], r6: Result[t6, e]): Result[t7, e] & f=
    //     apR(liftR5(f, r1, r2, r3, r4, r5), r6)

    // pub def liftR7(f: (t1,t2,t3,t4,t5,t6,t7) -> t8 & f, r1: Result[t1, e], r2: Result[t2, e], r3: Result[t3, e], r4: Result[t4, e], r5: Result[t5, e], r6: Result[t6, e], r7: Result[t7, e]): Result[t8, e] & f=
    //     apR(liftR6(f, r1, r2, r3, r4, r5, r6), r7)

    // pub def pipeR2(r1: Result[t1, e], r2: Result[t2, e], fn: (t1,t2) -> t3 & f): Result[t3, e] & f =
    //     liftR2(fn, r1, r2)

    // pub def pipeR3(r1: Result[t1, e], r2: Result[t2, e], r3: Result[t3, e], f: (t1,t2,t3) -> t4 & f): Result[t4, e] & f=
    //     liftR3(f, r1, r2, r3)

    // pub def pipeR4(r1: Result[t1, e], r2: Result[t2, e], r3: Result[t3, e], r4: Result[t4, e], f: (t1,t2,t3,t4) -> t5 & f): Result[t5, e] & f=
    //     liftR4(f, r1, r2, r3, r4)
    
    // pub def pipeR5(r1: Result[t1, e], r2: Result[t2, e], r3: Result[t3, e], r4: Result[t4, e], r5: Result[t5, e], f: (t1,t2,t3,t4,t5) -> t6 & f): Result[t6, e] & f=
    //     liftR5(f, r1, r2, r3, r4, r5)
    
    // pub def pipeR6(r1: Result[t1, e], r2: Result[t2, e], r3: Result[t3, e], r4: Result[t4, e], r5: Result[t5, e], r6: Result[t6, e], f: (t1,t2,t3,t4,t5,t6) -> t7 & f): Result[t7, e] & f=
    //     liftR6(f, r1, r2, r3, r4, r5, r6)

    // pub def pipeR7(r1: Result[t1, e], r2: Result[t2, e], r3: Result[t3, e], r4: Result[t4, e], r5: Result[t5, e], r6: Result[t6, e], r7: Result[t7, e], f: (t1,t2,t3,t4,t5,t6,t7) -> t8 & f): Result[t8, e] & f=
    //     liftR7(f, r1, r2, r3, r4, r5, r6, r7)

}