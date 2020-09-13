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

// Ideally to go into flix-sandbox... (might be a bit limited)

// Check is the anonymous version of Validation.
// Operationally it is noticeably less useful than Validation (less operations can be supported).


use Data.Check;
use Data.Check.{Pass, Fail};

namespace Data {

    pub enum Check[e] { 
        case Pass
        case Fail(Nel[e])
    }

}

namespace Data {

    // type alias RowFail = { datasetName: String, index: Int32, failures: Nel[String] }

    pub def failure(err: e): Check[e] = Fail(Nel.singleton(err))

    

    pub def checkBool(x: Bool, err: e): Check[e] = if (x) Pass else Fail(Nel.singleton(err))

    pub def checkOption(x: Option[a], err: e): Check[e] = match x { 
        case Some(_) => Pass
        case None  => Fail(Nel.singleton(err))
    }

    pub def fromResult(x: Result[a, e]): Check[e] = match x { 
        case Ok(_) => Pass
        case Err(err) => Fail(Nel.singleton(err))
    }


    pub def isPass(x: Check[e]): Bool = match x {
        case Pass => true
        case Fail(_) => false
    }

    pub def toResult(v: Check[e]): Result[Unit, Nel[e]] = match v {
        case Pass => Ok()
        case Fail(e) => Err(e)
    }

    pub def getErrors(v: Check[e]): List[e] = match v {
        case Pass => Nil
        case Fail(e) => Nel.toList(e)
    }


    ///
    /// Returns `Fail(f(v))` if `o` is `Fail(v)`. Otherwise returns `Pass`.
    ///
    pub def map(f: e1 -> e2 & ef, x: Check[e1]): Check[e2] & ef = match x {
        case Pass => Pass
        case Fail(e) => Fail(Nel.map(f, e))
    }

    
    ///
    /// Returns ...
    ///
    pub def append(x1: Check[e], x2: Check[e]): Check[e] = match (x1, x2) {
        case (Pass, b) => b
        case (a, Pass) => a
        case (Fail(e1), Fail(e2)) => Fail(Nel.append(e1, e2))
    }



    ///
    /// Returns `Success(v1 :: v2 :: ... v :: vn)` if each of `f(xs_i)` is `Success(v_i)`.
    ///
    /// Otherwise returns `Failure(e1 :: ... :: en)` with all of the failures concatenated.
    ///
    pub def traverse(f: a -> Check[e] & ef, xs: List[a]): Check[e] & ef =
        traverseHelperPass(f, xs)



    ///
    /// Helper function for `traverse`.
    ///
    /// Precondition: no Failure has been encountered.
    ///
    def traverseHelperPass(f: a -> Check[e] & ef, xs: List[a]): Check[e] & ef = match xs {
        case Nil        => Pass
        case x :: rs    => match f(x) {
            case Pass => traverseHelperPass(f, rs)
            case Fail(e1) => traverseHelperFail(f, rs, e1)
        }
    }

    ///
    /// Helper function for `traverse`.
    ///
    /// Precondition: at least one Failure has been encountered.
    ///
    def traverseHelperFail(f: a -> Check[e] & f, xs: List[a], ac: Nel[e]): Check[e] & f = match xs {
        case Nil        => Fail(ac)
        case x :: rs    => match f(x) {
            case Pass(_) => traverseHelperFail(f, rs, ac)
            case Fail(e1) => traverseHelperFail(f, rs, Nel.append(ac, e1))
        }
    }

    // TODO - a "faster" CPS version without Nel.append is possible


}


