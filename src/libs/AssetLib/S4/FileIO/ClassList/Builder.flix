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

namespace AssetLib/S4/FileIO/ClassList/Builder {

    use Data.{RoseTree, RoseForest};
    use Data.RoseTree.{RoseTree};

    use AssetLib/S4/FileIO/ClassList/Datatypes.{ClassListFile, ClassListRow, ClassRow, CharacteristicRow, Datatype};
    use AssetLib/S4/FileIO/ClassList/Datatypes.{ClassList, Class, Characteristic, Refinement};
    use AssetLib/S4/FileIO/ClassList/Datatypes.ClassListRow.{ClassRow, CharacteristicRow, ValueRow};
    use AssetLib/S4/FileIO/ClassList/Datatypes.Datatype.{Text, Date, NumInt, NumDecimal};
    use AssetLib/S4/FileIO/ClassList/Datatypes.Refinement.{ListOfValues, IntRange, DecimalRange};



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
                    let c1 = { classType = r1.classType, name = r1.name
                            , description = r1.description, characteristics = cxs };
                    classesList(rest1, cs -> k(c1 :: cs)))
            }
            case _ => k(Nil)
        }

    def characteristicsList(src: List[ClassListRow], k: (List[Characteristic], List[ClassListRow]) -> List[Class]): List[Class] = 
        match src { 
            case CharacteristicRow(r1) :: rest => {
                listOfValuesList(rest, (vals, rest1) ->
                    let c1 = {  name = r1.name, description = r1.description
                            , datatype = r1.datatype, refinement = makeRefinement(vals) };
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
        use Text/Regex/MatchEvaluator.{lift2, getInt32Named};
        let patt    = Text/Regex/Pattern.compile("(?<start>\d+) \- (?<end>\d+)");
        let* patt1  = Option.toOk(patt, "intRangeHelper");
        let eval    = lift2((x: Int32, y: Int32) -> IntRange(x,y), getInt32Named("start"), getInt32Named("end"));
        Text/Regex.evalContains(src, patt1, eval)

    /// Print Html via a rose tree

    type alias Label = {name: String, description: String}

    pub def allTrees(src: ClassList): RoseForest[Label] = 
        List.map(buildRoseTree, src.classes)

    def buildRoseTree(src: Class): RoseTree[Label] = 
        let label = { name = src.name, description = src.description};
        roseTreeChars(src.characteristics,  xs -> RoseTree(label, xs))

    def roseTreeChars(xs: List[Characteristic], k: List[RoseTree[Label]] -> RoseTree[Label]): RoseTree[Label] = 
        match xs { 
            case Nil => k(Nil)
            case x1 :: rest =>
                roseTreeChar1(x1, v1 -> 
                    roseTreeChars(rest, vs -> k(v1 :: vs)))
        }

    def roseTreeChar1(src: Characteristic, k: RoseTree[Label] -> RoseTree[Label]): RoseTree[Label] = 
        let label = { name = src.name, description = src.description};
        match src.refinement { 
            case Some(r) => roseTreeRefines1(r, kids -> k(RoseTree(label, kids)))
            case None => k(RoseTree(label, Nil))
        }

    def roseTreeRefines1(src: Refinement, k: List[RoseTree[Label]] -> RoseTree[Label]): RoseTree[Label] = 
        let intRangeLabel = (x,y) -> {name = "Int Range", description = Int32.toString(x) + " - " + Int32.toString(y) };
        let decimalRangeLabel = (x,y) -> {name = "Decimal Range", description = Float64.toString(x) + " - " + Float64.toString(y) };
        match src { 
            case ListOfValues(xs)   => k(List.map(x -> RoseTree({name = "Value", description = x}, Nil), xs))
            case IntRange(x, y)     => k(RoseTree(intRangeLabel(x,y), Nil) :: Nil)
            case DecimalRange(x, y) => k(RoseTree(decimalRangeLabel(x,y), Nil) :: Nil)
        }
        
}