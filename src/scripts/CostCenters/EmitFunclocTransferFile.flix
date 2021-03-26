/*
 * Copyright 2021 Stephen Tetley
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


namespace CostCenters/EmitFunclocTransferFile {

    use AssetLib/S4/FileIO/TransferFile.RowSetter;
    use AssetLib/S4/FileIO/TransferFile/Datatypes.EntityType.{FuncLoc};

    type alias CCUpdateRow = 
        { funcloc: String
        , costCenter: String            /// Usually (always?) numeric, but may be blank
        , costCenterOrigin: Origin      /// (D)irect or (H)ierarchy (i.e. inherit)
        , description: String
        , statusOfObject: String
        }

    pub enum Origin { 
        case Direct
        case Hierarchy
    }

    instance ToString[Origin] { 
        pub def toString(x: Origin): String = match x {
            case Direct => "D"
            case Hierarchy => "H"
        }
    }

    instance FromString[Origin] { 
        pub def fromString(x: String): Option[Origin] = match x { 
            case "D" => Some(Direct)
            case "H" => Some(Hierarchy)
            case _ => None
        }
    }

    instance Eq[Origin] { 
        pub def eq(x: Origin, y: Origin): Bool = match (x, y) { 
            case (Direct, Direct) => true
            case (Hierarchy, Hierarchy) => true
            case (_, _) => false
        }
    }

    instance Hash[Floc] {
        pub def hash(x: Floc): Int32 = Hash.hash(ToString.toString(x))
    }


    pub def outputFunclocFile(user: String,
                                rows: List[CCUpdateRow], 
                                outpath: System.FilePath): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        use AssetLib/S4/FileIO/TransferFile/EmitUploadFile.{outputUploadFile, execMapRowSetter};
        let headers = ["FUNCLOC", "KOST_FLOC", "KOSTLI", "TXTMI", "USTW_FLOC"];
        let* rows2 = execMapRowSetter(headers, funclocSetRow!, rows);
        outputUploadFile(FuncLoc, "", user, headers, rows2, outpath)

    def funclocSetRow!(x: CCUpdateRow): RowSetter[Unit] = 
        use AssetLib/S4/FileIO/TransferFile/RowSetter.{flatMap, return, putStringNamed!};
        let* _  = putStringNamed!("FUNCLOC",    x.funcloc);
        let* _  = putStringNamed!("KOST_FLOC",  x.costCenter);
        let* _  = putStringNamed!("KOSTLI",     ToString.toString(x.costCenterOrigin));
        let* _  = putStringNamed!("TXTMI",      x.description);
        let* _  = putStringNamed!("USTW_FLOC",  x.statusOfObject);
        return()



}
