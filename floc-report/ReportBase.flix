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

namespace ReportBase {

    pub def foreach(f: a -> Unit, xs: List[a]): Unit = match xs {
        case Nil => ()
        case x :: rs => { f(x); foreach(f, rs) }
    }

    pub def foldLines(f: ac -> TextParser.Parser[ac], ac: ac, path: Path): Result[ac, String] = 
        match Path.readLines(path) {
            case Err(_) => Err("io error")
            case Ok(xs) => foldLinesHelper(f, ac, xs)    
        }

    def foldLinesHelper(f: ac -> TextParser.Parser[ac], ac: ac, xs: List[String]): Result[ac, String] = 
        match xs { 
            case Nil => Ok(ac)
            case x :: rs => 
                match TextParser.run(f(ac), x) {
                    case Err(msg) => Err(msg)
                    case Ok(ac1) => foldLinesHelper(f, ac1, rs)
                }
        }

    pub def foreachLines(f: TextParser.Parser[Unit], path: Path): Result[Unit, String] = 
        match Path.readLines(path) {
            case Err(_) => Err("io error")
            case Ok(xs) => foreachLinesHelper(f, xs)    
        }

    def foreachLinesHelper(f: TextParser.Parser[Unit], xs: List[String]): Result[Unit, String] = 
        match xs { 
            case Nil => Ok()
            case x :: rs => 
                match TextParser.run(f, x) {
                    case Err(msg) => Err(msg)
                    case Ok() => foreachLinesHelper(f, rs)
                }
        }



}