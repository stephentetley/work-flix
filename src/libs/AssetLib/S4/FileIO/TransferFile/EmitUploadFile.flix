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

namespace AssetLib/S4/FileIO/TransferFile/EmitUploadFile {

    use AssetLib/S4/FileIO/TransferFile/Datatypes.{EntityType, DataRow};
    use AssetLib/S4/FileIO/TransferFile/Datatypes.FileType.{Upload};
    use AssetLib/S4/FileIO/TransferFile/Datatypes.DataModel.{U1};
    use AssetLib/S4/FileIO/TransferFile.RowSetter;

    pub def outputUploadFile( entityType: EntityType
                            , variant: String
                            , user: String
                            , headers: Array[String]
                            , rows: List[DataRow]
                            , outpath: System.FilePath): Result[Unit, String] & Impure = 
        use AssetLib/S4/FileIO/TransferFile/Printer.{writeTransferFile};
        let fileHeader =  
            { fileType      = Upload
            , dataModel     = U1
            , entityType    = entityType
            , variant       = variant
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

    pub def execMapRowSetter(headers: Array[String], makeRow: a -> RowSetter[b], xs: List[a]): Result[List[DataRow], String] & Impure = 
        use AssetLib/S4/FileIO/TransferFile/RowSetter.{makeIndices, execRowSetter};
        let size = Array.length(headers);
        let indices = makeIndices(headers);
        Result.traverse(x -> execRowSetter(indices, size, makeRow(x)), xs)


}
