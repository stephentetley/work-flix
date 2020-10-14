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


namespace AutoLifting {

    /// Assumption - needs name supply for UXL?

    pub opaque type ReportMonad[a] = Int32 ~> Result[(Int32, a), System.Error]

}


namespace AutoLifting/ReportMonad {

    use AutoLifting.ReportMonad;
    use AutoLifting.ReportMonad.{ReportMonad};

    pub def runReportMonad(ma: ReportMonad[a]): Result[a, System.Error] & Impure = 
        let n1 = initEquiNumber();
        Result.map(snd, apply1(ma, n1))


    def initEquiNumber(): Int32 & Impure = 
        use Time/LocalDateTime.{now, getDayOfMonth, getHour, getMinute};
        let dt = now();
        let x1 = getDayOfMonth(dt) * 10_000_000;
        let x2 = getHour(dt) * 100_000;
        let x3 = getMinute(dt) * 1_000;
        x1 + x2 + x3


    pub def return(x: a): ReportMonad[a] =
        ReportMonad(s -> Ok((s, x)) as & Impure)

    pub def throwError(msg: String): ReportMonad[a] =
        ReportMonad(_ -> Err(System/Error.Generic(msg)) as & Impure)        

    def apply1(x: ReportMonad[a], s: Int32): Result[(Int32, a), System.Error] & Impure =
        let ReportMonad(f) = x;
        f(s)

    pub def map(f: a -> b & ef, x: ReportMonad[a]): ReportMonad[b] =
        ReportMonad(s ->
            match apply1(x, s) {
                case Ok((s1, a)) => {
                    let ans = f(a) as & Impure;
                    Ok((s1, ans))
                }
                case Err(e) => Err(e)
            }
        )

    pub def ap(mf: ReportMonad[a -> b & ef], ma: ReportMonad[a]): ReportMonad[b] =
        ReportMonad(s ->
            match apply1(mf, s) {
                case Ok((s1, f)) => {
                    match apply1(ma, s1) {
                        case Ok((s2, a)) => Ok((s2, f(a) as & Impure))
                        case Err(e2) => Err(e2)
                    }
                }
                case Err(e1) => Err(e1)
            }
        )

    pub def bind(x: ReportMonad[a], k: a -> ReportMonad[b]): ReportMonad[b] =
        ReportMonad(s ->
            match apply1(x, s) {
                case Ok((s1, a)) => { let ans = k(a); apply1(ans, s1) }
                case Err(e) => Err(e)
            }
        )

    pub def flatMap(k: a -> ReportMonad[b], x: ReportMonad[a]): ReportMonad[b] = bind(x, k)

    pub def liftAction(fn: Unit ~> a): ReportMonad[a] =
        ReportMonad(s -> 
            let a = fn(); 
            Ok((s, a)) 
        )

    pub def liftActionResult(fn: Unit ~> Result[a, System.Error]): ReportMonad[a] =
        ReportMonad(s -> match fn() {
            case Ok(a) => Ok((s, a))
            case Err(e) => Err(e)
        })


    pub def mapM(mf: a -> ReportMonad[b], xs: List[a]): ReportMonad[List[b]] =
        ReportMonad(s ->
            mapMHelper(mf, s, xs, e -> Err(e), (s1, ys) -> Ok((s1, ys)))
        )

    ///
    /// Helper function for `mapM`.
    ///
    def mapMHelper(mf: a -> ReportMonad[b], 
                   s: Int32, 
                   xs: List[a], 
                   fk: System.Error -> Result[(Int32, List[b]), System.Error], 
                   sk: (Int32, List[b]) -> Result[(Int32, List[b]), System.Error]): Result[(Int32, List[b]), System.Error] & Impure =
        match xs {
            case Nil => sk(s, Nil)
            case x :: rs => {
                let ma = mf(x);
                match apply1(ma, s) {
                    case Err(e) => fk(e)
                    case Ok((s1, x1)) => mapMHelper(mf, s1, rs, fk, (s2, ks) -> sk(s2, x1 :: ks))
                }
            }
        }


    pub def mapX(mf: a -> ReportMonad[b], xs: List[a]): ReportMonad[Unit] =
        ReportMonad(s ->
            mapXHelper(mf, s, xs, e -> Err(e), s1 -> Ok((s1, ())))
        )

    ///
    /// Helper function for `mapX`.
    ///
    def mapXHelper(mf: a -> ReportMonad[b], 
                   s: Int32, 
                   xs: List[a], 
                   fk: System.Error -> Result[(Int32, Unit), System.Error], 
                   sk: Int32 -> Result[(Int32, Unit), System.Error]): Result[(Int32, Unit), System.Error] & Impure =
        match xs {
            case Nil => sk(s)
            case x :: rs => {
                let ma = mf(x);
                match apply1(ma, s) {
                    case Err(e) => fk(e)
                    case Ok((s1, _)) => mapXHelper(mf, s1, rs, fk, s2 -> sk(s2))
                }
            }
        }

    pub def sequence(xs: List[ReportMonad[a]]): ReportMonad[List[a]] =
        ReportMonad(s ->
            sequenceHelper(s, xs, e -> Err(e), (s1, ks) -> Ok((s1, ks)))
        )

    ///
    /// Helper function for `sequence`.
    ///
    def sequenceHelper(s: Int32, 
                       xs: List[ReportMonad[a]], 
                       fk: System.Error -> Result[(Int32, List[a]), System.Error], 
                       sk: (Int32, List[a]) -> Result[(Int32, List[a]), System.Error]): Result[(Int32, List[a]), System.Error] & Impure =
        match xs {
            case Nil => sk(s, Nil)
            case mx :: rs => match apply1(mx, s) {
                case Err(e) => fk(e)
                case Ok((s1, x)) => sequenceHelper(s1, rs, fk, (s2, ks) -> sk(s2, x :: ks))
            }
        }

    /// Alias for `bind`
    pub def >>=(ma: ReportMonad[a], k: a -> ReportMonad[b]): ReportMonad[b] = 
        bind(ma, k)

    /// Alias for `flatMap` (flipped `bind`)
    pub def =<<(k: a -> ReportMonad[b], ma: ReportMonad[a]): ReportMonad[b] = 
        flatMap(k, ma)


    pub def genEquiId(): ReportMonad[String] =         
        ReportMonad(s -> Ok((s, "$" + Int32.toString(s))) as & Impure)

    pub def restEquiIdCounter(): ReportMonad[Unit] =
        ReportMonad(_ -> { let n = initEquiNumber(); Ok((n, ()))})

}