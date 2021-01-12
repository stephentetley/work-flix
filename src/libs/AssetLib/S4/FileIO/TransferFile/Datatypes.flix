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



namespace AssetLib/S4/FileIO/TransferFile/Datatypes {

    use Time.LocalDateTime;


    /// Potentially we now favour "File Upload" for modifications.


    type alias TransferFile = 
        { fileHeader: FileHeader
        , selection: List[String]       /// uninterpreted
        , headers: Headers
        , dataRows: List[DataRow]
        }

    type alias  DataRow = Array[String]

    type alias FileHeader = 
        { fileType: FileType
        , dataModel : DataModel
        , entityType: EntityType
        , variant: String
        , user: String
        , dateTime: LocalDateTime
        } 


    /// We want direct indexing...
    type alias Headers = Array[String]
    
    /// Possibly change to String?
    /// Generally we are now only concerned with Download files
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


    

    /// EntityData
    /// Currently used by AssetLib/S4/FileIO/TransferFile/Evaluate - should we remove this?
    type alias EntityData[row] = 
        { entityType: EntityType
        , headers: Headers
        , dataRows: List[row]
        }

}