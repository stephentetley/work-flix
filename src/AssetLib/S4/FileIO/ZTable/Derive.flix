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
    rel Up(structure: String, child: String, parent: String, level: Int32)

    // TODO count up

    pub def flocLevel[r](db: #{ Floobjl, Up, Level | r}, sturucture: String, start: String): #{Level} = 
        let rules = #{
            /// SITE 'is' 1
            Up(struct, sub, super, 2) :- Floobjl(struct, super, sub), if super == "SITE".
            Up(struct, sub, super, i+1) :- Floobjl(struct, x, sub), Up(struct, x, super, i).
        };
        project Level (solve (rules <+> db <+> #{ Level(s1, x) :- Up(struct1, s1, p, x), if s1 == start && struct1 == sturucture. }))

    rel Linked(child: String, parent: String)

    pub def validChild[r](db: #{ Floobjl, Linked | r}, start: String): Bool = 
        let rules = #{
            Linked(sub, super) :- Floobjl(_, super, sub).
            Linked(sub, super) :- Floobjl(_, x, sub), Linked(x, super).
        };
        (solve rules <+> db) |= Linked(start, "SITE").

}