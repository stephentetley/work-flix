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

    // type alias Checker[a, e] = a -> Check[e]

}

namespace Data/Check {



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
    /// Returns ...
    ///
    pub def concat(xs: List[Check[e]]): Check[e] = 
        List.foldLeft(append, Pass, xs)

    ///
    /// Returns `Pass` if each of `f(xs_i)` is `Pass`.
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
            case Fail(e1) => traverseHelperFail(f, rs, e1, ks -> Fail(ks))
        }
    }

    ///
    /// Helper function for `traverse`.
    ///
    /// Precondition: at least one Failure has been encountered (initially `ac1`).
    ///
    def traverseHelperFail(f: a -> Check[e] & ef, xs: List[a], ac1: Nel[e], fk: Nel[e] -> Check[e]): Check[e] & ef = match xs {
        case Nil        => fk(ac1)
        case x :: rs    => match f(x) {
            case Pass(_) => traverseHelperFail(f, rs, ac1, fk)
            case Fail(es) => traverseHelperFail(f, rs, es, ks -> fk(Nel.append(ac1, ks)))
        }
    }

    ///
    /// Returns `Pass` if each of `f(xs_i)` is `Pass`.
    ///
    /// Otherwise returns `Failure(e1 :: ... :: en)` with all of the failures concatenated.
    ///
    pub def traverseWithIndex(f: (a, Int32) -> Check[e] & ef, xs: List[a]): Check[e] & ef =
        traverseWithIndexHelperPass(f, 0, xs)

    ///
    /// Helper function for `traverse`.
    ///
    /// Precondition: no Failure has been encountered.
    ///
    def traverseWithIndexHelperPass(f: (a, Int32) -> Check[e] & ef, ix: Int32, xs: List[a]): Check[e] & ef = match xs {
        case Nil        => Pass
        case x :: rs    => match f(x, ix) {
            case Pass => traverseWithIndexHelperPass(f, ix + 1, rs)
            case Fail(e1) => traverseWithIndexHelperFail(f, ix + 1, rs, e1, ks -> Fail(ks))
        }
    }

    ///
    /// Helper function for `traverse`.
    ///
    /// Precondition: at least one Failure has been encountered (initially `ac1`).
    ///
    def traverseWithIndexHelperFail(f: (a, Int32) -> Check[e] & ef, 
                                    ix: Int32, 
                                    xs: List[a], 
                                    ac1: Nel[e], 
                                    fk: Nel[e] -> Check[e]): Check[e] & ef = match xs {
        case Nil        => fk(ac1)
        case x :: rs    => match f(x, ix) {
            case Pass(_) => traverseWithIndexHelperFail(f, ix + 1, rs, ac1, fk)
            case Fail(es) => traverseWithIndexHelperFail(f, ix + 1, rs, es, ks -> fk(Nel.append(ac1, ks)))
        }
    }




}


