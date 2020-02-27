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

    def csvHeaders(): Array[String] = 
        [ "Site", "Function", "Process Group", "Process", "System", "Assembly", "Item", "Component", 
            "Functional Location", "Equipment", "Parent", "Description"
        ]

    def mkFlocRootCells(x: FlocRoot): Array[String] = 
        [ x.floc, "", "", "", "", "", "", "", x.floc, "", "", x.description ]


    def flocRootParser(writer: CsvWriter) : TextParser.Parser[Unit] = 
        TextParser.fmap(
            x -> mkFlocRootCells(x) |> CsvExport.writeRow(writer), 
            HierarchyParser.flocRootLine()
        )

    def mkFlocRowCells(x: FlocRow): Array[String] = 
        let arr = [ "", "", "", "", "", "", "", "", x.floc, "", "", x.description ];
        let ix = FuncLoc.new(x.floc) |> FuncLoc.level |> i -> i - 1;
        arr[ix] = x.floc;
        arr
    
    def flocRowParser(writer: CsvWriter) : TextParser.Parser[Unit] = 
        TextParser.fmap(
            x -> mkFlocRowCells(x) |> CsvExport.writeRow(writer), 
            HierarchyParser.flocLine()
        )

    def mkEquiRowCells(x: EquiRow): Array[String] = 
        let parent = Option.getWithDefault(x.superordinate, "");
        [ "", "", "", "", "", "", "", "", x.floc, x.equiId, parent, x.description ]

    def equiRowParser(writer: CsvWriter) : TextParser.Parser[Unit] = 
        TextParser.fmap(
            x -> mkEquiRowCells(x) |> CsvExport.writeRow(writer), 
            HierarchyParser.equiLine()
        )
    
    def ignoreRow() : TextParser.Parser[Unit] = 
        TextParser.fmap(
            _ -> (), 
            TextParser.restOfInput()
        )

    pub def generateReport(inputfile: String, destfile: String): Result[Unit, String] = 
        let path = Path.new(inputfile);
        let writer = CsvExport.new(destfile, csvHeaders());
        let p1 = 
            TextParser.choice([
                flocRootParser(writer),
                flocRowParser(writer),
                equiRowParser(writer),
                ignoreRow()
            ]);
        ReportBase.foreachLines(p1, path);
        CsvExport.close(writer) |> Ok

}