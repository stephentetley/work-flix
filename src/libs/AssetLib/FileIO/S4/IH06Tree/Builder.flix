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


namespace AssetLib/FileIO/S4/IH06Tree/Builder {
        
    use Data.{RoseTree, RoseForest};
    use Data.RoseTree.{Node};

    use AssetLib/FileIO/S4/IH06Tree/Datatypes.{IH06File, IH06Row, IH06Tree, IH06Node, FlocRow, EquiRow};
    use AssetLib/FileIO/S4/IH06Tree/Datatypes.IH06Row.{FlocRow, EquiRow};
    use AssetLib/FileIO/S4/IH06Tree/Datatypes.IH06Node.{FlocNode, EquiNode};

    
    pub def buildIH06Tree(src: IH06File): Result[IH06Tree, String] = match src.rows { 
        case r1 :: _ => { 
            let parent = Option.getWithDefault("", getParentId(r1));
            match treesList(parent, src.rows, (xs, _) -> xs) {
                case x1 :: Nil => Ok(x1)
                case _ :: _ => Err("buildIH06Trees - more than one tree")
                case Nil => Err("buildIH06Trees - no tree")
            }
        }
        case Nil => Err("buildIH06Trees - Empty Structure List")
    }
        
    pub def readTree(src: System.FilePath): Result[IH06Tree, String] & Impure = 
        use Result.{flatMap};
        let* ast = AssetLib/FileIO/S4/IH06Tree/Parser.parseFileWithBOM(src);
        buildIH06Tree(ast)

    def getParentId(row: IH06Row): Option[String] = match row {
        case FlocRow(r1) => Some(r1.parent)
        case _           => None
    }

    def makeFlocNode(row: FlocRow): IH06Node = 
        let level = getLevel(row.floc);
        FlocNode({ +level = level | row })
    
    def makeEquiNode(row: EquiRow): IH06Node = 
        let level = getLevel(row.floc);
        EquiNode({ +level = level | row })

    def getLevel(floc: String): Int32 = 
        use AssetLib/Base/S4/Floc.{new, level};
        Result.getWithDefault(Result.map(level, new(floc)), 0)


    def isChildNodeFloc(parentId: String, parentPointer: String): Bool = 
        parentId == parentPointer

    def isChildNodeEqui(parentId: String, parentFloc: String, parentPointer: String): Bool = 
        if (parentFloc == parentId)
            true
        else 
            parentId == parentPointer


    /// In CPS ...
    /// This is preorder builder with unlimited depth and each row is either Floc or Equi.
    /// We have to check links in the data whether to go up or down.
    def treesList(parentId: String, xs: List[IH06Row], k: (List[IH06Tree], List[IH06Row]) -> List[IH06Tree]): List[IH06Tree] =
        match xs { 
            case FlocRow(r1) :: rest => {
                if (isChildNodeFloc(parentId, r1.parent))
                    treesList(r1.floc, rest, (kids, rest1) -> {
                        let label = makeFlocNode(r1);
                        let node = Node(label, kids);
                        treesList(parentId, rest1, (siblings, rest2) -> k(node :: siblings, rest2))
                    })
                else
                    k(Nil, xs)
            }
            case EquiRow(r1) :: rest => {
                if (isChildNodeEqui(parentId, r1.floc, r1.superordinate))
                    treesList(r1.equiId, rest, (kids, rest1) -> {
                        let label = makeEquiNode(r1);
                        let node = Node(label, kids);
                        treesList(parentId, rest1, (siblings, rest2) -> k(node :: siblings, rest2))
                    })
                else
                    k(Nil, xs)
            }
            case Nil => k(Nil, Nil)
        }

    /// Print Html via a rose tree

    pub type alias Label = {name :: String, description :: String}


    pub def toLabelledTree(src: IH06Tree): RoseTree[Label] = 
        Data/RoseTree.map(makeRTLabel, src)

        
    def makeRTLabel(x: IH06Node): Label = match x {
        case FlocNode(r) => {name = Int32.toString(r.level) + ": " + r.floc, description = r.description}
        case EquiNode(r) => {name = Int32.toString(r.level) + ": " + r.equiId, description = r.description}
    }

}