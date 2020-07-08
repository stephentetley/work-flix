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

use FactIO/Csv.CsvWriter;
use FactIO/Csv/Export.{new => newCsvWriter, writeRow, close};

use AssetLib/Common/Utils.{foreachR};
use AssetLib/S4/FileIO/IH06Tree/Raw/Datatypes.{IH06Tree, IH06Node};
use AssetLib/S4/FileIO/IH06Tree/Raw/Datatypes.IH06Node.{FlocNode, EquiNode};

/// TODO - this is an out-of-date format...
/// It should be derived from the tree representation and export two 
/// sheets - one for flocs one for equi and both should have level.
namespace AssetLib/S4/FileIO/IH06Tree/Raw/ExportCsv {

    /// Flocs
    pub def exportFlocCsv(xs: List[IH06Tree], path: String): Result[Unit, System.Error] & Impure =
        use Result.flatMap;
        let* writer = newCsvWriter(path, Text/Charset.utf_8(), flocHeaders());
        let* _ = foreachR(emitIH06Flocs(writer), xs);
        let _ = writer.close();
        Ok()


    def flocHeaders(): Array[String] & Impure = 
        [ "Floc", "Level", "Description", "Parent Floc" ]


    def emitIH06Flocs(writer: CsvWriter, src: IH06Tree): Result[Unit, System.Error] & Impure = 
        use Result.flatMap;
        let RoseTree(label, kids) = src;
        let* _ = emitFlocNode(writer, label);
        foreachR(emitIH06Flocs(writer), kids)

    def emitFlocNode(writer: CsvWriter, src: IH06Node): Result[Unit, System.Error] & Impure = 
        match src { 
            case FlocNode(r) => { 
                let row = [ r.floc, Int32.toString(r.level), r.description, r.parent ];
                writeRow(writer, row)
            }
            case _ => Ok()
        }


    /// Equis
    pub def exportEquiCsv(xs: List[IH06Tree], path: String): Result[Unit, System.Error] & Impure =
        use Result.flatMap;
        let* writer = newCsvWriter(path, Text/Charset.utf_8(), equiHeaders());
        let* _ = foreachR(emitIH06Equis(writer), xs);
        let _ = writer.close();
        Ok()


    def equiHeaders(): Array[String] & Impure = 
        [ "EquiId", "Level", "Description", "Parent Floc", "Superordinate Equi" ]


    def emitIH06Equis(writer: CsvWriter, src: IH06Tree): Result[Unit, System.Error] & Impure = 
        use Result.flatMap;
        let RoseTree(label, kids) = src;
        let* _ = emitEquiNode(writer, label);
        foreachR(emitIH06Equis(writer), kids)

    def emitEquiNode(writer: CsvWriter, src: IH06Node): Result[Unit, System.Error] & Impure = 
        match src { 
            case EquiNode(r) => { 
                let row = [ r.equiId, Int32.toString(r.level), r.description, r.floc, r.superordinate ];
                writeRow(writer, row)
            }
            case _ => Ok()
        }


}