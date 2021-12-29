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

    use AssetLib/GenS4/GenMonad.{Env, Output};

    /// State (for id gen and Output) + Env
    /// Monad is impure so we can lift array handling into it
    pub opaque type GenMonad[a] = (Int32, Output, Env) -> Result[(Int32, Output, a), String] & Impure

    instance Functor[GenMonad] { 
        pub def map(f: a -> b & ef, x: GenMonad[a]): GenMonad[b] & ef = 
            AssetLib/GenS4/GenMonad.map(f, x)
    }

    instance Applicative[GenMonad] { 
        pub def point(x: a): GenMonad[a] = 
            AssetLib/GenS4/GenMonad.point(x)

        pub def ap(f: GenMonad[a -> b & ef], x: GenMonad[a]): GenMonad[b] & ef = 
            AssetLib/GenS4/GenMonad.ap(f, x)
    }

    instance Monad[GenMonad] { 
        pub def flatMap(k: a -> GenMonad[b] & ef, x: GenMonad[a]): GenMonad[b] & ef = 
            AssetLib/GenS4/GenMonad.flatMap(k, x)
    }
}

namespace AssetLib/GenS4/GenMonad {

    use AssetLib/S4Lite/Datatypes.{UxlSource, SLFunctionalLocation, SLEquipment, SLEquiLongText, SLEquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.{FlocCharacteristic, EquiCharacteristic};
    use AssetLib/GenS4.GenMonad;
    use AssetLib/GenS4.GenMonad.{GenMonad};


    /// Potentially Env should be open to the user: `Env[e] = (Time.LocalDate, e)`
    pub type alias Env = Time.LocalDate

    pub type alias Output = UxlSource

    pub opaque type EquiRef = String

    pub def withEquiRef(x: EquiRef, f: String -> a & ef): a & ef = 
        let EquiRef(x1) = x;
        f(x1)

    /// Alternative to `WorkLists` for generating equipment ...

    pub def runGenMonad(mx: GenMonad[a]): Result[(UxlSource, a), String] & Impure = 
        use Result.flatMap;
        let today               = Time/LocalDate.now();
        let index               = AssetLib/S4Lite/Utils.getStartUid();
        let acc                 = AssetLib/S4Lite/Datatypes.emptyUxlSource();
        let* ((_, uxl, ans))    = apply1(mx, index, acc, today);
        Ok((uxl, ans))

    pub def execGenMonad(mx: GenMonad[a]): Result[UxlSource, String] & Impure = 
        runGenMonad(mx) |> Result.map(fst)

    pub def evalGenMonad(mx: GenMonad[a]): Result[a, String] & Impure = 
        runGenMonad(mx) |> Result.map(snd)

    pub def point(x: a): GenMonad[a] = 
        GenMonad((st, w, _) -> Ok((st, w, x)) as & Impure)

    def apply1(x: GenMonad[a], st: Int32, w: Output, r: Env): Result[(Int32, Output, a), String] & Impure =
        let GenMonad(f) = x;
        f(st, w, r)

    pub def map(f: a -> b & ef, x: GenMonad[a]): GenMonad[b] & ef =
        GenMonad((st, w, r) -> 
            match apply1(x, st, w, r) {
                case Ok((st1, w1, a)) => {
                    let ans = f(a) as & Impure;
                    Ok((st1, w1, ans))
                }
                case Err(e) => Err(e)
            }
        ) as & ef


    pub def ap(mf: GenMonad[a -> b & ef], ma: GenMonad[a]): GenMonad[b] & ef = 
        GenMonad((st, w, r) -> 
            match apply1(mf, st, w, r) {
                case Ok((st1, w1, f)) => 
                    match apply1(ma, st1, w1, r) { 
                        case Ok((st2, w2, a)) => {let ans = f(a) as & Impure; Ok((st2, w2, ans))}
                        case Err(e) => Err(e)
                    }
                case Err(e) => Err(e)
            }) as & ef


    pub def bind(x: GenMonad[a], k: a -> GenMonad[b] & ef): GenMonad[b] & ef = 
        GenMonad((st, w, r) -> 
            match apply1(x, st, w, r) {
                case Ok((st1, w1, a)) => { let ans = k(a) as & Impure; apply1(ans, st1, w1, r) }
                case Err(e) => Err(e)
            }
        ) as & ef

    pub def flatMap(k: a -> GenMonad[b] & ef, x: GenMonad[a]): GenMonad[b] & ef = bind(x, k)


    pub def alt(ma: GenMonad[a], mb: GenMonad[a]): GenMonad[a] =
        GenMonad((st, w, r) -> 
            match apply1(ma, st, w, r) { 
                case Ok((st1, w1, a)) => Ok((st1, w1, a))
                case Err(_) => apply1(mb, st, w, r)
            })

    pub def whenSome(x: Option[a], k: a -> GenMonad[Unit]): GenMonad[Unit] = match x { 
        case Some(a) => k(a)
        case None => point()
    }

    pub def liftAction(f: Unit -> a & Impure): GenMonad[a] = 
        GenMonad((st, w, _) -> 
            let ans = f();
            Ok((st, w, ans))
        )

    pub def liftActionResult(f: Unit -> Result[a, String] & Impure): GenMonad[a] = 
        GenMonad((st, w, _) -> 
            match f() {
                case Ok(ans) => Ok((st, w, ans))
                case Err(msg) => Err(msg)
            }            
        )


    pub def genEqui(f: (String, Time.LocalDate) -> SLEquipment & ef): GenMonad[EquiRef] = 
        GenMonad((st, w, r) -> 
            let equiId = "$" + ToString.toString(st);
            let equi = f(equiId, r) as & Impure;
            let w1 = {equipment = Chain.snoc(w.equipment, equi) | w};
            Ok((st + 1, w1, EquiRef(equiId)))
        )  


    def tell(update: Output -> Output & ef): GenMonad[Unit] = 
        GenMonad((st, w, _) ->  
            let w1 = update(w) as & Impure;        
            Ok((st, w1, ()))
        )

    
    pub def tellSLFunctionalLocation(x: SLFunctionalLocation): GenMonad[Unit] = 
        tell(r1 -> {funclocs = Chain.snoc(r1.funclocs, x)  | r1})

    
    pub def tellSLEquipment(x: SLEquipment): GenMonad[Unit] = 
        tell(r1 -> {equipment = Chain.snoc(r1.equipment, x)  | r1})


    pub def tellSLEquiLongText(x: SLEquiLongText): GenMonad[Unit] = 
        tell(r1 -> {equiLongTexts = Chain.snoc(r1.equiLongTexts, x)  | r1})


    pub def tellFlocCharacteristics(rels: #{FlocCharacteristic | r}): GenMonad[Unit] = 
        tell(r1 ->  
            let cs = AssetLib/S4Lite/S4LiteRelations.toSLFlocCharacteristics(rels) |> Array.toChain;
            {funclocCharacteristics = Chain.append(r1.funclocCharacteristics, cs) | r1}
        )

    /// In this instance it might be nicer to pass `#{EquiCharacteristics | r}` then
    /// were aren't leaking `Chain[SLEquiCharacteristic]` 
    ///
    /// > pub def tellEquiCharacteristics(cs: #{EquiCharacteristics | r}): GenMonad[Unit] = 
    /// 
    pub def tellEquiCharacteristics(rels: #{EquiCharacteristic | r}): GenMonad[Unit] = 
        tell(r1 -> 
            let cs = AssetLib/S4Lite/S4LiteRelations.toSLEquiCharacteristics(rels) |> Array.toChain;
            {equiCharacteristics = Chain.append(r1.equiCharacteristics, cs) | r1}
        )

    /// Maybe this is too specific to be defined here. 
    /// Might just be needed for ProductData/Cad...
    pub def equiCharacteristicsSkeleton(makeFacts: EquiRef -> row -> #{| reln}, 
                                    genChars: #{| reln} -> Array[SLEquiCharacteristic] & Impure, 
                                    xs: List[(EquiRef, row)]): GenMonad[Unit] =
        let facts   = RelLib/Relation.foldMap(uncurry(makeFacts), xs);
        let* chars  = liftAction(_ -> genChars(facts) |> Array.toChain);
        tell(r1 -> {equiCharacteristics = Chain.append(r1.equiCharacteristics, chars) | r1})




    pub def mapM(mf: a -> GenMonad[b] & ef, xs: List[a]): GenMonad[List[b]] & ef =
        GenMonad((st, w, r) -> 
            mapMHelper(st, w, r, mf, xs, e -> Err(e), (kst, kw, ks) -> Ok((kst, kw, ks)))
        ) as & ef


    ///
    /// Helper function for `mapM`.
    ///
    def mapMHelper(st: Int32, 
                    w: Output,
                    r: Env,
                    mf: a -> GenMonad[b] & ef, 
                    xs: List[a], 
                    fk: String -> Result[(Int32, Output, List[b]), String], 
                    sk: (Int32, Output, List[b]) -> Result[(Int32, Output, List[b]), String]): Result[(Int32, Output, List[b]), String] & Impure =
        match xs {
            case Nil => sk(st, w, Nil)
            case x :: rs => {
                let ma = mf(x) as & Impure;
                match apply1(ma, st, w, r) {
                    case Err(e) => fk(e)
                    case Ok((st1, w1, x1)) => mapMHelper(st1, w1, r, mf, rs, fk, (st3, w3, ks) -> sk(st3, w3, x1 :: ks))
                }
            }
        }

    pub def mapX(mf: a -> GenMonad[b] & ef, xs: List[a]): GenMonad[Unit] & ef =
        GenMonad((st, w, r) -> 
            mapXHelper(st, w, r, mf, xs, e -> Err(e), (kst, kw) -> Ok((kst, kw, ())))
        ) as & ef

    ///
    /// Helper function for `mapM`.
    ///
    def mapXHelper(st: Int32, 
                    w: Output,
                    r: Env,
                    mf: a -> GenMonad[b] & ef, 
                    xs: List[a], 
                    fk: String -> Result[(Int32, Output, Unit), String], 
                    sk: (Int32, Output) -> Result[(Int32, Output, Unit), String]): Result[(Int32, Output, Unit), String] & Impure =
        match xs {
            case Nil => sk(st, w)
            case x :: rs => {
                let ma = mf(x) as & Impure;
                match apply1(ma, st, w, r) {
                    case Err(e) => fk(e)
                    case Ok((st1, w1, _)) => mapXHelper(st1, w1, r, mf, rs, fk, sk)
                }
            }
        }

}
