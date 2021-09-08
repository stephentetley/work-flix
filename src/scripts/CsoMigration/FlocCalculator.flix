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

    use CsoMigration/Relations.{AibCso, FlocMapping, Level1, Level2, Level3, Level4, Level5};

    pub rel Answer(name: String, sainum: String, floc: String, level: Int32, status: String)

    pub rel NotOnS4(name: String, sainum: String, status: String)

    pub rel HasLevel1(sainum: String)
    pub rel HasLevel2(sainum: String)
    pub rel HasLevel3(sainum: String)
    pub rel HasLevel4(sainum: String)
    pub rel HasLevel5(sainum: String)

    pub def calculate(facts: #{AibCso, FlocMapping, Level1, Level2, Level3, Level4, Level5, 
                                Answer, NotOnS4, HasLevel1, HasLevel2, HasLevel3, HasLevel4, HasLevel5 | r}): Unit & Impure = 
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
        let ans = solve (rules <+> facts);
        Console.printLine("Not on S4...");
        query ans select (x1, x2, x3) from NotOnS4(x1, x2, x3) |> Array.foreach(println);
        Console.printLine("Answers...");
        query ans select (x1, x2, x3, x4, x5) from Answer(x1, x2, x3, x4, x5) |> Array.foreach(println)            

}