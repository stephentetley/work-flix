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

namespace AssetLib/FileIO/PDT {

    pub opaque type PDTEvaluator[a] = Map[String, String] ~> Result[a, String]
}

namespace AssetLib/FileIO/PDT/PDTEvaluator {

    use AssetLib/FileIO/PDT.PDTEvaluator;
    use AssetLib/FileIO/PDT.PDTEvaluator.{PDTEvaluator};

    pub def return(x: a): PDTEvaluator[a] = 
        PDTEvaluator(_ -> Ok(x) as & Impure)

    def apply1(x: PDTEvaluator[a], attrs: Map[String, String]): Result[a, String] & Impure =
        let PDTEvaluator(f) = x;
        f(attrs)

    pub def throwError(msg: String): PDTEvaluator[a] =
        PDTEvaluator(_ -> Err(msg) as & Impure)

    pub def swapError(ma: PDTEvaluator[a], msg: String): PDTEvaluator[a] =
        PDTEvaluator(attrs ->
            match apply1(ma, attrs) {
                case Ok(a) => Ok(a)
                case Err(_) => Err(msg)
            }
        )

    pub def map(f: a -> b & ef, x: PDTEvaluator[a]): PDTEvaluator[b] =
        PDTEvaluator(attrs ->
            match apply1(x, attrs) {
                case Ok(a) => {
                    let ans = f(a) as & Impure;
                    Ok(ans)
                }
                case Err(e) => Err(e)
            }
        )

    pub def ap(mf: PDTEvaluator[a -> b & ef], ma: PDTEvaluator[a]): PDTEvaluator[b] =
        PDTEvaluator(attrs ->
            match apply1(mf, attrs) {
                case Ok(f) => {
                    match apply1(ma, attrs) {
                        case Ok(a) => Ok(f(a) as & Impure)
                        case Err(e2) => Err(e2)
                    }
                }
                case Err(e1) => Err(e1)
            }
        )

    
    pub def seqLeft(ma: PDTEvaluator[a], mb: PDTEvaluator[b]): PDTEvaluator[a] = 
        PDTEvaluator(attrs ->
            match apply1(ma, attrs) { 
                case Ok(a) => match apply1(mb, attrs) {
                    case Ok(_) => Ok(a)
                    case Err(e) => Err(e)
                }
                case Err(e) => Err(e)
            }
        )

    pub def seqRight(ma: PDTEvaluator[a], mb: PDTEvaluator[b]): PDTEvaluator[b] = 
        PDTEvaluator(attrs ->
            match apply1(ma, attrs) { 
                case Ok(_) => apply1(mb, attrs)
                case Err(e) => Err(e)
            }
        )

    pub def bind(x: PDTEvaluator[a], k: a -> PDTEvaluator[b]): PDTEvaluator[b] =
        PDTEvaluator(attrs ->
            match apply1(x, attrs) {
                case Ok(a) => apply1(k(a), attrs)
                case Err(e) => Err(e)
            }
        )

    pub def flatMap(k: a -> PDTEvaluator[b], x: PDTEvaluator[a]): PDTEvaluator[b] = bind(x, k)

    pub def kleisliLeft(f1: a -> PDTEvaluator[b], f2: b -> PDTEvaluator[c], x: a): PDTEvaluator[c] =
        PDTEvaluator(attrs -> 
            match apply1(f1(x), attrs) { 
                case Ok(b) => apply1(f2(b), attrs)
                case Err(e) => Err(e)
            }
        )

    pub def kleisliRight(f1: b -> PDTEvaluator[c], f2: a -> PDTEvaluator[b], x: a): PDTEvaluator[c] =
        kleisliLeft(f2, f1, x)

    pub def optional(x: PDTEvaluator[a]): PDTEvaluator[Option[a]] =
        PDTEvaluator(attrs ->
            match apply1(x, attrs) {
                case Ok(a) => Ok(Some(a))
                case Err(_) => Ok(None)
            }
        )

    pub def liftAction(fn: Unit ~> a): PDTEvaluator[a] =
        PDTEvaluator(_ -> let x = fn(); Ok(x))

    pub def liftOption(x: Option[a],  errMsg: String): PDTEvaluator[a] = match x { 
        case Some(x1) => return(x1)
        case None => throwError(errMsg)
    }

    pub def liftResult(x: Result[a, String]): PDTEvaluator[a] =
        PDTEvaluator(_-> x as & Impure)

    pub def liftActionResult(fn: Unit ~> Result[a, String] ): PDTEvaluator[a] =
        PDTEvaluator(_ -> fn())



    pub def getStringNamed(label: String): PDTEvaluator[String] =
        PDTEvaluator(attrs ->
            match Map.get(label, attrs) {
                case Some(s) => Ok(s)
                case None => Err("getStringNamed('${label}') - label not found")
            } as & Impure
        )


}
