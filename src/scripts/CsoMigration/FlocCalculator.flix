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



namespace CsoMigration/FlocCalculator {

    use SheetIO.RowSetter;

    use CsoMigration/Relations.{AibCso, FlocMapping, Level1, Level2, Level3, Level4, Level5};

    pub rel Answer(name: String, sainum: String, floc: String, level: Int32, status: String)

    pub rel NotOnS4(name: String, sainum: String, status: String)

    pub rel HasLevel1(sainum: String)
    pub rel HasLevel2(sainum: String)
    pub rel HasLevel3(sainum: String)
    pub rel HasLevel4(sainum: String)
    pub rel HasLevel5(sainum: String)

    pub def calculate(facts: #{AibCso, FlocMapping, Level1, Level2, Level3, Level4, Level5, 
                                Answer, NotOnS4, HasLevel1, HasLevel2, HasLevel3, HasLevel4, HasLevel5 | r}, 
                        outpath: System.FilePath): Result[Unit, String] & Impure = 
        use Result.flatMap;
        let rules = #{
            
            HasLevel1(sainum) :- 
                FlocMapping(_, sainum, siteFloc, _),
                Level1(siteFloc, _).

            HasLevel2(sainum) :- 
                FlocMapping(_, sainum, siteFloc, _),
                Level2(siteFloc, _, _).

            HasLevel3(sainum) :- 
                FlocMapping(_, sainum, siteFloc, _),
                Level3(siteFloc, _, _).

            HasLevel4(sainum) :- 
                FlocMapping(_, sainum, siteFloc, _),
                Level4(siteFloc, _, _).

            HasLevel5(sainum) :- 
                FlocMapping(_, sainum, siteFloc, _),
                Level5(siteFloc, _, _).


            NotOnS4(name, sainum, "OPERATIONAL") :- 
                AibCso(name, sainum, "OPERATIONAL"),
                not HasLevel1(sainum).

            NotOnS4(name, sainum, "NON OPERATIONAL") :- 
                AibCso(name, sainum, "NON OPERATIONAL"),
                not HasLevel1(sainum).

            Answer(name, sainum, floc, 1, status) :- 
                AibCso(name, sainum, status),
                not HasLevel2(sainum), 
                FlocMapping(_, sainum, floc, _).

            Answer(name, sainum, floc, 2, status) :- 
                AibCso(name, sainum, status),
                not HasLevel3(sainum), 
                FlocMapping(_, sainum, site, _),
                Level2(site, floc, _).

            Answer(name, sainum, floc, 3, status) :- 
                AibCso(name, sainum, status),
                not HasLevel4(sainum), 
                FlocMapping(_, sainum, site, _),
                Level3(site, floc, _).

            Answer(name, sainum, floc, 4, status) :- 
                AibCso(name, sainum, status),
                not HasLevel5(sainum), 
                FlocMapping(_, sainum, site, _),
                Level4(site, floc, _).

        };
        let ans = solve (rules <+> facts) project NotOnS4, Answer;
        let rows1 = query ans select (x1, x2, x3) from NotOnS4(x1, x2, x3);
        Console.printLine("Not on S4 - ${Array.length(rows1)}");
        let* _ = writeNotOnS4Rows(outpath, rows1);
        let rows2 = query ans select (x1, x2, x3, x4, x5) from Answer(x1, x2, x3, x4, x5);
        Console.printLine("Answers - ${Array.length(rows2)}");
        let* _ = writeAnswerRows(outpath, rows2);
        Ok()



    pub def writeNotOnS4Rows(path: System.FilePath, arr: Array[(String, String, String)]): Result[Unit, String] & Impure = 
        let writer = {sheetName = "Not on S4",
            headers = Some(["Common Name", "Aib Reference", "AI2 Status"]),
            setter = setNotOnS4Row,
            rows = Array.toList(arr)
        };
        SheetIO/Writer.writeWorkSheet(writer, path)

    def setNotOnS4Row(ans: (String, String, String)): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, startingAt, putStringAt!, putInt32At!};
        use SheetIO/RowSetter.{*>, ++>};
        ans `RelLib/Tuple.case3` ((x1, x2, x3) ->
                startingAt(0)
            ++> flip(putStringAt!, x1)
            ++> flip(putStringAt!, x2)
            ++> flip(putStringAt!, x3)
            *> return())

    pub def writeAnswerRows(path: System.FilePath, arr: Array[(String, String, String, Int32, String)]): Result[Unit, String] & Impure = 
        let writer = {sheetName = "Largest Floc",
            headers = Some(["Common Name", "Aib Reference", "Existing Floc", "Existing Floc Level", "AI2 Status"]),
            setter = setAnswerRow,
            rows = Array.toList(arr)
        };
        SheetIO/Writer.addWorkSheet(writer, path)

    def setAnswerRow(ans: (String, String, String, Int32, String)): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, startingAt, putStringAt!, putInt32At!};
        use SheetIO/RowSetter.{*>, ++>};
        ans `RelLib/Tuple.case5` ((x1, x2, x3, x4, x5) ->
                startingAt(0)
            ++> flip(putStringAt!, x1)
            ++> flip(putStringAt!, x2)
            ++> flip(putStringAt!, x3)
            ++> flip(putInt32At!,  x4)
            ++> flip(putStringAt!, x5)
            *> return())


}