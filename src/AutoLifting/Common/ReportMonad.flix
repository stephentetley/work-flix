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

/// TODO - rename file to `ReportMonad` once we can replace the old one...

namespace AutoLifting/Common {

    use BasicDb.DbMonad;

    /// Needs name supply for UXL

    pub opaque type ReportMonad[a] = Int32 -> DbMonad[(Int32, a)]

}


namespace AutoLifting/Common/ReportMonad {

    use BasicDb.DbMonad;


    use AutoLifting/Common.ReportMonad;
    use AutoLifting/Common.ReportMonad.{ReportMonad};

    pub def runReportMonad(ma: ReportMonad[a], dbpath: System.FilePath): Result[a, System.Error] & Impure = 
        use Result.{flatMap};
        use BasicDb/DbMonad.{runSQLite};
        let n1 = initEquiNumber();
        let ReportMonad(fn) = ma;
        let* (_, ans) = runSQLite(fn(n1), dbpath);
        Ok(ans)


    def initEquiNumber(): Int32 & Impure = 
        use Time/LocalDateTime.{now, getDayOfMonth, getHour, getMinute};
        let dt = now();
        let x1 = getDayOfMonth(dt) * 10_000_000;
        let x2 = getHour(dt) * 100_000;
        let x3 = getMinute(dt) * 1_000;
        x1 + x2 + x3


    pub def return(x: a): ReportMonad[a] =
        ReportMonad(s -> BasicDb/DbMonad.return((s, x)))

    pub def throwError(msg: String): ReportMonad[a] =
        ReportMonad(_ -> BasicDb/DbMonad.throwError(msg))        

    def apply1(ma: ReportMonad[a], s: Int32): DbMonad[(Int32, a)] =
        let ReportMonad(f) = ma;
        f(s)

    pub def map(f: a -> b & ef, ma: ReportMonad[a]): ReportMonad[b] =
        use BasicDb/DbMonad.{flatMap, liftAction, return};
        ReportMonad(s -> 
            let* (s1, a)    = apply1(ma, s);
            let* b          = liftAction(_ -> f(a) as & Impure);
            return((s1, b))
        )

    pub def ap(mf: ReportMonad[a -> b & ef], ma: ReportMonad[a]): ReportMonad[b] =
        use BasicDb/DbMonad.{flatMap, liftAction, return};
        ReportMonad(s ->
            let* (s1, f)    = apply1(mf, s);
            let* (s2, a)    = apply1(ma, s1);
            let* b          = liftAction(_ -> f(a) as & Impure);
            return((s2, b))
        )

    pub def bind(ma: ReportMonad[a], k: a -> ReportMonad[b]): ReportMonad[b] =        
        use BasicDb/DbMonad.{flatMap};
        ReportMonad(s ->
            let* (s1, a)    = apply1(ma, s);
            apply1(k(a), s1)
        )

    pub def flatMap(k: a -> ReportMonad[b], x: ReportMonad[a]): ReportMonad[b] = bind(x, k)

    pub def liftAction(fn: Unit ~> a): ReportMonad[a] =
        use BasicDb/DbMonad.{flatMap, return};
        ReportMonad(s -> 
            let* a = BasicDb/DbMonad.liftAction(fn); 
            return((s, a)) 
        )

    pub def liftResult(fn: Unit -> Result[a, System.Error]): ReportMonad[a] =
        use BasicDb/DbMonad.{flatMap, return};
        ReportMonad(s ->
            let* a = BasicDb/DbMonad.liftResult(fn); 
            return((s, a)) 
        )


    pub def liftActionResult(fn: Unit ~> Result[a, System.Error]): ReportMonad[a] =    
        use BasicDb/DbMonad.{flatMap, return};
        ReportMonad(s -> 
            let* a = BasicDb/DbMonad.liftActionResult(fn); 
            return((s, a))
        )


    pub def liftDbMonad(fn: Unit -> DbMonad[a]): ReportMonad[a] =
        use BasicDb/DbMonad.{flatMap, return};
        ReportMonad(s ->  
            let* a = fn();
            return((s, a))
        )


