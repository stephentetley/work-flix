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

/// Probably this will go in a new project / repository...

namespace AutoLifting/Base {

    pub enum Delta[dt] { 
        case Same
        case Diff(Nel[dt])
    }


}

namespace AutoLifting/Base/Delta {


    use AutoLifting/Base.Delta;
    use AutoLifting/Base.Delta.{Same, Diff};

    pub def difference(delta: dt): Delta[dt] = Diff(Nel.singleton(delta))

    pub def same(): Delta[e] = Same    

    ///
    /// Monoidal...
    ///
    pub def append(x1: Delta[e], x2: Delta[e]): Delta[e] = match (x1, x2) {
        case (a, Same) => a
        case (Same, b) => b
        case (Diff(dt1), Diff(dt2)) => Diff(Nel.append(dt1, dt2))
    }

    pub def diff(cmp: (a, a) -> Bool, x: a, y: a, delta: dt): Delta[dt] = 
        use Data/Transient/DList.{empty, singleton};
        if (cmp(x,y)) 
            same()
        else 
            difference(delta)

    /// Diff types that can use builting equality...
    pub def diffEquals(x: a, y: a, delta: dt): Delta[dt] = diff((a,b) -> a == b, x, y, delta)

    pub def diffOption(cmp: (a, a) -> Bool, x: Option[a], y: Option[a], delta: d): Delta[d] = 
        match (x, y) { 
            case (Some(x1), Some(y1))   => diff(cmp, x1, y1, delta)
            case (None,     None)       => same()
            case (_, _)                 => difference(delta)
        }

    ///
    /// Returns `Fail(Nel.map(f, xs))` if `x` is `Fail(xs)`. Otherwise returns `Pass`.
    ///
    pub def mapDeltas(f: dt1 -> dt2 & ef, x: Delta[dt1]): Delta[dt2] & ef = match x {
        case Same => Same
        case Diff(xs) => Diff(Nel.map(f, xs))
    }

    ///
    /// Returns `Fail(f(xs))` if `x` is `Fail(xs)`. Otherwise returns `Pass`.
    ///
    pub def collectDeltas(f: List[dt1] -> dt2 & ef, x: Delta[dt1]): Delta[dt2] & ef = match x {
        case Same => Same
        case Diff(xs) => { 
            let d2 = f(Nel.toList(xs));
            Diff(Nel.singleton(d2))
        }
    }



}


