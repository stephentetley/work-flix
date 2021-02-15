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


namespace Skeleton {

    use BasicDb.DbMonad;
    
    pub opaque type GenMonad[a] = Int32 -> DbMonad[(Int32, a)]

}

namespace Skeleton/GenMonad {

    use BasicDb.DbMonad;

    use Skeleton.GenMonad;
    use Skeleton.GenMonad.{GenMonad};

    pub def runElaborateMonad(ma: GenMonad[a]): DbMonad[a] = 
        use BasicDb/DbMonad.{flatMap};
        let GenMonad(f) = ma;
        let action = () -> {
            f(10000)
        };
        BasicDb/DbMonad.map(snd, action())

    def apply1(ma: GenMonad[a], s1: Int32): DbMonad[(Int32, a)] = 
        let GenMonad(x1) = ma;
        x1(s1)

    pub def return(x: a): GenMonad[a] = 
        GenMonad(s1 -> BasicDb/DbMonad.return((s1, x)))

    pub def throwError(msg: String): GenMonad[a] =
        GenMonad(_ -> BasicDb/DbMonad.throwError(msg))

    pub def swapError(ma: GenMonad[a], msg: String): GenMonad[a] =
        GenMonad(s1 -> BasicDb/DbMonad.swapError(apply1(ma, s1), msg))
            


    pub def catchError(ma: GenMonad[a], handle: String -> GenMonad[a]): GenMonad[a] =
        GenMonad(s1 -> BasicDb/DbMonad.catchError(apply1(ma, s1), msg -> apply1(handle(msg), s1)))

    pub def mapError(f: String -> String, ma: GenMonad[a]): GenMonad[a] =
        GenMonad(s1 -> BasicDb/DbMonad.mapError(f, apply1(ma, s1)))
            

    /// Needs to allow allow effects (e.g create / access arrays)
    pub def map(fn: a -> b & ef, ma: GenMonad[a]): GenMonad[b] = 
        GenMonad(s1 -> BasicDb/DbMonad.map(ans -> {let (s2, a) = ans; (s2, fn(a))}, apply1(ma, s1)))


    
    pub def ap(mf: GenMonad[a -> b & ef], ma: GenMonad[a]): GenMonad[b] =         
        use BasicDb/DbMonad.{flatMap, return};
        GenMonad(s1 -> {
            let* (s2, f) = apply1(mf, s1); 
            let* (s3, a) = apply1(ma, s2); 
            let* ans     = BasicDb/DbMonad.map(f, return(a));
            return((s3, ans))
        })



    pub def seqLeft(ma: GenMonad[a], mb: GenMonad[b]): GenMonad[a] = 
        let* a = ma;
        let* _ = mb;
        return(a)

    pub def seqRight(ma: GenMonad[a], mb: GenMonad[b]): GenMonad[b] = 
        let* _ = ma;
        let* b = mb;
        return(b)


    pub def bind(ma: GenMonad[a], fn: a -> GenMonad[b]): GenMonad[b] = 
        GenMonad(s1 -> 
            BasicDb/DbMonad.bind(
                apply1(ma, s1), 
                ans -> {let (s2, a) = ans; apply1(fn(a), s2)}
        ))

    pub def flatMap(fn: a -> GenMonad[b], ma: GenMonad[a]): GenMonad[b] = bind(ma, fn)


    pub def liftOption(x: Option[a], errMsg: String): GenMonad[a] = match x {
        case Some(a) => return(a)
        case None => throwError(errMsg)
    }

    /// For Functor ...
    pub def ignore(mx: GenMonad[a]): GenMonad[Unit] =
        map(constant(), mx)


    // Haskell's <$>
    pub def <&>(f: a -> b & ef, mx: GenMonad[a]): GenMonad[b] =
        map(f, mx)

    pub def <&(x: a, mx: GenMonad[b]): GenMonad[a] =
        map(_ -> x, mx)

    // Haskell's <*> (i.e `ap`)
    pub def <*>(f: GenMonad[a -> b & ef], mx: GenMonad[a]): GenMonad[b] =
        ap(f, mx)

    pub def <**>(mx: GenMonad[a], f: GenMonad[a -> b & ef]): GenMonad[b] =
        ap(f, mx)

    ///
    /// Applies the binary function `f` to the values in `o1` and `o2`.
    ///
    /// Returns an error if either `o1` or `o2` are errors.
    ///
    pub def lift2(f: (t1, t2) -> u & ef, 
                  o1: GenMonad[t1], 
                  o2: GenMonad[t2]): GenMonad[u] =
        ap(map(f, o1), o2)


