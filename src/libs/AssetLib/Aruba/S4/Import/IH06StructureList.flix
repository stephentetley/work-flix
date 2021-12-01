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

namespace AssetLib/Aruba/S4/Import/IH06StructureList {

    use AssetLib/FileIO/S4/IH06Tree/Datatypes.{IH06File};
    use AssetLib/FileIO/S4/IH06Tree/Datatypes.IH06Row.{FlocRow, EquiRow};
    
    use AssetLib/Aruba/S4/Base.{S4Floc, S4Equi, S4SubFloc, S4EquiLocation, S4SubEqui, S4FlocLevel};
    use AssetLib/Aruba/S4/Hierarchy.{Site, Function, ProcessGroup, Process, System, Subsystem, 
        MaintainableItem, Equipment, ChildFloc, ChildEqui, FunctionalLocation};
    

    pub rel IH06Floc(floc: String, description: String, parentFloc: String)

    pub rel IH06Equi(equiId: String, description: String, floc: String, superEqui: String)

    /// Read from file...

    pub def readIH06Relations(src: System.FilePath): Result[#{IH06Floc, IH06Equi |r}, String] & Impure = 
        use Result.{flatMap};
        let* ast = AssetLib/FileIO/S4/IH06Tree/Parser.parseFileWithBOM(src);
        buildIH06Relations(ast) |> Ok

    def buildIH06Relations(src: IH06File): #{IH06Floc, IH06Equi | r} = 
        let build1 = x1 -> match x1 {
            case FlocRow(r1) => #{ IH06Floc(r1.floc , r1.description , r1.parent). }
            case EquiRow(r1) => #{ IH06Equi(r1.equiId , r1.description , r1.floc, r1.superordinate). }
        };
        RelLib/Relation.foldMap(build1, src.rows)
        

    pub def readBaseRelations(src: System.FilePath): Result[#{S4Floc, S4Equi, S4SubFloc, S4SubEqui, S4EquiLocation, S4FlocLevel | r}, String] & Impure = 
        readIH06Relations(src) |> Result.map(toBase)

    pub def readHierarchyRelations(src: System.FilePath): Result[#{Site, Function, ProcessGroup, Process, System, Subsystem, 
                                MaintainableItem, Equipment, ChildFloc, ChildEqui, FunctionalLocation | r}, String] & Impure = 
        readBaseRelations(src) |> 
            Result.map(AssetLib/Aruba/S4/Hierarchy.fromS4BaseRelations)


    /// To Base representation

    pub def toBase(input: #{IH06Floc, IH06Equi | r}): #{S4Floc, S4Equi, S4SubFloc, S4SubEqui, S4EquiLocation, S4FlocLevel | r1} =
        let rules = #{

            S4Floc(floc, description) :- 
                IH06Floc(floc, description, _).

            S4Equi(equiId, description) :- 
                IH06Equi(equiId, description, _, _).

            S4SubFloc(parent, child) :- 
                IH06Floc(child, _, parent), 
                if not String.isEmpty(parent).

            S4SubEqui(parent, child) :- 
                IH06Equi(child, _, _, parent), 
                if not String.isEmpty(parent).
            
            S4EquiLocation(equiId, floc) :- 
                IH06Equi(equiId, _, floc, _).
            
            S4FlocLevel(floc, Option.getWithDefault(flocLevel(floc), -1)) :- 
                IH06Floc(floc, _, _), 
                if not Option.isEmpty(flocLevel(floc)).
            
        };
        let input1 = input as #{IH06Floc, IH06Equi, S4Floc, S4Equi, S4SubFloc, S4SubEqui, S4EquiLocation, S4FlocLevel};
        solve (rules <+> input1) project S4Floc, S4Equi, S4SubFloc, S4SubEqui, S4EquiLocation,  S4FlocLevel

    def flocLevel(floc: String): Option[Int32] = 
        use AssetLib/Base/S4/Floc.{level, new};
        new(floc)
            |> Result.map(level)
            |> Result.toOption
            
}
