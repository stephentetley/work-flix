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

namespace Elaborator {

    use BasicDb.DbMonad;

    pub opaque type ElaborateMonad[a] = Map[String, Int32] -> DbMonad[(Map[String, Int32], a)]

}

namespace Elaborator/ElaborateMonad {
    
    use BasicDb.DbMonad;

    use Elaborator.ElaborateMonad;
    use Elaborator.ElaborateMonad.{ElaborateMonad};

    pub def runElaborateMonad(ma: ElaborateMonad[a], 
                              x: {equiTableName: String, flocTableName: String}): DbMonad[a] = 
        use BasicDb/DbMonad.{flatMap};
        let ElaborateMonad(f) = ma;
        let action = () -> {
            let* _  = Elaborator/GetValuaMax.cacheValuaFlocMaxQuery(x.flocTableName);
            let* _  = Elaborator/GetValuaMax.cacheValuaEquiMaxQuery(x.equiTableName);
            f(Map.empty())
        };
        BasicDb/DbMonad.map(snd, action())

    def apply1(ma: ElaborateMonad[a], st: Map[String, Int32]): DbMonad[(Map[String, Int32], a)] = 
        let ElaborateMonad(x1) = ma;
        x1(st)

    pub def return(x: a): ElaborateMonad[a] = 
        ElaborateMonad(s1 -> BasicDb/DbMonad.return((s1, x)))

    pub def throwError(msg: String): ElaborateMonad[a] =
        ElaborateMonad(_ -> BasicDb/DbMonad.throwError(msg))


    pub def swapError(ma: ElaborateMonad[a], msg: String): ElaborateMonad[a] =
        ElaborateMonad(s1 -> BasicDb/DbMonad.swapError(apply1(ma, s1), msg))
            


    pub def catchError(ma: ElaborateMonad[a], handle: String -> ElaborateMonad[a]): ElaborateMonad[a] =
        ElaborateMonad(s1 -> BasicDb/DbMonad.catchError(apply1(ma, s1), msg -> apply1(handle(msg), s1)))

    pub def mapError(f: String -> String, ma: ElaborateMonad[a]): ElaborateMonad[a] =
        ElaborateMonad(s1 -> BasicDb/DbMonad.mapError(f, apply1(ma, s1)))
            

    /// Needs to allow allow effects (e.g create / access arrays)
    pub def map(fn: a -> b & ef, ma: ElaborateMonad[a]): ElaborateMonad[b] = 
        ElaborateMonad(s1 -> BasicDb/DbMonad.map(ans -> {let (s2, a) = ans; (s2, fn(a))}, apply1(ma, s1)))
            

    
    pub def ap(mf: ElaborateMonad[a -> b & ef], ma: ElaborateMonad[a]): ElaborateMonad[b] =         
        use BasicDb/DbMonad.{flatMap, return};
        ElaborateMonad(s1 -> {
            let* (s2, f) = apply1(mf, s1); 
            let* (s3, a) = apply1(ma, s2); 
            let* ans     = BasicDb/DbMonad.map(f, return(a));
            return((s3, ans))
        })



    pub def seqLeft(ma: ElaborateMonad[a], mb: ElaborateMonad[b]): ElaborateMonad[a] = 
        let* a = ma;
        let* _ = mb;
        return(a)

    pub def seqRight(ma: ElaborateMonad[a], mb: ElaborateMonad[b]): ElaborateMonad[b] = 
        let* _ = ma;
        let* b = mb;
        return(b)


    pub def bind(ma: ElaborateMonad[a], fn: a -> ElaborateMonad[b]): ElaborateMonad[b] = 
        ElaborateMonad(s1 -> 
            BasicDb/DbMonad.bind(
                apply1(ma, s1), 
                ans -> {let (s2, a) = ans; apply1(fn(a), s2)}
        ))

    pub def flatMap(fn: a -> ElaborateMonad[b], ma: ElaborateMonad[a]): ElaborateMonad[b] = bind(ma, fn)

    pub def kleisliLeft(f1: a -> ElaborateMonad[b], f2: b -> ElaborateMonad[c], x: a): ElaborateMonad[c] =
        let* b = f1(x);
        let* c = f2(b);
        return(c)

    pub def kleisliRight(f1: b -> ElaborateMonad[c], f2: a -> ElaborateMonad[b], x: a): ElaborateMonad[c] =
        kleisliLeft(f2, f1, x)


