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

namespace AssetLib/S4/FileReaders/IH06Tree/Datatypes {

    type alias Header =  { floc: String, description: String, validForm: LocalDate }

    type alias FlocRow = { floc: String, description: String, parent: Option[String] }
    type alias EquiRow = { equiId: String, description: String, floc: String, superordinate: Option[String] }

    pub enum IH06Row {
        case FlocRow(FlocRow),
        case EquiRow(EquiRow)
    }

    type alias IH06File = { header: Header, rows: List[IH06Row] }



}