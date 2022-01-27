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

namespace AssetLib/FileIO/S4/ClassList/Builder {

    use AssetLib/FileIO/S4/ClassList/Datatypes.{ClassListRow};
    use AssetLib/FileIO/S4/ClassList/Datatypes.ClassListRow.{ClassRow, CharRow, ValueRow};
    use AssetLib/FileIO/S4/ClassList/Datatypes.{ClassRecords, ClassDescription, Characteristic, PicklistValue, IntRange};


    pub def readEquiClassRecords(src: System.FilePath): Result[ClassRecords, String] & Impure = 
        use Result.flatMap;
        let* xs = AssetLib/FileIO/S4/ClassList/EquiParser.parseFile(src);
        let ans = AssetLib/FileIO/S4/ClassList/Builder.buildRecords(xs);
        Ok(ans)

    pub def readFlocClassRecords(src: System.FilePath): Result[ClassRecords, String] & Impure = 
        use Result.flatMap;
        let* xs = AssetLib/FileIO/S4/ClassList/FlocParser.parseFile(src);
        let ans = AssetLib/FileIO/S4/ClassList/Builder.buildRecords(xs);
        Ok(ans)


    def buildRecords(xs: List[ClassListRow]): ClassRecords = 
        { classDescriptions = extractClassDescriptions(xs)
        , characteristics   = extractCharacteristics(xs)
        , picklistValues    = extractPicklistValues(xs)
        , intRanges         = extractIntRanges(xs)
        }



    def extractClassDescriptions(xs: List[ClassListRow]): List[ClassDescription] = 
        let step = (acc, x) -> match x {
            case ClassRow(r1) => Chain.snoc(acc, {className = r1.name, description = r1.description})
            case _            => acc
        };
        Foldable.foldLeft(step, Chain.empty(), xs) |> Chain.toList


    def extractCharacteristics(xs: List[ClassListRow]): List[Characteristic] = 
        let step = (acc, x) -> match x {
            case ClassRow(r1) => {className = r1.name | acc}
            case CharRow(r1)  => { 
                let x1 = {className = acc.className, charName = r1.name, description = r1.description, 
                            s4Datatype = r1.chartype, textLength = r1.textLength, 
                            decimalPlaces = r1.decimalPlaces}; 
                {results = Chain.snoc(acc.results, x1) | acc}
            }
            case _            => acc
        };
        Foldable.foldLeft(step, {results = Chain.empty(), className = ""}, xs) |> x -> x.results |> Chain.toList

    def extractPicklistValues(xs: List[ClassListRow]): List[PicklistValue] = 
        let step = (acc, x) -> match x {
            case ClassRow(r1) => {classname = r1.name | acc}
            case CharRow(r1)  => {charname = r1.name, chartype = r1.chartype | acc}
            case ValueRow(s) if acc.chartype == "CHAR" => {
                let x1 = { className = acc.classname, charName = acc.charname, value = s}; 
                {results = Chain.snoc(acc.results, x1) | acc}
            }
            case _            => acc
        };
        Foldable.foldLeft(step, {results = Chain.empty(), classname = "", charname = "", chartype = ""}, xs) |> x -> x.results |> Chain.toList



    def extractIntRanges(xs: List[ClassListRow]): List[IntRange] = 
        let step = (acc, x) -> match x {
            case ClassRow(r1) => {classname = r1.name | acc}
            case CharRow(r1)  => {charname = r1.name, chartype = r1.chartype | acc}
            case ValueRow(s) if acc.chartype == "NUM" => {
                let (rstart, rend) = intRange(s);
                let x1 = { className = acc.classname, charName = acc.charname, 
                            rangeFrom = rstart, rangeTo = rend}; 
                {results = Chain.snoc(acc.results, x1), chartype = "" | acc}
            }
            case _            => acc
        };
        Foldable.foldLeft(step, {results = Chain.empty(), classname = "", charname = "", chartype = ""}, xs) |> x -> x.results |> Chain.toList


    def intRange(src: String): (Int32, Int32) = 
        match (intRangeHelper(src) as & Pure) {
            case Ok(rng) => rng
            case Err(_) => (-1, -1)
        }

    def intRangeHelper(src: String): Result[(Int32, Int32), String] & Impure = 
        use Result.flatMap;
        use Text/Regex/MatchEvaluator.{getInt32Named};
        let* patt   = Text/Regex/Pattern.compile("(?<start>\\d+) \\- (?<end>\\d+)");
        let eval    = Applicative.product(getInt32Named("start"), getInt32Named("end"));
        Text/Regex.evalContains(patt, eval, src)


        
}