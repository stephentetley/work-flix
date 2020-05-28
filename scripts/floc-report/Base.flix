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

namespace FlocReport/Base {


    pub def foldLines(f: ac -> TextParser.Parser[ac], ac: ac, path: Path): Result[ac, String] & Impure = 
        match Path.readLines(path) {
            case Err(_) => Err("io error")
            case Ok(xs) => foldLinesHelper(f, ac, xs)    
        }

    def foldLinesHelper(f: ac -> TextParser.Parser[ac], ac: ac, xs: List[String]): Result[ac, String] = 
        match xs { 
            case Nil => Ok(ac)
            case x :: rs => 
                match TextParser.runs(f(ac), x) {
                    case Err(msg) => Err(msg)
                    case Ok(ac1) => foldLinesHelper(f, ac1, rs)
                }
        }

    pub def foreachLines(p: TextParser.Parser[a], fn: a -> Unit & Impure, path: Path): Result[Unit, String] & Impure = 
        match Path.readLines(path) {
            case Err(_) => Err("io error")
            case Ok(xs) => foreachLinesHelper(p, fn, xs)    
        }

    def foreachLinesHelper(p: TextParser.Parser[a], fn: a -> Unit & Impure, xs: List[String]): Result[Unit, String] & Impure = 
        match xs { 
            case Nil => Ok()
            case x :: rs => 
                match TextParser.runs(p, x) {
                    case Err(msg) => Err(msg)
                    case Ok(a) => { fn(a); foreachLinesHelper(p, fn, rs) }
                }
        }



}