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

use FactIO.CsvExport;
use FactIO.CsvRowSetter;

use AssetLib/Aib/FileIO/TreeExport/Raw/Datatypes.{AibTree, AibNode};

namespace AssetLib/Aib/FileIO/TreeExport/Raw/CsvExport {


    pub def exportAibTreesCsv(src: List[AibTree], path: System.FilePath): Result[Unit, System.Error] & Impure =
        use Result.{flatMap};
        use FactIO/CsvExport.{runCsvExport, traverseX};
        let headers = characteristicHeaders();
        let* _ = runCsvExport(traverseX(writeAibTree, src), path, FactIO/CsvFormat.default(), headers, Text/Charset.utf_8());
        Ok()
        


    def characteristicHeaders(): Array[String] & Impure = 
        [ "Level", "Reference", "Short Name", "Parent", "Common Name" ]


    def writeAibTree(src: AibTree): CsvExport[Unit] = 
        use FactIO/CsvExport.{flatMap, writeRow, traverseX};
        let RoseTree(label, kids) = src;
        let* _ = writeRow(emitAibNode(label));
        traverseX(writeAibTree, kids)

    def emitAibNode(src: AibNode): CsvRowSetter[Unit] = 
        use FactIO/CsvRowSetter.{flatMap, return, putString!, putInt32!};
        let* _ = putInt32!(0, src.level); 
        let* _ = putString!(1, src.reference); 
        let* _ = putString!(2, src.shortName);
        let* _ = putString!(3, src.parent); 
        let* _ = putString!(4, src.commonName);
        return()



}