    pub def mapM(mf: a -> ReportMonad[b], xs: List[a]): ReportMonad[List[b]] =
        ReportMonad(s ->
            mapMHelper(mf, s, xs, (s1, ys) -> BasicDb/DbMonad.return((s1, ys)))
        )

    ///
    /// Helper function for `mapM`.
    ///
    def mapMHelper(mf: a -> ReportMonad[b], 
                   s: Int32, 
                   xs: List[a], 
                   sk: (Int32, List[b]) -> DbMonad[(Int32, List[b])]): DbMonad[(Int32, List[b])] =
        use BasicDb/DbMonad.{flatMap, return};
        match xs {
            case Nil => sk(s, Nil)
            case x :: rs => {                
                let* (s1, a) = apply1(mf(x), s);
                mapMHelper(mf, s1, rs, (s2, ks) -> sk(s2, a :: ks))
            }
        }


    pub def mapX(mf: a -> ReportMonad[b], xs: List[a]): ReportMonad[Unit] =
        ReportMonad(s ->
            mapXHelper(mf, s, xs, s1 -> BasicDb/DbMonad.return((s1, ())))
        )

    ///
    /// Helper function for `mapX`.
    ///
    def mapXHelper(mf: a -> ReportMonad[b], 
                   s: Int32, 
                   xs: List[a], 
                   sk: Int32 -> DbMonad[(Int32, Unit)]): DbMonad[(Int32, Unit)] =
        use BasicDb/DbMonad.{flatMap, return};
        match xs {
            case Nil => sk(s)
            case x :: rs => {
                let* (s1, _) = apply1(mf(x), s);
                mapXHelper(mf, s1, rs, s2 -> sk(s2))
            }
        }

    pub def sequence(xs: List[ReportMonad[a]]): ReportMonad[List[a]] =
        ReportMonad(s ->
            sequenceHelper(s, xs, (s1, ks) -> BasicDb/DbMonad.return((s1, ks)))
        )

    ///
    /// Helper function for `sequence`.
    ///
    def sequenceHelper(s: Int32, 
                       xs: List[ReportMonad[a]], 
                       sk: (Int32, List[a]) -> DbMonad[(Int32, List[a])]): DbMonad[(Int32, List[a])]=
        use BasicDb/DbMonad.{flatMap, return};
        match xs {
            case Nil => sk(s, Nil)
            case mx :: rs => {
                let* (s1, a) = apply1(mx, s);
                sequenceHelper(s1, rs, (s2, ks) -> sk(s2, a :: ks))
            }
        }


    
    pub def foldM(mf: (b, a) -> ReportMonad[b], start: b, xs: List[a]): ReportMonad[b] =
        ReportMonad(s ->
            foldMHelper(s, mf, start, xs, (s1, ac) -> BasicDb/DbMonad.return((s1, ac)))
        )

    def foldMHelper(s: Int32, 
                    mf: (b, a) -> ReportMonad[b], 
                    acc: b, 
                    xs: List[a], 
                    sk: (Int32, b) -> DbMonad[(Int32, b)]): DbMonad[(Int32, b)] =
        use BasicDb/DbMonad.{flatMap, return};
        match xs {
            case Nil => sk(s, acc)
            case x :: rs => {
                let ma = mf(acc, x);
                let* (s1, acc1) = apply1(ma, s);
                foldMHelper(s1, mf, acc1, rs, sk)
            }
        }

    /// Alias for `bind`
    pub def >>=(ma: ReportMonad[a], k: a -> ReportMonad[b]): ReportMonad[b] = 
        bind(ma, k)

    /// Alias for `flatMap` (flipped `bind`)
    pub def =<<(k: a -> ReportMonad[b], ma: ReportMonad[a]): ReportMonad[b] = 
        flatMap(k, ma)


    pub def genEquiId(): ReportMonad[String] =         
        ReportMonad(s -> BasicDb/DbMonad.return((s + 1, "$" + Int32.toString(s))))

    pub def restEquiIdCounter(): ReportMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, liftAction, return};
        ReportMonad(_ -> 
            let* n = liftAction(_ -> initEquiNumber()); 
            BasicDb/DbMonad.return((n, ()))
        )



}