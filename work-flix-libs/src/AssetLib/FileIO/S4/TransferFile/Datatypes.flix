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



namespace AssetLib/FileIO/S4/TransferFile/Datatypes {

    use Time.LocalDateTime;


    /// Potentially we now favour "File Upload" for modifications.


    pub type alias TransferFile[r: Region] = 
        { fileHeader :: FileHeader
        , selection :: List[String]       /// uninterpreted
        , headers :: Headers[r]
        , dataRows :: List[DataRow[r]]
        }

    pub type alias DataRow[r: Region] = Array[String, r]

    pub type alias FileHeader = 
        { fileType :: FileType
        , dataModel :: DataModel
        , entityType :: EntityType
        , variant :: String
        , user :: String
        , dateTime :: LocalDateTime
        } 


    /// We want direct indexing...
    pub type alias Headers[r: Region] = Array[String, r]
    
    /// Possibly change to String?
    /// Generally we are now only concerned with Download files
    pub enum FileType {
        case Download
        case Upload
    }

    pub enum DataModel {
        case U1
    }

    pub enum EntityType {
        case FuncLoc
        case ClassFloc
        case ValuaFloc
        case Iflotx
        case Equi
        case ClassEqui
        case ValuaEqui
        case Eqmltxt
    }

    instance ToString[EntityType] {
        pub def toString(x: EntityType): String = match x {
            case FuncLoc    => "FUNCLOC"
            case ClassFloc  => "CLASSFLOC"
            case ValuaFloc  => "VALUAFLOC"
            case Iflotx     => "IFLOTX"
            case Equi       => "EQUI"
            case ClassEqui  => "CLASSEQUI"
            case ValuaEqui  => "VALUAEQUI"
            case Eqmltxt    => "EQMLTEXT"
        }
    }

    instance FromString[EntityType] {
        pub def fromString(x: String): Option[EntityType] = match x {
            case "FUNCLOC"   => Some(FuncLoc)
            case "CLASSFLOC" => Some(ClassFloc)
            case "VALUAFLOC" => Some(ValuaFloc)
            case "IFLOTX"    => Some(Iflotx)
            case "EQUI"      => Some(Equi)
            case "CLASSEQUI" => Some(ClassEqui)
            case "VALUAEQUI" => Some(ValuaEqui)
            case "EQMLTEXT"  => Some(Eqmltxt)
            case _ => None
        }
    }

    instance Eq[EntityType] {
        pub def eq(x: EntityType, y: EntityType): Bool = match (x, y) {
            case (FuncLoc, FuncLoc) => true
            case (ClassFloc, ClassFloc) => true
            case (ValuaFloc, ValuaFloc) => true
            case (Iflotx, Iflotx) => true
            case (Equi, Equi) => true
            case (ClassEqui, ClassEqui) => true
            case (ValuaEqui, ValuaEqui) => true
            case (Eqmltxt, Eqmltxt) => true
            case (_, _) => false
        }
    }

    instance Hash[EntityType] {
        pub def hash(x: EntityType): Int32 = Hash.hash(ToString.toString(x))
    }
    


    pub type alias ClassFlocRow = 
        { funcloc :: String
        , className :: String
        , classType :: String
        , internalClassNumber :: String
        , status :: Option[Int32]
        }


    pub type alias ValuaFlocRow = 
        { funcloc :: String
        , classType :: String
        , charId :: String
        , charValue :: String
        , code :: Option[Int32]
        , valueDescription :: String
        , instanceCounter :: Int32
        , intCounterValue :: Int32
        , position :: String            /// Int32?
        , valueFrom :: String
        , valueTo :: String
        }

        
    /// Note status appears to be optional.
    pub type alias ClassEquiRow = 
        { equi :: String
        , className :: String
        , classType :: String
        , internalClassNumber :: String
        , status :: Option[Int32]
        }


    pub type alias ValuaEquiRow = 
        { equi :: String
        , classType :: String
        , charId :: String
        , charValue :: String
        , code :: Option[Int32]
        , valueDescription :: String
        , instanceCounter :: Int32
        , intCounterValue :: Int32
        , position :: String            /// Int32?
        , valueFrom :: String
        , valueTo :: String
        }


}
