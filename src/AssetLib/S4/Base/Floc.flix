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

use AssetLib/S4/Base.Floc;
use AssetLib/S4/Base.Floc.{Floc};

namespace AssetLib/S4/Base {

    pub opaque type Floc = List[String]

}    

namespace AssetLib/S4/Base/Floc {

    pub def new(s: String): Floc = Floc(String.splitOn(s, "-"))

    pub def toString(x: Floc): String = 
        let Floc(xs1) = x;
        String.intercalate("-", xs1)

    /// level
    pub def level(x: Floc): Int32 = 
        let Floc(xs1) = x;
        List.length(xs1)


    /// suffix
    pub def suffix(x: Floc): Option[String] = 
        let Floc(xs1) = x;
        List.last(xs1)

    /// parent
    pub def parent(x: Floc): Option[Floc] = 
        let Floc(xs1) = x;
        List.init(xs1) |> Option.map(Floc)

}    