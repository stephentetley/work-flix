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

namespace AssetLib/GenS4 {

    use AssetLib/GenS4/GenEquiMonad.{Env, Output};

    /// State (for id gen and Output) + Env
    pub opaque type GenEquiMonad[a] = (Int32, Output, Env) ~> Result[(Int32, Output, a), String]
}

namespace AssetLib/GenS4/GenEquiMonad {

    use AssetLib/S4Lite/Datatypes.{UxlSource, SLEquipment, SLEquiLongText, SLEquiCharacteristic};
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3};
    use AssetLib/GenS4.GenEquiMonad;
    use AssetLib/GenS4.GenEquiMonad.{GenEquiMonad};


    /// Potentially Env should have SolutionId...
    type alias Env = Time.LocalDate

    type alias Output = 
        { equipment: Chain[SLEquipment]
        , longText: Chain[SLEquiLongText]
        , characteristics: Chain[SLEquiCharacteristic]
        }

    pub opaque type EquiRef = String

    pub def withEquiRef(x: EquiRef, f: String -> a & ef): a & ef = 
        let EquiRef(x1) = x;
        f(x1)

    /// Alternative to `WorkLists` for generating equipment ...

    pub def runGenEquiMonad(mx: GenEquiMonad[a]): Result[(UxlSource, a), String] & Impure = 
        use Result.flatMap;
        let today           = Time/LocalDate.now();
        let index           = AssetLib/S4Lite/Utils.getStartUid();
        let acc             = {equipment = Chain.empty(), longText = Chain.empty(), characteristics = Chain.empty()};
        let* ((_, w, ans))  = apply1(mx, index, acc, today);
        let uxl             = {funclocs                 = Chain.empty()
                            , funclocLongTexts          = Chain.empty()
                            , funclocCharacteristics    = Chain.empty()
                            , equipment                 = w.equipment
                            , equiLongTexts             = w.longText
                            , equiCharacteristics       = w.characteristics
                            };
        Ok((uxl, ans))

    pub def execGenEquiMonad(mx: GenEquiMonad[a]): Result[UxlSource, String] & Impure = 
        runGenEquiMonad(mx) |> Result.map(fst)

    pub def return(x: a): GenEquiMonad[a] = 
        GenEquiMonad((st, w, _) -> Ok((st, w, x)) as & Impure)

    def apply1(x: GenEquiMonad[a], st: Int32, w: Output, r: Env): Result[(Int32, Output, a), String] & Impure =
        let GenEquiMonad(f) = x;
        f(st, w, r)

    pub def map(f: a -> b & ef, x: GenEquiMonad[a]): GenEquiMonad[b] =
        GenEquiMonad((st, w, r) -> 
            match apply1(x, st, w, r) {
                case Ok((st1, w1, a)) => {
                    let ans = f(a) as & Impure;
                    Ok((st1, w1, ans))
                }
                case Err(e) => Err(e)
            }
        )  


    pub def ap(mf: GenEquiMonad[a -> b & ef], ma: GenEquiMonad[a]): GenEquiMonad[b] = 
        GenEquiMonad((st, w, r) -> 
            match apply1(mf, st, w, r) {
                case Ok((st1, w1, f)) => 
                    match apply1(ma, st1, w1, r) { 
                        case Ok((st2, w2, a)) => {let ans = f(a) as & Impure; Ok((st2, w2, ans))}
                        case Err(e) => Err(e)
                    }
                case Err(e) => Err(e)
            })


    pub def seqLeft(ma: GenEquiMonad[a], mb: GenEquiMonad[b]): GenEquiMonad[a] = 
        GenEquiMonad((st, w, r) -> 
            match apply1(ma, st, w, r) { 
                case Ok((st1, w1, a)) => 
                    match apply1(mb, st1, w1, r) {
                        case Ok((st2, w2, _)) => Ok(st2, w2, a)
                        case Err(e) => Err(e)
                    }
                case Err(e) => Err(e)
            })

    pub def seqRight(ma: GenEquiMonad[a], mb: GenEquiMonad[b]): GenEquiMonad[b] = 
        GenEquiMonad((st, w, r) ->  
            match apply1(ma, st, w, r) {  
                case Ok((st1, w1, _)) => apply1(mb, st1, w1, r)
                case Err(e) => Err(e)
            })


    pub def bind(x: GenEquiMonad[a], k: a -> GenEquiMonad[b]): GenEquiMonad[b] = 
        GenEquiMonad((st, w, r) -> 
            match apply1(x, st, w, r) {
                case Ok((st1, w1, a)) => { let ans = k(a); apply1(ans, st1, w1, r) }
                case Err(e) => Err(e)
            }
        )

    pub def flatMap(k: a -> GenEquiMonad[b], x: GenEquiMonad[a]): GenEquiMonad[b] = bind(x, k)


    pub def kleisliLeft(f1: a -> GenEquiMonad[b], f2: b -> GenEquiMonad[c], x: a): GenEquiMonad[c] =
        GenEquiMonad((st, w, r) -> 
            match apply1(f1(x), st, w, r) { 
                case Ok((st1, w1, a)) => apply1(f2(a), st1, w1, r)
                case Err(e) => Err(e)
            })

    pub def kleisliRight(f1: b -> GenEquiMonad[c], f2: a -> GenEquiMonad[b], x: a): GenEquiMonad[c] =
        kleisliLeft(f2, f1, x)


    pub def alt(ma: GenEquiMonad[a], mb: GenEquiMonad[a]): GenEquiMonad[a] =
        GenEquiMonad((st, w, r) -> 
            match apply1(ma, st, w, r) { 
                case Ok((st1, w1, a)) => Ok((st1, w1, a))
                case Err(_) => apply1(mb, st, w, r)
            })


    pub def genEqui(f: (String, Time.LocalDate) -> SLEquipment & ef): GenEquiMonad[EquiRef] = 
        GenEquiMonad((st, w, r) -> 
            let equiId = "$" + ToString.toString(st);
            let equi = f(equiId, r) as & Impure;
            let w1 = {equipment = Chain.snoc(w.equipment, equi) | w};
            Ok((st + 1, w1, EquiRef(equiId)))
        )  


    pub def liftAction(f: Unit ~> a): GenEquiMonad[a] = 
        GenEquiMonad((st, w, _) -> 
            let ans = f() as & Impure;
            Ok((st, w, ans))
        )


    pub def appendCharacteristics(cs: Chain[SLEquiCharacteristic]): GenEquiMonad[Unit] = 
        GenEquiMonad((st, w, _) ->  
            let w1 = {characteristics = Chain.append(w.characteristics, cs) | w} as & Impure;        
            Ok((st, w1, ()))
        )

    pub def equiCharacteristicsSkeleton(makeFacts: EquiRef -> row -> #{| reln}, 
                                    genChars: #{| reln} ~> Chain[SLEquiCharacteristic], 
                                    xs: List[(EquiRef, row)]): GenEquiMonad[Unit] =
        let facts   = Relation.foldMap(uncurry(makeFacts), xs);
        let* chars  = liftAction(_ -> genChars(facts));
        appendCharacteristics(chars)

    /// Alias for `seqRight`
    pub def *>(p1: GenEquiMonad[a], p2: GenEquiMonad[b]): GenEquiMonad[b] = seqRight(p1, p2)

    /// Alias for `seqLeft`
    pub def <*(p1: GenEquiMonad[a], p2: GenEquiMonad[b]): GenEquiMonad[a] = seqLeft(p1, p2)

    /// Haskell's <|>
    pub def <!>(p1: GenEquiMonad[a], p2: GenEquiMonad[a]): GenEquiMonad[a] =
        alt(p1, p2)

    // Haskell's <$>
    pub def <&>(f: a -> b, p2: GenEquiMonad[a]): GenEquiMonad[b] =
        map(f, p2)

    pub def <&(x: b, p2: GenEquiMonad[a]): GenEquiMonad[b] =
        p2 *> return(x)

    /// Alias for `bind`
    pub def >>=(ma: GenEquiMonad[a], k: a -> GenEquiMonad[b]): GenEquiMonad[b] = bind(ma, k)

    /// Alias for `flatMap` (flipped `bind`)
    pub def =<<(k: a -> GenEquiMonad[b], ma: GenEquiMonad[a]): GenEquiMonad[b] = flatMap(k, ma)


    pub def mapM(mf: a -> GenEquiMonad[b], xs: List[a]): GenEquiMonad[List[b]] =
        GenEquiMonad((st, w, r) -> 
            mapMHelper(st, w, r, mf, xs, e -> Err(e), (kst, kw, ks) -> Ok((kst, kw, ks)))
        )

    /// (Int32, Output, AssetLib/GenS4/GenEquiMonad.Env) ~> Result[(Int32, Output, a), String]

    ///
    /// Helper function for `mapM`.
    ///
    def mapMHelper(st: Int32, 
                    w: Output,
                    r: Env,
                    mf: a -> GenEquiMonad[b], 
                    xs: List[a], 
                    fk: String -> Result[(Int32, Output, List[b]), String], 
                    sk: (Int32, Output, List[b]) -> Result[(Int32, Output, List[b]), String]): Result[(Int32, Output, List[b]), String] & Impure =
        match xs {
            case Nil => sk(st, w, Nil)
            case x :: rs => {
                let ma = mf(x);
                match apply1(ma, st, w, r) {
                    case Err(e) => fk(e)
                    case Ok((st1, w1, x1)) => mapMHelper(st1, w1, r, mf, rs, fk, (st3, w3, ks) -> sk(st3, w3, x1 :: ks))
                }
            }
        }        

}
