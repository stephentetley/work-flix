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

use System.Error.{IllegalArgumentException, Generic};

use AssetLib/S4/ChangeFile.DataRowEvaluator;
use AssetLib/S4/Hierarchy/Relations.{Node, Root, Child};

namespace AssetLib/S4/Hierarchy/BuildHierarchy {


    def getRoot[r](): #{ Root, Node | r } = #{
        Root(id, desc, parent) :- Node(id, desc, parent), not Node(parent, _, _).
    }

    def rootName(src: (String, String, String)): String= 
        let (name, _, _) = src;
        name

    pub def getRoots[r](db: #{ Root, Node | r }): List[String] = 
        fold Root Nil ((x,ac) -> rootName(x) :: ac) (solve getRoot() <+> db)

    
    pub def children[r](start: String): #{ Child, Node | r } = #{
        Child(id, desc) :- Node(id, desc, parent), Node(parent, _, _), if parent == start.
    }

}