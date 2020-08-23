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

use Time.LocalDateTime;

namespace AssetLib/S4/FileIO/EntityFile/Datatypes {

    /// EntityFile - from "File Download" or for "File Upload".

    pub opaque type EntityFile = { fileHeader: FileHeader, selection: Selection, headers: Headers, dataRows: List[DataRow] }

    pub opaque type DataRow = Array[String]



    pub type alias FileHeader = { fileType: FileType, dataModel : DataModel, entityType: EntityType, 
                                    variant: String, user: String, dateTime: LocalDateTime } 

    pub enum FileType {
        case Download,
        case Upload
    }

    pub enum DataModel {
        case U1
    }

    pub enum EntityType {
        case FuncLoc,
        case ClassFloc,
        case ValuaFloc,
        case Iflotx,
        case Equi,
        case ClassEqui,
        case ValuaEqui,
        case Eqmltxt
    }


    pub def showEntityType(x: EntityType): String = match x {
        case FuncLoc    => "FUNCLOC"
        case ClassFloc  => "CLASSFLOC"
        case ValuaFloc  => "VALUAFLOC"
        case Iflotx     => "IFLOTX"
        case Equi       => "EQUI"
        case ClassEqui  => "CLASSEQUI"
        case ValuaEqui  => "VALUAEQUI"
        case Eqmltxt    => "EQMLTEXT"
    }

    /// Uninterpreted
    pub opaque type Selection = List[String]

    pub def emptySelection(): Selection = Selection(Nil)

    pub opaque type Headers = Array[String]
    

    /// EntityData


    pub opaque type EntityData[row] = { entityType: EntityType, headers: Headers, dataRows: List[row] }

}