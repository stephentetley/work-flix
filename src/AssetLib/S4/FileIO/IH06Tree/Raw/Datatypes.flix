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
use Time.LocalDate;

namespace AssetLib/S4/FileIO/IH06Tree/Raw/Datatypes {

    /// Flat representation - not a tree.
    type alias IH06File = { header: Header, rows: List[IH06Row] }

    type alias Header =  { floc: String, description: String, validForm: LocalDate }

    pub enum IH06Row {
        case FlocRow(FlocRow),
        case EquiRow(EquiRow)
    }

    /// Empty string for no parent
    type alias FlocRow = { floc: String, description: String, parent: String }

    /// Empty string for no super
    type alias EquiRow = { equiId: String, description: String, floc: String, superordinate: String }




    /// Nested representation.
    /// With IH06 imports we don't have any more structure than a RoseTree so 
    /// we use a RoseTree.
    type alias IH06Tree = RoseTree[IH06Node]

    pub enum IH06Node {
        case FlocNode(FlocNode)
        case EquiNode(EquiNode)
    }

    type alias FlocNode = { level: Int32, floc: String, description: String, parent: String }
    type alias EquiNode = { level: Int32, equiId: String, description: String, floc: String, superordinate: String }

}