    pub def alt(ma: ElaborateMonad[a], mb: ElaborateMonad[a]): ElaborateMonad[a] =
        ElaborateMonad(s1 -> BasicDb/DbMonad.alt(apply1(ma, s1), apply1(mb, s1)))

    pub def optional(ma: ElaborateMonad[a]): ElaborateMonad[Option[a]] = 
        alt(map(Some, ma), return(None))

    pub def tryWithDefault(ma: ElaborateMonad[a], d: a): ElaborateMonad[a] = 
        alt(ma, return(d))

    pub def testM(ma: ElaborateMonad[a]): ElaborateMonad[Bool] =
        ElaborateMonad(s1 -> 
            BasicDb/DbMonad.catchError( BasicDb/DbMonad.map(ans -> (fst(ans), true), apply1(ma, s1))
                                      , _ -> BasicDb/DbMonad.return((s1, false)))
        )

    /// For Functor ...
    pub def ignore(mx: ElaborateMonad[a]): ElaborateMonad[Unit] =
        map(constant(), mx)


    // Haskell's <$>
    pub def <&>(f: a -> b & ef, mx: ElaborateMonad[a]): ElaborateMonad[b] =
        map(f, mx)

    pub def <&(x: a, mx: ElaborateMonad[b]): ElaborateMonad[a] =
        map(_ -> x, mx)

    // Haskell's <*> (i.e `ap`)
    pub def <*>(f: ElaborateMonad[a -> b & ef], mx: ElaborateMonad[a]): ElaborateMonad[b] =
        ap(f, mx)

    pub def <**>(mx: ElaborateMonad[a], f: ElaborateMonad[a -> b & ef]): ElaborateMonad[b] =
        ap(f, mx)

    /// /// Short circuits on fail...
    /// pub def mapM(f: a -> ElaborateMonad[b], xs: List[a]): ElaborateMonad[List[b]] =
    ///     ElaborateMonad(s1 -> mapMHelper(s1, f, xs, e -> Err(e), (s2, ys) -> Ok((s2, ys))))

    /// ///
    /// /// Helper function for `mapM`.
    /// ///
    /// def mapMHelper(s1: Map[String, Int32], 
    ///                mf: a -> ElaborateMonad[b], 
    ///                xs: List[a], 
    ///                fk: String -> Result[(Map[String, Int32], List[b]), String], 
    ///                sk: (Map[String, Int32], List[b]) -> Result[(Map[String, Int32], List[b]), String]): Result[(Map[String, Int32], List[b]), String] & Impure =
    ///     match xs {
    ///         case Nil => sk(s1, Nil)
    ///         case x :: rs => {
    ///             let ma = mf(x);
    ///             match apply1(ma, s1) {
    ///                 case Err(e) => fk(e)
    ///                 case Ok((s2, ans)) => mapMHelper(s2, mf, rs, fk, (s3, ks) -> sk(s3, ans :: ks))
    ///             }
    ///         }
    ///     }

    def makeEquiKey(equiId: String, charName: String): String = "${equiId}::${charName}"

    pub def nextValuaEquiCounter(equiId: String, charName: String): ElaborateMonad[Int32] = 
        use BasicDb/DbMonad.{flatMap, return};
        ElaborateMonad(s1 -> {
            let key = makeEquiKey(equiId, charName); 
            match Map.get(key, s1) {
                case Some(i) => return((Map.insert(key, i + 1, s1), i + 1))
                case None => {
                    let* i = Elaborator/GetValuaMax.getValuaEquiMax(equiId, charName);
                    return((Map.insert(key, i + 1, s1), i + 1))
                }
            }
        })

    def makeFlocKey(funcloc: String, charName: String): String = "${funcloc}::${charName}"

    pub def nextValuaFlocCounter(funcloc: String, charName: String): ElaborateMonad[Int32] = 
        use BasicDb/DbMonad.{flatMap, return};
        ElaborateMonad(s1 -> {
            let key = makeFlocKey(funcloc, charName); 
            match Map.get(key, s1) {
                case Some(i) => return((Map.insert(key, i + 1, s1), i + 1))
                case None => {
                    let* i = Elaborator/GetValuaMax.getValuaFlocMax(funcloc, charName);
                    return((Map.insert(key, i + 1, s1), i + 1))
                }
            }
        })

}
