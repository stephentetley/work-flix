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

use AssetLib/S4/FileReaders/IH06Tree/Raw/Datatypes.{IH06File, IH06Row, IH06Tree, IH06Node, FlocRow, EquiRow};
use AssetLib/S4/FileReaders/IH06Tree/Raw/Datatypes.IH06Row.{FlocRow, EquiRow};
use AssetLib/S4/FileReaders/IH06Tree/Raw/Datatypes.IH06Node.{FlocNode, EquiNode};

namespace AssetLib/S4/FileReaders/IH06Tree/Raw/Builder {
    
    pub def buildIH06Trees(src: IH06File): List[IH06Tree] = treesList("", src.rows, (xs, _) -> xs)

    def makeFlocNode(row: FlocRow): IH06Node = FlocNode({ floc = row.floc, description = row.description })
    def makeEquiNode(row: EquiRow): IH06Node = EquiNode({ equiId = row.equiId, description = row.description })


    def isChildNodeFloc(parentId: String, parentPointer: Option[String]): Bool = 
        match parentPointer { 
            case Some(x) => x == parentId
            case None => parentId == ""
        }

    def isChildNodeEqui(parentId: String, parentFloc: String, parentPointer: Option[String]): Bool = 
        if (parentFloc == parentId)
            true
        else 
            match parentPointer { 
                case Some(x) => x == parentId
                case None => parentId == ""
            }


    /// In CPS ...
    /// This is preorder builder with unlimited depth and each row is either Floc or Equi.
    /// We have to check links in the data wether to go up or down.
    def treesList(parentId: String, xs: List[IH06Row], k: (List[IH06Tree], List[IH06Row]) -> List[IH06Tree]): List[IH06Tree] = 
        match xs { 
            case FlocRow(r1) :: rest => {
                if (isChildNodeFloc(parentId, r1.parent))
                    treesList(r1.floc, rest, (kids, rest1) -> {
                        let label = makeFlocNode(r1);
                        let node = RoseTree(label, kids);
                        treesList(parentId, rest1, (siblings, rest2) -> k(node :: siblings, rest2))
                    })
                else
                    k(Nil, xs)
            }
            case EquiRow(r1) :: rest => {
                if (isChildNodeEqui(parentId, r1.floc, r1.superordinate))
                    treesList(r1.floc, rest, (kids, rest1) -> {
                        let label = makeEquiNode(r1);
                        let node = RoseTree(label, kids);
                        treesList(parentId, rest1, (siblings, rest2) -> k(node :: siblings, rest2))
                    })
                else
                    k(Nil, xs)
            }
            case _ => k(Nil, Nil)
        }




    /// Print Html via a rose tree

    type alias Label = {name: String, description: String}

    pub def allTrees(src: List[IH06Tree]): RoseForest[Label] = 
        List.map(Data/RoseTree.map(makeRTLabel), src)
        
    def makeRTLabel(x: IH06Node): Label = match x {
        case FlocNode(r) => {name = r.floc, description = r.description}
        case EquiNode(r) => {name = r.equiId, description = r.description}
    }

}