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

namespace FlocReport {

    type alias Cells = Option[List[String]]

    def csvHeaders(): Array[String] & Impure = 
        [ "Site", "Function", "Process Group", "Process", "System", "Assembly", "Item", "Component", 
            "Functional Location", "Equipment", "Parent", "Description"
        ]

    def mkFlocRootCells(x: FlocRoot): Cells = 
        Some(x.floc :: "" :: "" :: "" :: "" :: "" :: "" :: "" :: x.floc :: "" :: "" :: x.description  :: Nil)


    def flocRootParser() : TextParser.Parser[Cells] = 
        TextParser.fmap(
            mkFlocRootCells, 
            HierarchyParser.flocRootLine()
        )

    def mkFlocRowCells(x1: FlocRow): Cells = 
        let zs = "" :: "" :: "" :: "" :: "" :: "" :: "" :: "" :: x1.floc :: "" :: "" :: x1.description :: Nil;
        let ix = FuncLoc.new(x1.floc) |> FuncLoc.level |> i -> i - 1;
        List.update(ix, x1.floc, zs) |> Some
    
    def flocRowParser() : TextParser.Parser[Cells] = 
        TextParser.fmap(
            mkFlocRowCells, 
            HierarchyParser.flocLine()
        )

    def mkEquiRowCells(x: EquiRow): Cells = 
        let parent = Option.getWithDefault(x.superordinate, "");
        Some("" :: "" :: "" :: "" :: "" :: "" :: "" :: "" :: x.floc :: x.equiId :: parent :: x.description :: Nil)

    def equiRowParser() : TextParser.Parser[Cells] = 
        TextParser.fmap(
            mkEquiRowCells,
            HierarchyParser.equiLine()
        )
    
    def ignoreRow() : TextParser.Parser[Cells] = 
        TextParser.fmap(
            _ -> None, 
            TextParser.restOfInput()
        )

    // |> CsvExport.writeRow(writer)
    pub def generateReport(inputfile: String, destfile: String): Result[Unit, String] & Impure = 
        let path = Path.new(inputfile);
        let writer = CsvExport.new(destfile, csvHeaders());
        let fn = ans -> match ans { 
            case None => () as & Impure 
            case Some(xs) => { let arr = List.toArray(xs); CsvExport.writeRow(writer, arr) }
        };
        let p1 = 
            TextParser.choice(
                flocRootParser()  ::
                flocRowParser()   ::
                equiRowParser()   ::
                ignoreRow()             :: 
                Nil
            );
        ReportBase.foreachLines(p1, fn, path);
        CsvExport.close(writer) |> Ok

}