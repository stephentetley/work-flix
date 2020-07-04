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

use Data.{RoseTree, RoseForest};
use Data.RoseTree.{RoseTree};

use AssetLib/S4/FileReaders/ClassList/Datatypes.{ClassListFile, ClassListRow, ClassRow, CharacteristicRow, Datatype};
use AssetLib/S4/FileReaders/ClassList/Datatypes.{ClassList, Class, Characteristic, Refinement};
use AssetLib/S4/FileReaders/ClassList/Datatypes.ClassListRow.{ClassRow, CharacteristicRow, ValueRow};
use AssetLib/S4/FileReaders/ClassList/Datatypes.Datatype.{Text, Date, NumInt, NumDecimal};
use AssetLib/S4/FileReaders/ClassList/Datatypes.Refinement.{ListOfValues, IntRange, DecimalRange};

namespace AssetLib/S4/FileReaders/ClassList/Builder {
    
    pub def buildClassList(src: ClassListFile): ClassList & Impure = 
        { dateStamp = src.dateStamp, classes = classesList(src.rows)}

    def classesList(src: List[ClassListRow]): List[Class] & Impure = 
        match src { 
            case ClassRow(r1) :: rest => {
                let (cxs, rest1) = characteristicsList(rest);
                let c1 = { classType = r1.classType, name = r1.name
                         , description = r1.description, characteristics = cxs };
                let cs = classesList(rest1);
                c1 :: cs
            }
            case _ => Nil
        }

    def characteristicsList(src: List[ClassListRow]): (List[Characteristic],  List[ClassListRow]) & Impure = 
        match src { 
            case CharacteristicRow(r1) :: rest => {
                let (vals, rest1) = listOfValuesList(rest);
                let c1 = {  name = r1.name, description = r1.description
                        , datatype = r1.datatype, refinement = makeRefinement(vals) };
                let (cs, rest2) = characteristicsList(rest1);                
                (c1 :: cs, rest2)
            }
            case xs => (Nil, xs)
        }

    def listOfValuesList(src: List[ClassListRow]): (List[String],  List[ClassListRow]) & Impure = 
        match src { 
            case ValueRow(v1) :: rest => {
                let (vs, rest1) = listOfValuesList(rest);
                (v1 :: vs, rest1)
            }
            case xs => (Nil, xs)
        }

    def makeRefinement(xs: List[String]): Option[Refinement] & Impure = 
        match xs {
            case Nil => None
            case r1 :: Nil => match intRange(r1) { 
                case Ok(rng) => Some(rng)
                case Err(_) => Some(ListOfValues(r1 :: Nil))
            }
            case ans => Some(ListOfValues(ans))
        }

    def intRange(src: String): Result[Refinement, System.Error] & Impure = 
        use Result.flatMap;
        use Text/Regex/MatchEvaluator.{lift2, getNamedCaptureInt32};
        let* patt = Text/Regex/Pattern.compile("(?<start>\d+) \- (?<end>\d+)");
        let eval = lift2((x,y) -> IntRange(x,y), getNamedCaptureInt32("start"), getNamedCaptureInt32("end"));
        Text/Regex.evalContains(src, patt, eval)

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