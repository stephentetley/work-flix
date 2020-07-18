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

use Data.RoseTree.{RoseTree};
use FactIO.CsvWriter;
use FactIO/CsvExport.{new => newCsvWriter, writeRow, close};

use AssetLib/Common/Utils.{traverseX};
use AssetLib/Aib/FileIO/TreeExport/Raw/Datatypes.{AibTree, AibNode};

namespace AssetLib/Aib/FileIO/TreeExport/Raw/ExportCsv {


    pub def exportAibTreesCsv(src: List[AibTree], path: String): Result[Unit, System.Error] & Impure =
        use Result.flatMap;
        let headers = characteristicHeaders();
        let* writer = newCsvWriter(path, Text/Charset.utf_8(), headers);
        let* _ = traverseX(emitAibTree(writer), src);
        let _ = writer.close();
        Ok()

    def characteristicHeaders(): Array[String] & Impure = 
        [ "Level", "Reference", "Short Name", "Parent", "Common Name" ]


    def emitAibTree(writer: CsvWriter, src: AibTree): Result[Unit, System.Error] & Impure = 
        use Result.flatMap;
        let RoseTree(label, kids) = src;
        let* _ = emitAibNode(writer, label);
        traverseX(emitAibTree(writer), kids)

    def emitAibNode(writer: CsvWriter, src: AibNode): Result[Unit, System.Error] & Impure = 
        let row = [ Int32.toString(src.level), src.reference, src.shortName, src.parent, src.commonName ];
        writeRow(writer, row)



}