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


namespace AssetLib/S4/FileIO/ClassList/Datatypes {

    use Time.LocalDate;

    /// Source type indicates minor but important formatting differences in the input files
    pub enum SourceType {
        case FlocClasses,
        case EquiClasses
    }


    /// Flat representation - not a tree.
    type alias ClassListFile = { dateStamp: LocalDate, rows: List[ClassListRow] }

    /// ValueRow could be a list-of-values item or a range. It is decoded later.
    pub enum ClassListRow {
        case ClassRow(ClassRow),
        case CharacteristicRow(CharacteristicRow),
        case ValueRow(String)
    }

    type alias ClassRow = { classType: String, name: String, description: String }
    type alias CharacteristicRow = { name: String, description: String, datatype: Datatype }

    /// Nested representation.
    type alias ClassList = { dateStamp: LocalDate, classes: List[Class]}


    // classType eg "002", "003"
    type alias Class = { classType: String, name: String, description: String, characteristics: List[Characteristic] }

    type alias Characteristic = { name: String, description: String, datatype: Datatype, refinement: Option[Refinement] }

    pub enum Datatype { 
        case Text(Int32),
        case Date(Int32),
        case NumInt(Int32),
        case NumDecimal(Int32, Int32)
    }

    pub enum Refinement {
        case ListOfValues(List[String]),
        case IntRange(Int32, Int32),
        case DecimalRange(Float64, Float64)
    }
    

}