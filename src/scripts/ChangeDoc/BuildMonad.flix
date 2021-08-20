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

namespace ChangeDoc {
    use ChangeDoc/Interpreter.{State => Changes};

    pub opaque type BuildMonad[a] = Changes ~> Result[a, String]
}

namespace ChangeDoc/BuildMonad {
    
    use ChangeDoc.{BuildMonad};
    use ChangeDoc.BuildMonad.{BuildMonad};

    use ChangeDoc/Datatypes.{ChangeKey, EntityType, ValueState, Origin};
    use ChangeDoc/Datatypes.ChangeKey.{NameKey, ClassKey, 
        AttrKey, ValuaKey, AddrAttrKey};
    use ChangeDoc/Datatypes.Origin.{Direct, HSuperior, RRef};
    use ChangeDoc/Datatypes.ValueState.{CreateLocal, DeleteLocal, 
        UpdateGlobal, DeleteGlobal};
    use ChangeDoc/Interpreter.{State};


    pub def runBuildMonad(st: State, mx: BuildMonad[a]): Result[a, String] & Impure = 
        apply1(mx, st)
        
    def apply1(x: BuildMonad[a], r: State): Result[a, String] & Impure =
        let BuildMonad(f1) = x;
        f1(r)

    pub def return(x: a): BuildMonad[a] = 
        BuildMonad(_ -> Ok(x) as & Impure)

    pub def map(f: a -> b & ef, x: BuildMonad[a]): BuildMonad[b] =
        BuildMonad(r -> 
            match apply1(x, r) {
                case Ok(a) => {
                    let ans = f(a) as & Impure;
                    Ok(ans)
                }
                case Err(e) => Err(e)
            }
        )  


    pub def ap(mf: BuildMonad[a -> b & ef], ma: BuildMonad[a]): BuildMonad[b] = 
        BuildMonad(r -> 
            match apply1(mf, r) {
                case Ok(f) => 
                    match apply1(ma, r) { 
                        case Ok(a) => {let ans = f(a) as & Impure; Ok(ans)}
                        case Err(e) => Err(e)
                    }
                case Err(e) => Err(e)
            })

    pub def bind(x: BuildMonad[a], k: a -> BuildMonad[b]): BuildMonad[b] = 
        BuildMonad(r -> 
            match apply1(x, r) {
                case Ok(a) => { let ans = k(a); apply1(ans, r) }
                case Err(e) => Err(e)
            }
        )

    pub def flatMap(k: a -> BuildMonad[b], x: BuildMonad[a]): BuildMonad[b] = bind(x, k)


    /// Alias for `ap`
    pub def <*>(p1: BuildMonad[a -> b], p2: BuildMonad[a]): BuildMonad[b] = ap(p1, p2)

    /// Haskell's <$>
    pub def <&>(f: a -> b, p2: BuildMonad[a]): BuildMonad[b] =
        map(f, p2)


    pub def getAttrString(entype: EntityType, flocId: String, name: String): BuildMonad[String] = 
        BuildMonad(r ->
            match Map.get(AttrKey(entype, flocId, name), r) { 
                case Some(CreateLocal(x1)) => Ok(x1)
                case Some(UpdateGlobal(x1)) => Ok(x1)
                case _ => Ok("")
            } as & Impure)



    pub def getAttrOrigin(entype: EntityType, flocId: String, name: String): BuildMonad[Option[Origin]] =
        BuildMonad(r -> 
            match Map.get(AttrKey(entype, flocId, name), r) { 
                case Some(CreateLocal(x1)) => Ok(decodeOrigin(x1))
                case Some(UpdateGlobal(x1)) => Ok(decodeOrigin(x1))
                case _ => Ok(None)
            } as & Impure)

    def decodeOrigin(x: String): Option[Origin] = match x { 
        case "D" => Some(Direct)
        case "H" => Some(HSuperior)
        case "R" => Some(RRef)
        case _ => None
    }

}
