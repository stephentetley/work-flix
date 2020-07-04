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

use AssetLib/S4/FileReaders/ClassList/Datatypes.{ClassListFile, ClassListRow, ClassRow, CharacteristicRow, Datatype};
use AssetLib/S4/FileReaders/ClassList/Datatypes.{ClassList, Class, Characteristic, Refinement};
use AssetLib/S4/FileReaders/ClassList/Datatypes.ClassListRow.{ClassRow, CharacteristicRow, ValueRow};
use AssetLib/S4/FileReaders/ClassList/Datatypes.Datatype.{Text, Date, NumInt, NumDecimal};

namespace AssetLib/S4/FileReaders/ClassList/Builder {
    
    pub def buildClassList(src: ClassListFile): ClassList = 
        { dateStamp = src.dateStamp, classes = classesList(src.rows)}

    def classesList(src: List[ClassListRow]): List[Class] = 
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

    def characteristicsList(src: List[ClassListRow]): (List[Characteristic],  List[ClassListRow]) = 
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

    def listOfValuesList(src: List[ClassListRow]): (List[String],  List[ClassListRow]) = 
        match src { 
            case ValueRow(v1) :: rest => {
                let (vs, rest1) = listOfValuesList(rest);
                (v1 :: vs, rest1)
            }
            case xs => (Nil, xs)
        }

    def makeRefinement(_: List[String]): Option[Refinement] = None

}