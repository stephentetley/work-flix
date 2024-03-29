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

namespace Aruba/S4/Import/GenWorkList {

    use Functor.{<$>};
    use Applicative.{<*>};

    use SheetIO.NamedRowEvaluator;
    use Compatibility.{XlsxSource};

    use Aruba/S4/Base.{S4Floc, S4Equi, S4SubFloc, S4EquiLocation, S4SubEqui, S4FlocLevel};
    use Aruba/S4/Hierarchy.{Site, Function, ProcessGroup, Process, System, Subsystem, 
        Equipment, ChildFloc, ChildEqui, FunctionalLocation};

    pub rel WorkListFloc(floc: String, description: String, parentFloc: String)

    pub rel WorkListEqui(equiId: String, description: String, floc: String, superEqui: String)

    /// Read from file...

    pub def readFlocWorkList(src: XlsxSource): Result[#{WorkListFloc | r}, String] & Impure =
        SheetIO/Reader.someNamedRelations(evalFlocWorkItem(), src)


    def evalFlocWorkItem(): NamedRowEvaluator[#{WorkListFloc | r}] = 
        use SheetIO/NamedRowEvaluator.{getNonEmptyContentNamed, getTrimmedContentNamed};
        ((x1, x2) -> #{ WorkListFloc(x1, x2, flocParent(x1)). })
            <$> getNonEmptyContentNamed("Functional Location")
            <*> getNonEmptyContentNamed("Description")
            
    pub def readFlocBaseRelations(src: XlsxSource): Result[#{S4Floc, S4Equi, S4SubFloc, S4EquiLocation, S4SubEqui, S4FlocLevel | r}, String] & Impure = 
        readFlocWorkList(src) |> Result.map(toBase)



    pub def readEquiWorkList(src: XlsxSource): Result[#{WorkListEqui | r}, String] & Impure =
        SheetIO/Reader.someNamedRelations(evalEquiWorkItem(), src)

    /// Note - equiId will be an AIB pliref.
    def evalEquiWorkItem(): NamedRowEvaluator[#{WorkListEqui | r}] = 
        use SheetIO/NamedRowEvaluator.{getNonEmptyContentNamed, getTrimmedContentNamed};
        ((x1, x2, x3, x4) -> #{ WorkListEqui(x1, x2, x3, x4). })
            <$> getNonEmptyContentNamed("Reference")
            <*> getNonEmptyContentNamed("S4 Equi Name")
            <*> getNonEmptyContentNamed("S4 Floc")
            <*> getTrimmedContentNamed("Super Equi")


    pub def readEquiBaseRelations(src: XlsxSource): Result[#{S4Floc, S4Equi, S4SubFloc, S4EquiLocation, S4SubEqui, S4FlocLevel | r}, String] & Impure = 
        readEquiWorkList(src) |> Result.map(toBase)


    /// To Base representation

    pub def toBase(input: #{WorkListFloc, WorkListEqui | r}): #{S4Floc, S4Equi, S4SubFloc, S4EquiLocation, S4SubEqui, S4FlocLevel | r1} =
        let rules = #{

            S4Floc(floc, description) :- 
                WorkListFloc(floc, description, _).

            S4Equi(equiId, description) :- 
                WorkListEqui(equiId, description, _, _).

            S4SubFloc(parent, floc) :- 
                WorkListFloc(floc, _, parent), 
                if not String.isEmpty(parent).
            
            
            S4EquiLocation(equiId, floc) :- 
                WorkListEqui(equiId, _, floc, _).

            S4SubEqui(parent, child) :- 
                WorkListEqui(child, _, _, parent), 
                if not String.isEmpty(parent).
            
            S4FlocLevel(floc, Option.getWithDefault(-1, flocLevel(floc))) :- 
                WorkListFloc(floc, _, _), 
                if not Option.isEmpty(flocLevel(floc)).
            
        };
        let input1 = input as #{WorkListFloc, WorkListEqui, S4Floc, S4Equi, S4SubFloc, S4EquiLocation, S4SubEqui, S4FlocLevel};
        solve (rules <+> input1) project S4Floc, S4Equi, S4SubFloc, S4EquiLocation, S4SubEqui, S4FlocLevel

    def flocLevel(s: String): Option[Int32] = 
        use AssetLib/Base/S4/Floc.{floc, level};
        floc(s)
            |> Result.map(level)
            |> Result.toOption

    def flocParent(s: String): String = 
        use AssetLib/Base/S4/Floc.{floc, parent};
        match floc(s) {
            case Ok(x1) => parent(x1) |> Option.map(ToString.toString) |> Option.getWithDefault("")
            case Err(_) => ""
        }

}
