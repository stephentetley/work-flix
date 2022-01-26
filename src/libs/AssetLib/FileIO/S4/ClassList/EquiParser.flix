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

    use Text/Regex.{MatchEvaluator};

    /// ValueRow could be a list-of-values item or a range. It is decoded later.
    pub enum ClassListRow {
        case ClassRow(ClassRow)
        case CharRow(CharacteristicRow)
        case ValueRow(String)
        case EmptyRow
    }

    instance ToString[ClassListRow] {
        pub def toString(x: ClassListRow): String = match x {
            case ClassRow(r)  => "ClassRow({classtype = ${r.classtype}, name = ${r.name}, description = ${r.description}})"
            case CharRow(r)   => "CharacteristicRow({name = ${r.name}, description = ${r.description}, chartype = ${r.chartype}, textLength = ${r.textLength}, decimalPlaces = ${r.decimalPlaces}})"
            case ValueRow(s)  => "ValueRow(${s})"
            case EmptyRow     => "EmptyRow"
        }
    }

    pub type alias ClassRow = 
        { classtype :: String
        , name :: String
        , description :: String 
        }

    pub type alias CharacteristicRow = 
        { name :: String
        , description :: String
        , chartype :: String
        , textLength :: Int32
        , decimalPlaces :: Option[Int32]
        }


    type alias LineParser[a] = String -> Result[a, String]


    pub def parseFile(src: System.FilePath): Result[List[ClassListRow], String] & Impure = 
        use Result.flatMap;
        let* buf    = System/File/BOM.openBufferedReaderWithBOM(src);
        let* all    = System/File/BufferedReader.lines(buf) |> X/Cursor.toList!;
        let body    = all |> List.dropWhile(s -> not String.startsWith(prefix = "-----", s)) |> List.drop(1);
        Result.traverse(parseRow(), body)
        



    pub def parseRow(): LineParser[ClassListRow] = 
        choice(classRow1() :: classRow2() :: charRow1() :: charRow2() :: valueRow() :: emptyRow() :: Nil)

    pub def choice(ps: List[LineParser[a]]): LineParser[a] = input -> match ps { 
        case Nil       => Err("No Parse: ${input}")
        case p :: rest => match p(input) {
            case Err(_) => choice(rest, input)
            case Ok(a)  => Ok(a)
        }
    }


    pub def classRow1(): LineParser[ClassListRow] = 
        let regex = "[\\u0020\\u002D\\u007C]{11}002 (?<classname>[\\p{Print}\\u0020]{34}) (?<classdesc>.{40})X";
        let eval = ((x1, x2) -> ClassRow({classtype = "002", name = x1, description = x2})) 
                        <$> getTrimmed("classname") <*> getTrimmed("classdesc"); 
        makeLineParser(regex, eval)

    pub def classRow2(): LineParser[ClassListRow] = 
        let regex = "[\\u0020\\u002D\\u007C]{11}002 (?<classname>[\\p{Print}\\u0020]{34}) (?<classdesc>.+)";
        let eval = ((x1, x2) -> ClassRow({classtype = "002", name = x1, description = x2})) 
                        <$> getTrimmed("classname") <*> getTrimmed("classdesc"); 
        makeLineParser(regex, eval)


    pub def charRow1(): LineParser[ClassListRow] = 
        use Text/Regex/MatchEvaluator.{getInt32Named};
        let regex = "[\\u0020\\u002D\\u007C]{15}(?<charname>[\\p{Print}\\u0020]{34}) (?<chardesc>.{50}) (?<chartype>[\\p{Upper}\\u0020]{9}) (?<length>\\p{Digit}+) (\\u0020*)(?<decimals>\\p{Digit}+)";
        let eval = ((x1, x2, x3, x4, x5) -> CharRow({name = x1, description = x2, chartype = x3, textLength = x4, decimalPlaces = Some(x5)})) 
                        <$> getTrimmed("charname") <*> getTrimmed("chardesc") <*> getTrimmed("chartype") <*> getInt32Named("length") <*> getInt32Named("decimals"); 
        makeLineParser(regex, eval)

    pub def charRow2(): LineParser[ClassListRow] = 
        use Text/Regex/MatchEvaluator.{getInt32Named};
        let regex = "[\\u0020\\u002D\\u007C]{15}(?<charname>[\\p{Print}\\u0020]{34}) (?<chardesc>.{50}) (?<chartype>[\\p{Upper}\\u0020]{9}) (?<length>\\p{Digit}+)";
        let eval = ((x1, x2, x3, x4) -> CharRow({name = x1, description = x2, chartype = x3, textLength = x4, decimalPlaces = None})) 
                        <$> getTrimmed("charname") <*> getTrimmed("chardesc") <*> getTrimmed("chartype") <*> getInt32Named("length"); 
        makeLineParser(regex, eval)

    pub def valueRow(): LineParser[ClassListRow] = 
        let regex = "[\\u0020\\u002D\\u007C]{19}(?<value>.+)";
        let eval = (x1 -> ValueRow(x1)) <$> getTrimmed("value"); 
        makeLineParser(regex, eval)

    pub def emptyRow(): LineParser[ClassListRow] = 
        let regex = "[\\u0020\\u002D\\u007C]*";
        let eval = Applicative.point(EmptyRow); 
        makeLineParser(regex, eval)


    def makeLineParser(regex: String, eval: MatchEvaluator[a]): LineParser[a] = 
        match Text/Regex/Pattern.compile(regex) { 
            case Err(msg) => constant(Err(msg))
            case Ok(patt) => input -> Text/Regex.evalMatches(patt, eval, input) as & Pure
        }


    def getTrimmed(name: String): MatchEvaluator[String] = 
        String.trim <$> Text/Regex/MatchEvaluator.getCaptureNamed(name)

}
