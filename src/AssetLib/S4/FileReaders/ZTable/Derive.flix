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

use AssetLib/S4/FileReaders/ZTable/Relations.{Floobjl};

namespace AssetLib/S4/FileReaders/ZTable/Derive {

    rel Level(id: String, level: Int32)
    rel Descendant(super: String, sub: String, level: Int32)

    def descendants[r](): #{ Descendant, Floobjl | r } = #{
        Descendant(sub, super, 1) :- Floobjl(_, super, sub).
        Descendant(sub, super, i+1) :- Floobjl(_, x, sub), Descendant(super, x, i).
    }

    pub def flocLevel[r](db: #{ Floobjl, Descendant, Level | r}): #{ Level } = 
        project Level (solve db <+> descendants() <+> #{ Level(x,i) :- Descendant(start, x, i), if start == "SITE". })

}