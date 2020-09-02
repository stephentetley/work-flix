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

use AssetLib/Aib/FileIO/TreeExport/Raw/Datatypes.{AibTreeFile, AibRow, AibTree, AibNode};

namespace AssetLib/Aib/FileIO/TreeExport/Raw/Builder {
    

    /// Caller supplies level as it might not be site (level 1).
    pub def buildAibTrees(src: AibTreeFile, level: Int32): List[AibTree] = 
        treesList(level, "", "", src, (xs,_ ) -> xs)

    /// In CPS ...
    /// This is preorder builder with unlimited depth and all nodes the same type.
    /// We have to check if commonName is longer or shorter to decided whether to
    /// go up or down
    def treesList(level: Int32, parent: String, parentCommonName: String, xs: List[AibRow], k: (List[AibTree], List[AibRow]) -> List[AibTree]): List[AibTree] = 
        match xs { 
            case r1 :: rest => {
                if (String.startsWith(r1.commonName, parentCommonName))
                    treesList(level + 1, r1.reference, r1.commonName, rest, (kids, rest1) -> {
                        let label = makeAibNode(level, parent, parentCommonName, r1);
                        let node = RoseTree(label, kids);
                        treesList(level, parent, parentCommonName, rest1, (siblings, rest2) -> k(node :: siblings, rest2))
                    })
                else
                    k(Nil, xs)
            }
            case Nil => k(Nil, Nil)
        }

    def makeAibNode(level: Int32, parent: String, parentCommonName: String, row: AibRow): AibNode = 
        use Option.{getWithDefault};
        let short = String.stripPrefix(parentCommonName + "/", row.commonName).getWithDefault(row.commonName);
        { reference = row.reference, level = level, shortName = short, parent = parent, commonName = row.commonName }

    
    /// Print Html via a rose tree

    type alias Label = {name: String, description: String}

    pub def allTrees(src: List[AibTree]): RoseForest[Label] = 
        List.map(Data/RoseTree.map(makeRTLabel), src)
        
    def makeRTLabel(x: AibNode): Label = 
        {name = Int32.toString(x.level) + ": " + x.reference, description = x.shortName}
        

}