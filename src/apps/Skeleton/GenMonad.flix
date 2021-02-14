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


}    