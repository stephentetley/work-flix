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

    pub rel Answer(name: String, sainum: String, floc: String: level: Int32, status: String)

    pub rel NotOnS4(name: String, sainum: String, status: String)

    pub rel HasFlocMapping(sainum: String)

    pub def calculate(facts: #{AibCso, FlocMapping, Level1, Level2, Level3, Level4, Level5, NotOnS4, HasFlocMapping | r}): Unit & Impure = 
        let rules = #{
            
            HasFlocMapping(sainum) :- 
                FlocMapping(_, sainum, _, _).

            NotOnS4(name, sainum, "OPERATIONAL") :- 
                AibCso(name, sainum, "OPERATIONAL"),
                not HasFlocMapping(sainum).

            NotOnS4(name, sainum, "NON OPERATIONAL") :- 
                AibCso(name, sainum, "NON OPERATIONAL"),
                not HasFlocMapping(sainum).

        };
        let ans = (rules <+> facts);
        Console.printLine("Not on S4...");
        query ans select (x1, x2, x3) from NotOnS4(x1, x2, x3)
            |> Array.foreach(println)

}