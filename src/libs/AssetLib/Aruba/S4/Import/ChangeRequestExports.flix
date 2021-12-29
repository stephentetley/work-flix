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

namespace AssetLib/Aruba/S4/Import/ChangeRequestExports {

    use Functor.{<$>};
    use Applicative.{<*>};

    use SheetIO.NamedRowEvaluator;
    use SheetIO/Reader.{XlsxSource};

    use AssetLib/Aruba/S4/Base.{S4Floc, S4Equi, S4SubFloc, S4EquiLocation, S4SubEqui, S4FlocLevel};
    

    pub rel ExportFlocRow(floc: String, description: String, parentFloc: String)

    pub rel ExportEquiRow(equiId: String, description: String, floc: String, superEqui: String)

    /// Read from file...

    pub def readExportFlocRows(src: XlsxSource): Result[#{ExportFlocRow | r}, String] & Impure =
        SheetIO/Reader.someNamedRelations(evalExportFlocRow(), src)


    def evalExportFlocRow(): NamedRowEvaluator[#{ExportFlocRow | r}] = 
        use SheetIO/NamedRowEvaluator.{getNonEmptyContentNamed, getTrimmedContentNamed};
        ((x1, x2, x3) -> #{ WorkListFloc(x1, x2, x3). })
            <$> getNonEmptyContentNamed("Functional Location")
            <*> getNonEmptyContentNamed("Description")
            <*> getTrimmedContentNamed("Superior FunctLoc.")
            
    pub def readFlocBaseRelations(src: XlsxSource): Result[#{S4Floc, S4Equi, S4SubFloc, S4EquiLocation, S4SubEqui, S4FlocLevel | r}, String] & Impure = 
        readExportFlocRows(src) |> Result.map(toBase)



    pub def readExportEquiRows(src: XlsxSource): Result[#{ExportEquiRow | r}, String] & Impure =
        SheetIO/Reader.someNamedRelations(evalExportEquiRow(), src)

    def evalExportEquiRow(): NamedRowEvaluator[#{ExportEquiRow | r}] = 
        use SheetIO/NamedRowEvaluator.{getNonEmptyContentNamed, getTrimmedContentNamed};
        ((x1, x2, x3, x4) -> #{ ExportEquiRow(x1, x2, x3, x4). })
            <$> getNonEmptyContentNamed("Equipment")
            <*> getNonEmptyContentNamed("Description")
            <*> getNonEmptyContentNamed("Functional Location")
            <*> getTrimmedContentNamed("Superord. Equipment")


    pub def readEquiBaseRelations(src: XlsxSource): Result[#{S4Floc, S4Equi, S4SubFloc, S4EquiLocation, S4SubEqui, S4FlocLevel | r}, String] & Impure = 
        readExportEquiRows(src) |> Result.map(toBase)



    /// To Base representation

    pub def toBase(input: #{ExportFlocRow, ExportEquiRow | r}): #{S4Floc, S4Equi, S4SubFloc, S4EquiLocation, S4SubEqui, S4FlocLevel | r1} =
        let rules = #{

            S4Floc(floc, description) :- 
                ExportFlocRow(floc, description, _).

            S4Equi(equiId, description) :- 
                ExportEquiRow(equiId, description, _, _).

            S4SubFloc(parent, child) :- 
                ExportFlocRow(child, _, parent), 
                if not String.isEmpty(parent).
            
            S4EquiLocation(equiId, floc) :- 
                ExportEquiRow(equiId, _, floc, _).

            S4SubEqui(parent, child) :- 
                ExportEquiRow(child, _, _, parent), 
                if not String.isEmpty(parent).
            
            S4FlocLevel(floc, Option.getWithDefault(-1, flocLevel(floc))) :- 
                ExportFlocRow(floc, _, _), 
                if not Option.isEmpty(flocLevel(floc)).
            
        };
        let input1 = input as #{ExportFlocRow, ExportEquiRow, S4Floc, S4Equi, S4SubFloc, S4EquiLocation, S4SubEqui, S4FlocLevel};
        solve (rules <+> input1) project S4Floc, S4Equi, S4SubFloc, S4EquiLocation, S4SubEqui, S4FlocLevel

    def flocLevel(floc: String): Option[Int32] = 
        use AssetLib/Base/S4/Floc.{new, level};
        new(floc)
            |> Result.map(level)
            |> Result.toOption



}
