/*
 * Copyright 2022 Stephen Tetley
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

    use Basis/System.FilePath;

    use Text/RegexEval.MatchEvaluator;

    use AssetLib/FileIO/S4/ClassList/Datatypes.{ClassListRow};
    use AssetLib/FileIO/S4/ClassList/Datatypes.ClassListRow.{ClassRow, CharRow, ValueRow, EmptyRow};

    type alias LineParser[r: Region, a: Type] = Region[r] -> String -> Result[a, String] \ Read(r)


    pub def parseFile(src: FilePath): Result[List[ClassListRow], String] & Impure = 
        use Result.flatMap;
        region r {
            let* buf    = FlixSandbox/System/File/BOM.openBufferedReaderWithBOM(src);
            let all     = FlixSandbox/System/File/BufferedReader.lines(buf) |> Iterator.toList;
            let body    = all |> List.dropWhile(s -> not String.startsWith(prefix = "-----", s)) |> List.drop(1);
            Result.traverse(input -> {let p = parseRow(); p(r, input)}, body)
        }



    pub def parseRow(): LineParser[r, ClassListRow] \ Read(r) = 
        choice(classRow1() :: classRow2() :: charRow1() :: charRow2() :: valueRow() :: emptyRow() :: Nil)

    pub def choice(ps: List[LineParser[r, a]]): LineParser[r, a] = (r, input) -> match ps { 
        case Nil       => Err("No Parse: ${input}")
        case p :: rest => match p(r, input) {
            case Err(_) => choice(rest, r, input)
            case Ok(a)  => Ok(a)
        }
    }


    pub def classRow1(): LineParser[r, ClassListRow] \ Read(r) = 
        let regex = "[\\u0020\\u002D\\u007C]{11}002 (?<classname>[\\p{Print}\\u0020]{34}) (?<classdesc>.{39}) X";
        let eval = ((x1, x2) -> ClassRow({classtype = "002", name = x1, description = x2})) 
                        <$> getTrimmed("classname") <*> getTrimmed("classdesc"); 
        makeLineParser(regex, eval)

    pub def classRow2(): LineParser[r, ClassListRow] \ Read(r) = 
        let regex = "[\\u0020\\u002D\\u007C]{11}002 (?<classname>[\\p{Print}\\u0020]{34}) (?<classdesc>.+)";
        let eval = ((x1, x2) -> ClassRow({classtype = "002", name = x1, description = x2})) 
                        <$> getTrimmed("classname") <*> getTrimmed("classdesc"); 
        makeLineParser(regex, eval)


    pub def charRow1(): LineParser[r, ClassListRow] \ Read(r) = 
        use Text/RegexEval/MatchEvaluator.{getInt32Named};
        let regex = "[\\u0020\\u002D\\u007C]{15}(?<charname>[\\p{Print}\\u0020]{34}) (?<chardesc>.{50}) (?<chartype>[\\p{Upper}\\u0020]{9}) (?<length>\\p{Digit}+) (\\u0020*)(?<decimals>\\p{Digit}+)";
        let eval = ((x1, x2, x3, x4, x5) -> CharRow({name = x1, description = x2, chartype = x3, textLength = x4, decimalPlaces = Some(x5)})) 
                        <$> getTrimmed("charname") <*> getTrimmed("chardesc") <*> getTrimmed("chartype") <*> getInt32Named("length") <*> getInt32Named("decimals"); 
        makeLineParser(regex, eval)

    pub def charRow2(): LineParser[r, ClassListRow] \ Read(r) = 
        use Text/RegexEval/MatchEvaluator.{getInt32Named};
        let regex = "[\\u0020\\u002D\\u007C]{15}(?<charname>[\\p{Print}\\u0020]{34}) (?<chardesc>.{50}) (?<chartype>[\\p{Upper}\\u0020]{9}) (?<length>\\p{Digit}+)";
        let eval = ((x1, x2, x3, x4) -> CharRow({name = x1, description = x2, chartype = x3, textLength = x4, decimalPlaces = None})) 
                        <$> getTrimmed("charname") <*> getTrimmed("chardesc") <*> getTrimmed("chartype") <*> getInt32Named("length"); 
        makeLineParser(regex, eval)

    pub def valueRow(): LineParser[r, ClassListRow] \ Read(r) = 
        let regex = "[\\u0020\\u002D\\u007C]{19}(?<value>.+)";
        let eval = (x1 -> ValueRow(x1)) <$> getTrimmed("value"); 
        makeLineParser(regex, eval)

    pub def emptyRow(): LineParser[r, ClassListRow] = 
        let regex = "[\\u0020\\u002D\\u007C]*";
        let eval = Applicative.point(EmptyRow); 
        makeLineParser(regex, eval)


    def makeLineParser(regex: String, eval: MatchEvaluator[r, a]): LineParser[r, a] = 
        match Text/Regex/Pattern.compile(regex) { 
            case Err(msg) => (_, _) -> Err(msg) as \ Read(r)
            case Ok(patt) => (r, input) -> Text/RegexEval/Regex.matchAll(r, eval, patt, input)
        }


    def getTrimmed(name: String): MatchEvaluator[r, String] \ Read(r) = 
        String.trim <$> Text/RegexEval/MatchEvaluator.getCaptureNamed(name)

}
