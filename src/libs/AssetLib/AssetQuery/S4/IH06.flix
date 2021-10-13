/*
 * Copyright 2021 Stephen Tetley
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

namespace AssetLib/AssetQuery/S4/IH06 {

    use AssetLib/FileIO/S4/IH06Tree/Datatypes.{IH06File};
    use AssetLib/FileIO/S4/IH06Tree/Datatypes.IH06Row.{FlocRow, EquiRow};
    
    use AssetLib/AssetQuery/Hierarchy.{System, Unit, Equipment, SubEquipment};
    
    

    pub rel IH06Floc(floc: String, description: String, parentFloc: String)

    pub rel IH06Equi(equiId: String, description: String, floc: String, superEqui: String)

    pub def readHierarchyRelations(src: System.FilePath): Result[#{IH06Floc, IH06Equi |r}, String] & Impure = 
        use Result.{flatMap};
        let* ast = AssetLib/FileIO/S4/IH06Tree/Parser.parseFileWithBOM(src);
        buildHierarchyRelations(ast) |> Ok

    pub def buildHierarchyRelations(src: IH06File): #{IH06Floc, IH06Equi | r} = 
        let build1 = x1 -> match x1 {
            case FlocRow(r1) => #{ IH06Floc(r1.floc , r1.description , r1.parent). }
            case EquiRow(r1) => #{ IH06Equi(r1.equiId , r1.description , r1.floc, r1.superordinate). }
        };
        RelLib/Relation.foldMap(build1, src.rows)
        
    pub def buildHierarchy(src: #{IH06Floc, IH06Equi | r}): #{Equipment, SubEquipment | r1} = 
        let rules = #{
            Equipment(equiId, description, floc) :- 
                IH06Equi(equiId, description, floc, _).

            SubEquipment(parent, child) :- 
                IH06Equi(child, _, _, parent), 
                if not String.isEmpty(parent).

        };
        /// Cast stops "output" relation schema types leaking into input relation schema types
        let src1 = src as #{IH06Floc, IH06Equi, Equipment, SubEquipment | r};
        solve (rules <+> src1) project Equipment, SubEquipment

}
