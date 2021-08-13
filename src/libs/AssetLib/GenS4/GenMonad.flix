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
    pub opaque type GenMonad[a] = (Int32, Output, AssetLib/GenS4/GenMonad.Env) ~> Result[(Int32, Output, a), String]
}

namespace AssetLib/GenS4/GenMonad {

    use AssetLib/S4Lite/Datatypes.{SLEquipment, SLEquiLongText, SLEquiCharacteristic};
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3};
    use AssetLib/GenS4.GenMonad;
    use AssetLib/GenS4.GenMonad.{GenMonad};


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

    pub def return(x: a): GenMonad[a] = 
        GenMonad((st, w, _) -> Ok((st, w, x)) as & Impure)

    def apply1(x: GenMonad[a], st: Int32, w: Output, r: Env): Result[(Int32, Output, a), String] & Impure =
        let GenMonad(f) = x;
        f(st, w, r)

    pub def map(f: a -> b & ef, x: GenMonad[a]): GenMonad[b] =
        GenMonad((st, w, r) -> 
            match apply1(x, st, w, r) {
                case Ok((st1, w1, a)) => {
                    let ans = f(a) as & Impure;
                    Ok((st1, w1, ans))
                }
                case Err(e) => Err(e)
            }
        )  

    pub def bind(x: GenMonad[a], k: a -> GenMonad[b]): GenMonad[b] = 
        GenMonad((st, w, r) -> 
            match apply1(x, st, w, r) {
                case Ok((st1, w1, a)) => { let ans = k(a); apply1(ans, st1, w1, r) }
                case Err(e) => Err(e)
            }
        )

    pub def flatMap(k: a -> GenMonad[b], x: GenMonad[a]): GenMonad[b] = bind(x, k)


    pub def genEqui(f: (String, Time.LocalDate) -> SLEquipment & ef): GenMonad[EquiRef] = 
        GenMonad((st, w, r) -> 
            let equiId = "$" + ToString.toString(st);
            let equi = f(equiId, r) as & Impure;
            let w1 = {equipment = Chain.snoc(w.equipment, equi) | w};
            Ok((st + 1, w1, EquiRef(equiId)))
        )  


    pub def liftAction(f: Unit ~> a): GenMonad[a] = 
        GenMonad((st, w, _) -> 
            let ans = f() as & Impure;
            Ok((st, w, ans))
        )


    pub def appendCharacteristics(cs: Chain[SLEquiCharacteristic]): GenMonad[Unit] = 
        GenMonad((st, w, _) ->  
            let w1 = {characteristics = Chain.append(w.characteristics, cs) | w} as & Impure;        
            Ok((st, w1, ()))
        )
}