    ///
    /// Applies the ternary function `f` to the values in `o1`, `o2` and `o3`.
    ///
    /// Returns an error if any of `o1`, `o2` and `o3` are errors.
    ///
    pub def lift3(f: (t1, t2, t3) -> u & ef, 
                  o1: GenMonad[t1], 
                  o2: GenMonad[t2], 
                  o3: GenMonad[t3]): GenMonad[u] =
        ap(lift2(f, o1, o2), o3)

    ///
    /// Applies the 4-ary function `f` to the values in `o1`, `o2`, `o3` and `o4`.
    ///
    /// Returns an error if any of `o1`, `o2`, `o3` and `o4` are errors.
    ///
    pub def lift4(f: (t1, t2, t3, t4) -> u & ef, 
                  o1: GenMonad[t1], 
                  o2: GenMonad[t2], 
                  o3: GenMonad[t3], 
                  o4: GenMonad[t4]): GenMonad[u] =
        ap(lift3(f, o1, o2, o3), o4)

    ///
    /// Applies the 5-ary function `f` to the values in `o1`, `o2`, ... `o5`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o5` are errors.
    ///
    pub def lift5(f: (t1, t2, t3, t4, t5) -> u & ef, 
                  o1: GenMonad[t1], 
                  o2: GenMonad[t2], 
                  o3: GenMonad[t3], 
                  o4: GenMonad[t4], 
                  o5: GenMonad[t5]): GenMonad[u] =
        ap(lift4(f, o1, o2, o3, o4), o5)

    ///
    /// Applies the 6-ary function `f` to the values in `o1`, `o2`, ... `o6`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o6` are errors.
    ///
    pub def lift6(f: (t1, t2, t3, t4, t5, t6) -> u & ef, 
                  o1: GenMonad[t1], 
                  o2: GenMonad[t2], 
                  o3: GenMonad[t3],
                  o4: GenMonad[t4], 
                  o5: GenMonad[t5], 
                  o6: GenMonad[t6]): GenMonad[u] =
        ap(lift5(f, o1, o2, o3, o4, o5), o6)

    ///
    /// Applies the 7-ary function `f` to the values in `o1`, `o2`, ... `o7`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o7` are errors.
    ///
    pub def lift7(f: (t1, t2, t3, t4, t5, t6, t7) -> u & ef, 
                  o1: GenMonad[t1], 
                  o2: GenMonad[t2], 
                  o3: GenMonad[t3], 
                  o4: GenMonad[t4], 
                  o5: GenMonad[t5], 
                  o6: GenMonad[t6], 
                  o7: GenMonad[t7]): GenMonad[u] =
        ap(lift6(f, o1, o2, o3, o4, o5, o6), o7)

    ///
    /// Applies the 8-ary function `f` to the values in `o1`, `o2`, ... `o8`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o8` are errors.
    ///
    pub def lift8(f: (t1, t2, t3, t4, t5, t6, t7, t8) -> u & ef, 
                  o1: GenMonad[t1], 
                  o2: GenMonad[t2], 
                  o3: GenMonad[t3], 
                  o4: GenMonad[t4], 
                  o5: GenMonad[t5], 
                  o6: GenMonad[t6], 
                  o7: GenMonad[t7], 
                  o8: GenMonad[t8]): GenMonad[u] =
        ap(lift7(f, o1, o2, o3, o4, o5, o6, o7), o8)

    ///
    /// Applies the 9-ary function `f` to the values in `o1`, `o2`, ... `o9`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o9` are errors.
    ///
    pub def lift9(f: (t1, t2, t3, t4, t5, t6, t7, t8, t9) -> u & ef, 
                  o1: GenMonad[t1], 
                  o2: GenMonad[t2], 
                  o3: GenMonad[t3], 
                  o4: GenMonad[t4], 
                  o5: GenMonad[t5], 
                  o6: GenMonad[t6], 
                  o7: GenMonad[t7], 
                  o8: GenMonad[t8], 
                  o9: GenMonad[t9]): GenMonad[u] =
        ap(lift8(f, o1, o2, o3, o4, o5, o6, o7, o8), o9)

    ///
    /// Applies the 10-ary function `f` to the values in `o1`, `o2`, ... `o10`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o10` are errors.
    ///
    pub def lift10(f: (t1, t2, t3, t4, t5, t6, t7, t8, t9, t10) -> u & ef, 
                   o1: GenMonad[t1], 
                   o2: GenMonad[t2], 
                   o3: GenMonad[t3], 
                   o4: GenMonad[t4], 
                   o5: GenMonad[t5], 
                   o6: GenMonad[t6], 
                   o7: GenMonad[t7], 
                   o8: GenMonad[t8], 
                   o9: GenMonad[t9], 
                   o10: GenMonad[t10]): GenMonad[u] =
        ap(lift9(f, o1, o2, o3, o4, o5, o6, o7, o8, o9), o10)




}    