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




namespace AssetLib/FileIO/S4/ClassList/EquiParser {

    use Functor.{<$>};
    use Applicative.{<*>};

    use Text/Regex.{MatchEvaluator};

    use AssetLib/FileIO/S4/ClassList/Datatypes.{ClassListRow};
    use AssetLib/FileIO/S4/ClassList/Datatypes.ClassListRow.{ClassRow, CharacteristicRow, ValueRow};

    type alias LineParser[a] = String -> Result[a, String]

    pub def classRow1(): LineParser[ClassListRow] = 
        let regex = "[\\u0020\\u002D\\u007C]{11}002 (?<classname>[\\p{Print}\\u0020]{34}) (?<classdesc>[\\p{Print}\\u0020]{40})X";
        let eval = ((x1, x2) -> ClassRow({classtype = "002", name = x1, description = x2})) 
                        <$> getTrimmed("classname") <*> getTrimmed("classdesc"); 
        makeLineParser(regex, eval)

    pub def classRow2(): LineParser[ClassListRow] = 
        let regex = "[\\u0020\\u002D\\u007C]{11}002 (?<classname>[\\p{Print}\\u0020]{34}) (?<classdesc>[\\p{Print}\\u0020]+)";
        let eval = ((x1, x2) -> ClassRow({classtype = "002", name = x1, description = x2})) 
                        <$> getTrimmed("classname") <*> getTrimmed("classdesc"); 
        makeLineParser(regex, eval)

/*
    pub def charRow1(): LineParser[ClassListRow] = 
        let regex = Text/Regex/Pattern.compile("[\\u0020\\u002D\\u007C]{15}(?<charname>[\\p{Print}\\u0020]{34}) (?<chardesc>[\\p{Print}\\u0020]{50}) (?<chartype>[\\p{Upper}\\u0020]{9}) (?<length>\\p{Digit}+) (\\u0020*)(?<decimals>\\p{Digit}+)");
        let eval = ((x1, x2) -> CharacteristicRow({classtype = "002", name = x1, description = x2})) 
                        <$> getTrimmed("classname") <*> getTrimmed("classdesc"); 
        makeLineParser(regex, eval)
*/

    def makeLineParser(regex: String, eval: MatchEvaluator[a]): LineParser[a] = 
        match Text/Regex/Pattern.compile(regex) { 
            case Err(msg) => constant(Err(msg))
            case Ok(patt) => input -> Text/Regex.evalMatches(patt, eval, input) as & Pure
        }


    def getTrimmed(name: String): MatchEvaluator[String] = 
        String.trim <$> Text/Regex/MatchEvaluator.getCaptureNamed(name)

}
