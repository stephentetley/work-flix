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
    
use System.Error.{InputMismatchException, Generic};


use FactIO.LineEvaluator;
use FactIO.LineEvaluator.{LineEvaluator};
use FactIO/LineEvaluator.{findRegex, matchRegex};
use FactIO.LinesParser;

use AssetLib/S4/FileIO/IH06Tree/Relations.{Root, Floc3, Equi3, Equi4};


/// OUT OF DATE... 
/// Use a "proper" parser
namespace AssetLib/S4/FileIO/IH06Tree/Loader {


    def floc2[r](): LineEvaluator[#{ Root, Floc3, Equi3, Equi4 | r }] = 
        use Text/Regex/MatchEvaluator.{flatMap, getCaptureByName, return};
        let pattern = "\s{2}(?<floc>\S+)\s+(?<name>.{5,40})$";
        let eval = () -> {
            let* s1 = getCaptureByName("floc");
            let* s2 = getCaptureByName("name");
            return({ Root(s1, s2). })
        };
        matchRegex(pattern, eval())


    def floc3[r](): LineEvaluator[#{ Root, Floc3, Equi3, Equi4 | r }] = 
        use Text/Regex/MatchEvaluator.{flatMap, getCaptureByName, return, map};
        let pattern = "\|\-{2}\s{4}(?<floc>\S+)\s+(?<name>.{41})(?<parent>\S+)";
        let eval = () -> {
            let* s1 = getCaptureByName("floc");
            let* s2 = getCaptureByName("name") |> map(String.trim);
            let* s3 = getCaptureByName("parent");
            return({ Floc3(s1, s2, s3). })
        };
        findRegex(pattern, eval())

    def equi3[r](): LineEvaluator[#{ Root, Floc3, Equi3, Equi4 | r }] = 
        use Text/Regex/MatchEvaluator.{flatMap, getCaptureByName, return, map};
        let pattern = "\|\-{2,3}\s{3,4}(?<equiid>\$?\d+)\s+(?<name>.{41})(?<floc>\S+)$";
        let eval = () -> {
            let* s1 = getCaptureByName("equiid");
            let* s2 = getCaptureByName("name") |> map(String.trim);
            let* s3 = getCaptureByName("floc");
            return({ Equi3(s1, s2, s3). })
        };
        findRegex(pattern, eval())

    def equi4[r](): LineEvaluator[#{ Root, Floc3, Equi3, Equi4 | r }] = 
        use Text/Regex/MatchEvaluator.{flatMap, getCaptureByName, return, map};
        let pattern = "\|\-{2,3}\s{3,4}(?<equiid>\$?\d+)\s+(?<name>.{41})(?<floc>\S+)\s+(?<super>\$?\d+)$";
        let eval = () -> {
            let* s1 = getCaptureByName("equiid");
            let* s2 = getCaptureByName("name") |> map(String.trim);
            let* s3 = getCaptureByName("floc");
            let* s4 = getCaptureByName("super");
            return({ Equi4(s1, s2, s3, s4). })
        };
        findRegex(pattern, eval())


    def spacer[r](): LineEvaluator[#{ Root, Floc3, Equi3, Equi4 | r }] = 
        use Text/Regex/MatchEvaluator.{return};
        use FactIO/LineEvaluator.{map};
        matchRegex("(\||\s)+", return(#{ }))

    
    pub def ih06Loader[r](): LinesImporter[#{ Root, Floc3, Equi3, Equi4 | r }] = 
        use FactIO/LinesParser.{flatMap, return, skipLines, line, lines};
        use FactIO/LineEvaluator.{choice};
        let* _ = skipLines(3);
        let* root = line(floc2());
        let* rows = lines(choice(equi4() :: equi3() :: floc3() :: spacer() :: Nil));
        return(solve root <+> rows)

    /// Always UTF-8?
    pub def importLines[r](path: String) : Result[#{ Root, Floc3, Equi3, Equi4 | r }, System.Error] & Impure = 
        use Result.flatMap;
        let* relns = FactIO/LinesParser.runLinesParser(ih06Loader(), (), path, Text/Charset.utf_8());
        Ok(solve relns)


 }