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

opaque type FuncLoc = String

namespace FlocReport/FuncLoc {

    pub def new(path: String): FuncLoc = FuncLoc(path)

    pub def level(floc: FuncLoc): Int32 = 
        let FuncLoc(path) = floc;
        if (String.length(path) > 0)
            stringFoldLeft((ac, ch) -> if (ch == '-') ac+1 else ac, 1, path)
        else 0




    /// Pending addition to stdlib....


    ///
    /// Applies `f` to a start value `x` and all elements in `s` going from left to right.
    ///
    def stringFoldLeft(f: (b, Char) -> b, x: b, s: String): b =
        let len = String.length(s);
        foldLeftHelper(f, x, len, s, 0)

    ///
    /// Helper function for `foldLeft`.
    ///
    def foldLeftHelper(f: (b, Char) -> b, x: b, len: Int32, s: String, i: Int32): b =
        if (i >= len)
            x
        else {
            let x1 = f(x, String.charAt(i, s));
            foldLeftHelper(f, x1, len, s, i+1)
        }


}