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

use Data.{RoseTree, RoseForest};
use Data.RoseTree.{RoseTree};
use System.Error.{IllegalArgumentException, Generic};


use AssetLib/S4/Hierarchy/Relations.{Node, Root, Child};

namespace AssetLib/S4/Hierarchy/BuildHierarchy {


    type alias Label = {name: String, description: String}

    pub def allTrees[r](db: #{ Child, Root, Node | r}): RoseForest[Label] = 
        let xs = getRoots(db);
        List.map(x -> buildRoseTree(x, db), xs)

    pub def buildRoseTree[r](root: Label, db: #{ Child, Node | r}): RoseTree[Label] = 
        buildRoseTreeHelper(root, db, identity)

    def buildRoseTreeHelper[r](root: Label, db: #{ Child, Node | r}, k: RoseTree[Label] -> RoseTree[Label]): RoseTree[Label] = 
        let start = root.name;
        let kids = getChildLabels(start, db);
        buildRoseForest(kids, db, ks -> k(RoseTree(root, ks)))

    def buildRoseForest[r](nodes: List[Label], db: #{ Child, Node | r}, k: List[RoseTree[Label]] -> RoseTree[Label]): RoseTree[Label] = 
        match nodes { 
            case Nil => k(Nil)
            case x :: rs => buildRoseTreeHelper(x, db, v1 -> buildRoseForest(rs, db, vs -> k(v1 :: vs)))
        }


    def getRoot[r](): #{ Root, Node | r } = #{
        Root(id, desc, parent) :- Node(id, desc, parent), not Node(parent, _, _).
    }

    def rootToLabel(src: (String, String, String)): Label = 
        let (name, descr, _) = src;
        { name = name, description = descr }

    def childToLabel(src: (String, String)): Label = 
        let (name, descr) = src;
        { name = name, description = descr }

    pub def getRoots[r](db: #{ Root, Node | r }): List[Label] = 
        fold Root Nil ((x,ac) -> rootToLabel(x) :: ac) (solve getRoot() <+> db)

    
    def children[r](start: String): #{ Child, Node | r } = #{
        Child(id, desc) :- Node(id, desc, parent), Node(parent, _, _), if parent == start.
    }

    pub def getChildLabels[r](start: String, db: #{ Child, Node | r }): List[Label] = 
        fold Child Nil ((x,ac) -> childToLabel(x) :: ac) (solve children(start) <+> db)

}