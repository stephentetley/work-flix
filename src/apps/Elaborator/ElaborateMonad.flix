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
    
    pub opaque type ElaborateMonad[a] = Map[String, Int32] ~> Result[(Map[String, Int32], a), String]

}

namespace Elaborator/ElaborateMonad {
    
    use Elaborator.ElaborateMonad;
    use Elaborator.ElaborateMonad.{ElaborateMonad};

    def apply1(ma: ElaborateMonad[a], st: Map[String, Int32]): Result[(Map[String, Int32], a), String] & Impure = 
        let ElaborateMonad(x1) = ma;
        x1(st)

    pub def return(x: a): ElaborateMonad[a] = 
        ElaborateMonad(s1 -> Ok((s1, x)) as & Impure)

    pub def throwError(msg: String): ElaborateMonad[a] =
        ElaborateMonad(_ -> Err(msg) as & Impure)


    pub def swapError(ma: ElaborateMonad[a], msg: String): ElaborateMonad[a] =
        ElaborateMonad(s1 -> match apply1(ma, s1) { 
            case Ok((s2, a)) => Ok((s2, a))
            case Err(_) => Err(msg)
        })


    pub def catchError(ma: ElaborateMonad[a], handle: String -> ElaborateMonad[a]): ElaborateMonad[a] =
        ElaborateMonad(s1 -> match apply1(ma, s1) { 
            case Ok((s2, a)) => Ok((s2, a))
            case Err(e) => apply1(handle(e), s1)
        })

    pub def mapError(f: String -> String, ma: ElaborateMonad[a]): ElaborateMonad[a] =
        ElaborateMonad(s1 -> match apply1(ma, s1) { 
            case Ok((s2, a)) => Ok((s2, a))
            case Err(e) => Err(f(e))
        })

    /// Needs to allow allow effects (e.g create / access arrays)
    pub def map(fn: a -> b & ef, ma: ElaborateMonad[a]): ElaborateMonad[b] = 
        ElaborateMonad(s1 -> match apply1(ma, s1) { 
            case Ok((s2, a)) => {let ans = fn(a) as & Impure; Ok((s2, ans))}
            case Err(e) => Err(e)
        })

    pub def ap(mf: ElaborateMonad[a -> b & ef], ma: ElaborateMonad[a]): ElaborateMonad[b] = 
        ElaborateMonad(s1 -> match apply1(mf, s1) { 
            case Ok((s2, f)) => match apply1(ma, s2) { 
                case Ok((s3, a)) => {let ans = f(a) as & Impure; Ok((s3, ans))}
                case Err(e) => Err(e)
            }
            case Err(e) => Err(e)
        })


    pub def seqLeft(ma: ElaborateMonad[a], mb: ElaborateMonad[b]): ElaborateMonad[a] = 
        ElaborateMonad(s1 -> match apply1(ma, s1) { 
            case Ok((s2, a)) => match apply1(mb, s2) {
                case Ok((s3, _)) => Ok((s3, a))
                case Err(e) => Err(e)
            }
            case Err(e) => Err(e)
        })

    pub def seqRight(ma: ElaborateMonad[a], mb: ElaborateMonad[b]): ElaborateMonad[b] = 
        ElaborateMonad(s1 -> match apply1(ma, s1) { 
            case Ok((s2, _)) => apply1(mb, s2)
            case Err(e) => Err(e)
        })


    pub def bind(ma: ElaborateMonad[a], fn: a -> ElaborateMonad[b]): ElaborateMonad[b] = 
        ElaborateMonad(s1 -> match apply1(ma, s1) { 
            case Ok((s2, a)) => apply1(fn(a), s2)
            case Err(e) => Err(e)
        })

    pub def flatMap(fn: a -> ElaborateMonad[b], ma: ElaborateMonad[a]): ElaborateMonad[b] = bind(ma, fn)

    pub def kleisliLeft(f1: a -> ElaborateMonad[b], f2: b -> ElaborateMonad[c], x: a): ElaborateMonad[c] =
        ElaborateMonad(s1 -> match apply1(f1(x), s1) { 
            case Ok((s2, b)) => apply1(f2(b), s2)
            case Err(e) => Err(e)
        })

    pub def kleisliRight(f1: b -> ElaborateMonad[c], f2: a -> ElaborateMonad[b], x: a): ElaborateMonad[c] =
        kleisliLeft(f2, f1, x)


    pub def alt(ma: ElaborateMonad[a], mb: ElaborateMonad[a]): ElaborateMonad[a] =
        ElaborateMonad(s1 -> match apply1(ma, s1) { 
            case Ok((s2, a)) => Ok((s2, a))
            case Err(_) => apply1(mb, s1)
        })

    pub def optional(ma: ElaborateMonad[a]): ElaborateMonad[Option[a]] = 
        alt(map(Some, ma), return(None))

    pub def tryWithDefault(ma: ElaborateMonad[a], d: a): ElaborateMonad[a] = 
        alt(ma, return(d))

    pub def testM(ma: ElaborateMonad[a]): ElaborateMonad[Bool] =
        ElaborateMonad(s1 -> match apply1(ma, s1) { 
            case Ok((s2, _)) => Ok((s2, true))
            case Err(_) => Ok((s1, false))
        })

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

    /// Short circuits on fail...
    pub def mapM(f: a -> ElaborateMonad[b], xs: List[a]): ElaborateMonad[List[b]] =
        ElaborateMonad(s1 -> mapMHelper(s1, f, xs, e -> Err(e), (s2, ys) -> Ok((s2, ys))))

    ///
    /// Helper function for `mapM`.
    ///
    def mapMHelper(s1: Map[String, Int32], 
                   mf: a -> ElaborateMonad[b], 
                   xs: List[a], 
                   fk: String -> Result[(Map[String, Int32], List[b]), String], 
                   sk: (Map[String, Int32], List[b]) -> Result[(Map[String, Int32], List[b]), String]): Result[(Map[String, Int32], List[b]), String] & Impure =
        match xs {
            case Nil => sk(s1, Nil)
            case x :: rs => {
                let ma = mf(x);
                match apply1(ma, s1) {
                    case Err(e) => fk(e)
                    case Ok((s2, ans)) => mapMHelper(s2, mf, rs, fk, (s3, ks) -> sk(s3, ans :: ks))
                }
            }
        }

}
