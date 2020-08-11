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

use AssetLib/S4/FileIO/ZTable/Relations.{Floobjl};

namespace AssetLib/S4/FileIO/ZTable/Derive {

    rel Level(id: String, level: Int32)
    rel Up(child: String, parent: String, level: Int32)

    // TODO count up

    pub def flocLevel[r](db: #{ Floobjl, Up, Level | r}, floc1: String): Option[#{Level}] = 
        let p = #{
            Up(sub, "SITE", 1) :- Floobjl(_, "SITE", sub).
            Up(sub, super, i+1) :- Floobjl(_, x, sub), Up(super, x, i).
            
            Level(sub, i) :- Up(sub, _, i).
        };
        let m = solve (db <+> p);
        if (m |= Level(floc1,5).) Some(project Level m) else None

}