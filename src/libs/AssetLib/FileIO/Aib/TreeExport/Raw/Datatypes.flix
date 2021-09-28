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

use Data.RoseTree;

namespace AssetLib/FileIO/Aib/TreeExport/Raw/Datatypes {

    /// Flat representation - not a tree.
    type alias AibTreeFile = List[AibRow]

    type alias AibRow = 
        { reference :: String
        , commonName :: String
        , status :: String 
        }
    

    /// Nested representation.
    /// We only have a single node type so a RoseTree is adequate.
    type alias AibTree = RoseTree[AibNode]

    type alias AibNode =
        { reference :: String
        , level :: Int32
        , shortName :: String
        , parent :: String
        , commonName :: String
        , status :: String 
        }

}