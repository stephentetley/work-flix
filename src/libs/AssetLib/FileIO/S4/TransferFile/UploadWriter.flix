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

namespace AssetLib/FileIO/S4/TransferFile/UploadWriter {

    use AssetLib/FileIO/S4/TransferFile/Datatypes.{EntityType, DataRow, 
        ClassFlocRow, ValuaFlocRow, ClassEquiRow, ValuaEquiRow};
    use AssetLib/FileIO/S4/TransferFile/Datatypes.FileType.{Upload};
    use AssetLib/FileIO/S4/TransferFile/Datatypes.DataModel.{U1};
    use AssetLib/FileIO/S4/TransferFile/Datatypes.EntityType.{ClassFloc, ValuaFloc, ClassEqui, ValuaEqui};
    use AssetLib/FileIO/S4/TransferFile.UploadRowSetter;

    pub def outputUploadFile( entityType: EntityType
                            , variant: Option[String]
                            , user: String
                            , headers: Array[String]
                            , rows: List[DataRow]
                            , outpath: System.FilePath): Result[Unit, String] & Impure = 
        use AssetLib/FileIO/S4/TransferFile/Printer.{writeTransferFile};
        let fileHeader =  
            { fileType      = Upload
            , dataModel     = U1
            , entityType    = entityType
            , variant       = Option.getWithDefault(variant, "")
            , user          = user
            , dateTime      = Time/LocalDateTime.now()
            };
        let transfer = 
            { fileHeader    =  fileHeader
            , selection     = Nil
            , headers       = headers
            , dataRows      = rows
            };
        writeTransferFile(transfer, outpath)

    pub def execMapUploadRowSetter(headers: Array[String], makeRow: a -> UploadRowSetter[b], xs: List[a]): Result[List[DataRow], String] & Impure = 
        use AssetLib/FileIO/S4/TransferFile/UploadRowSetter.{makeIndices, execUploadRowSetter};
        let size = Array.length(headers);
        let indices = makeIndices(headers);
        Result.traverse(x -> execUploadRowSetter(indices, size, makeRow(x)), xs)


    /// Don't write "CLINT" (internalClassNumber)
    pub def writeClassFlocFile(user: String,
                                rows: List[ClassFlocRow], 
                                outpath: System.FilePath): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let headers = ["FUNCLOC", "CLASS", "CLASSTYPE", "CLSTATUS1"];
        let* rows2 = execMapUploadRowSetter(headers, classFlocSetRow!, rows);
        outputUploadFile(ClassFloc, None, user, headers, rows2, outpath)

    def classFlocSetRow!(x: ClassFlocRow): UploadRowSetter[Unit] = 
        use AssetLib/FileIO/S4/TransferFile/UploadRowSetter.{flatMap, return, putStringNamed!};
        let* _  = putStringNamed!("FUNCLOC",    x.funcloc);
        let* _  = putStringNamed!("CLASS",      x.className);
        let* _  = putStringNamed!("CLASSTYPE",  x.classType);
        let* _  = putStringNamed!("CLSTATUS1",  Option.getWithDefault(Option.map(ToString.toString, x.status), ""));
        return()


    pub def writeValuaFlocFile(user: String,
                                rows: List[ValuaFlocRow], 
                                outpath: System.FilePath): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        use AssetLib/FileIO/S4/TransferFile/UploadWriter.{outputUploadFile, execMapUploadRowSetter};
        let headers = ["FUNCLOC", "CLASSTYPE", "CHARID", "ATWRT", "ATCOD", "TEXTBEZ", "ATZIS", "VALCNT", "ATFLV", "ATFLB"];
        let* rows2 = execMapUploadRowSetter(headers, valuaFlocSetRow!, rows);
        outputUploadFile(ValuaFloc, None, user, headers, rows2, outpath)

    def valuaFlocSetRow!(x: ValuaFlocRow): UploadRowSetter[Unit] = 
        use AssetLib/FileIO/S4/TransferFile/UploadRowSetter.{flatMap, return, putStringNamed!, 
            putInt32Named!, putPaddedInt32Named!};
        let* _  = putStringNamed!("FUNCLOC",    x.funcloc);
        let* _  = putStringNamed!("CLASSTYPE",  x.classType);
        let* _  = putStringNamed!("CHARID",     x.charId);
        let* _  = putStringNamed!("ATWRT",      x.charValue);
        let* _  = putStringNamed!("ATCOD",      Option.getWithDefault(Option.map(ToString.toString, x.code), ""));
        let* _  = putStringNamed!("TEXTBEZ",    x.valueDescription);
        let* _  = putPaddedInt32Named!("ATZIS", 3, x.intCounterValue);
        let* _  = putPaddedInt32Named!("VALCNT", 4, x.intCounterValue);
        let* _  = putStringNamed!("ATFLV",      x.valueFrom);
        let* _  = putStringNamed!("ATFLB",      x.valueTo);
        return()   

    /// Don't write "CLINT" (internalClassNumber)
    pub def writeClassEquiFile(user: String,
                                rows: List[ClassEquiRow], 
                                outpath: System.FilePath): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let headers = ["EQUI", "CLASS", "CLASSTYPE", "CLSTATUS1"];
        let* rows2 = execMapUploadRowSetter(headers, classEquiSetRow!, rows);
        outputUploadFile(ClassEqui, None, user, headers, rows2, outpath)

    def classEquiSetRow!(x: ClassEquiRow): UploadRowSetter[Unit] = 
        use AssetLib/FileIO/S4/TransferFile/UploadRowSetter.{flatMap, return, putStringNamed!};
        let* _  = putStringNamed!("EQUI",       x.equi);
        let* _  = putStringNamed!("CLASS",  x.className);
        let* _  = putStringNamed!("CLASSTYPE",  x.classType);
        let* _  = putStringNamed!("CLSTATUS1",      Option.getWithDefault(Option.map(ToString.toString, x.status), ""));
        return()


    pub def writeValuaEquiFile(user: String,
                                rows: List[ValuaEquiRow], 
                                outpath: System.FilePath): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let headers = ["EQUI", "CLASSTYPE", "CHARID", "ATWRT", "ATCOD", "TEXTBEZ", "ATZIS", "VALCNT","ATFLV", "ATFLB"];
        let* rows2 = execMapUploadRowSetter(headers, valuaEquiSetRow!, rows);
        outputUploadFile(ValuaEqui, None, user, headers, rows2, outpath)

    def valuaEquiSetRow!(x: ValuaEquiRow): UploadRowSetter[Unit] = 
        use AssetLib/FileIO/S4/TransferFile/UploadRowSetter.{flatMap, return, putStringNamed!, 
            putInt32Named!, putPaddedInt32Named!};
        let* _  = putStringNamed!("EQUI",       x.equi);
        let* _  = putStringNamed!("CLASSTYPE",  x.classType);
        let* _  = putStringNamed!("CHARID",     x.charId);
        let* _  = putStringNamed!("ATWRT",      x.charValue);
        let* _  = putStringNamed!("ATCOD",      Option.getWithDefault(Option.map(ToString.toString, x.code), ""));
        let* _  = putStringNamed!("TEXTBEZ",    x.valueDescription);
        let* _  = putPaddedInt32Named!("ATZIS", 3, x.intCounterValue);
        let* _  = putPaddedInt32Named!("VALCNT", 4, x.intCounterValue);
        let* _  = putStringNamed!("ATFLV",      x.valueFrom);
        let* _  = putStringNamed!("ATFLB",      x.valueTo);
        return()    



}
