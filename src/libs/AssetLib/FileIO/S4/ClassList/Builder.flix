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

namespace AssetLib/FileIO/S4/ClassList/Builder {


    use AssetLib/FileIO/S4/ClassList/Datatypes.{ClassListFile, ClassListRow, ClassRow, CharacteristicRow, Datatype};
    use AssetLib/FileIO/S4/ClassList/Datatypes.{ClassList, Class, Characteristic, Refinement};
    use AssetLib/FileIO/S4/ClassList/Datatypes.ClassListRow.{ClassRow, CharacteristicRow, ValueRow};
    use AssetLib/FileIO/S4/ClassList/Datatypes.Datatype.{Text, Date, NumInt, NumDecimal};
    use AssetLib/FileIO/S4/ClassList/Datatypes.Refinement.{ListOfValues, IntRange, DecimalRange};
    use AssetLib/FileIO/S4/ClassList/Datatypes.SourceType.{FlocClasses, EquiClasses};

    pub def loadFlocClassList(path: System.FilePath): Result[ClassList, String] & Impure = 
        use Result.{flatMap};
        let* ast    = AssetLib/FileIO/S4/ClassList/Parser.parseFlocClassFile(path);
        let ans     = buildClassList(ast);
        Ok(ans)

    pub def loadEquiClassList(path: System.FilePath): Result[ClassList, String] & Impure = 
        use Result.{flatMap};
        let* ast    = AssetLib/FileIO/S4/ClassList/Parser.parseEquiClassFile(path);
        let ans     = buildClassList(ast);
        Ok(ans)


    pub def buildClassList(src: ClassListFile): ClassList = 
        let cs = classesList(src.rows, xs -> xs);
        { dateStamp = src.dateStamp, classes = cs }

    /// In CPS ...
    /// This is preorder builder with max depth of 3 and each row has 
    /// a distinct type, so we can tell from the node type whether to
    /// go up or down.

    def classesList(src: List[ClassListRow], k: List[Class] -> List[Class]): List[Class] = 
        match src { 
            case ClassRow(r1) :: rest => {
                characteristicsList(rest, (cxs, rest1) -> 
                    let c1 = {classtype = r1.classtype, name = r1.name, 
                                description = r1.description, characteristics = cxs};
                    classesList(rest1, cs -> k(c1 :: cs)))
            }
            case _ => k(Nil)
        }

    def characteristicsList(src: List[ClassListRow], k: (List[Characteristic], List[ClassListRow]) -> List[Class]): List[Class] = 
        match src { 
            case CharacteristicRow(r1) :: rest => {
                listOfValuesList(rest, (vals, rest1) ->
                    let c1 = {name = r1.name, description = r1.description, 
                                chartype = r1.chartype, refinement = makeRefinement(vals)};
                    characteristicsList(rest1, (cs, rest2) -> k(c1 :: cs, rest2)))
            }
            case xs => k(Nil, xs)
        }

    def listOfValuesList(src: List[ClassListRow], k: (List[String],  List[ClassListRow]) -> List[Class]): List[Class] =  
        match src { 
            case ValueRow(v1) :: rest => listOfValuesList(rest, (vs, rest1) -> k(v1 :: vs, rest1))
            case xs => k(Nil, xs)
        }

    def makeRefinement(xs: List[String]): Option[Refinement] = 
        match xs {
            case Nil => None
            case r1 :: Nil => match intRange(r1) { 
                case Ok(rng) => Some(rng)
                case Err(_) => Some(ListOfValues(r1 :: Nil))
            }
            case ans => Some(ListOfValues(ans))
        }

    def intRange(src: String): Result[Refinement, String] = intRangeHelper(src) as & Pure 

    def intRangeHelper(src: String): Result[Refinement, String] & Impure = 
        use Result.flatMap;
        use Text/Regex/MatchEvaluator.{getInt32Named};
        let* patt   = Text/Regex/Pattern.compile("(?<start>\\d+) \\- (?<end>\\d+)");
        let eval    = Applicative.liftA2((x, y) -> IntRange(x,y), getInt32Named("start"), getInt32Named("end"));
        Text/Regex.evalContains(patt, eval, src)


        
}