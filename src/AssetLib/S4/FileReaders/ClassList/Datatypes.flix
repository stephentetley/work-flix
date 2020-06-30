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

use Time.LocalDate;

namespace AssetLib/S4/FileReaders/ClassList/Datatypes {


    type alias ClassList = { dateStamp: LocalDate, classes: List[Class]}


    // classType eg "002", "003"
    type alias Class = { classType: String, name: String, description: String, characteristics: List[Characteristic] }

    type alias Characteristic = { name: String, description: String, datatype: Datatype }

    pub enum Datatype { 
        case Text(Int32, List[String]),
        case Date(Int32),
        case NumInt(Int32, Option[IntRange]),
        case NumDecimal(Int32, Int32, Option[DecimalRange])
    }

    type alias IntRange = { low: Int32, high: Int32 }

    type alias DecimalRange = { low: Float64, high: Float64 }


}