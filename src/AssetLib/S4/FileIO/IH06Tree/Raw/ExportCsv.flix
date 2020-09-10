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

use AssetLib/S4/FileIO/IH06Tree/Raw/Datatypes.{IH06Tree, IH06Node};
use AssetLib/S4/FileIO/IH06Tree/Raw/Datatypes.IH06Node.{FlocNode, EquiNode};
use AssetLib/S4/FileIO/IH06Tree/Raw/Builder.{buildIH06Trees};
use AssetLib/S4/FileIO/IH06Tree/Raw/Parser.{parseFile, parseFileWithBOM};

namespace AssetLib/S4/FileIO/IH06Tree/Raw/ExportCsv {


    type alias CsvOutputPaths = 
        { flocOutpath: System.FilePath
        , equiOutpath: System.FilePath
        }

    pub def exportCsv(sourceFile: System.FilePath, cs: Text.Charset, hasBOM: Bool, outPaths: CsvOutputPaths): Result[Unit, System.Error] & Impure = 
        use Result.flatMap;
        let* ast    = if (hasBOM) parseFileWithBOM(sourceFile, cs) else parseFile(sourceFile, cs);
        let ans     = buildIH06Trees(ast);
        let* _      = exportFlocCsv(ans, outPaths.flocOutpath);        
        let* _      = exportEquiCsv(ans, outPaths.equiOutpath);
        Ok()


    /// Flocs
    pub def exportFlocCsv(xs: List[IH06Tree], path: System.FilePath): Result[Unit, System.Error] & Impure =
        use Result.{flatMap};
        use FactIO/CsvExport.{runCsvExport, traverseX};
        let headers = [ "Floc", "Level", "Description", "Parent Floc" ];
        let* _ = runCsvExport(traverseX(emitIH06Flocs, xs), path, FactIO/CsvFormat.default(), headers, Text/Charset.utf_8());
        Ok()


    def emitIH06Flocs(src: IH06Tree): CsvExport[Unit] = 
        use FactIO/CsvExport.{flatMap, traverseX};
        let RoseTree(label, kids) = src;
        let* _ = emitFlocNode(label);
        traverseX(emitIH06Flocs, kids)

    def emitFlocNode(src: IH06Node): CsvExport[Unit] = 
        use FactIO/CsvRowSetter.{flatMap, return, putInt32!, putString!};
        match src { 
            case FlocNode(r) => {
                let proc = { 
                    let* _ = putString!(0, r.floc);
                    let* _ = putInt32!(1, r.level);
                    let* _ = putString!(2, r.description);
                    let* _ = putString!(3, r.parent);
                    return()
                };
                FactIO/CsvExport.writeRow(proc)
            }
            case _ => FactIO/CsvExport.return()
        }


    /// Equis
    pub def exportEquiCsv(xs: List[IH06Tree], path: System.FilePath): Result[Unit, System.Error] & Impure =
        use Result.{flatMap};
        use FactIO/CsvExport.{runCsvExport, traverseX};
        let headers = [ "EquiId", "Level", "Description", "Parent Floc", "Superordinate Equi" ];
        let* _ = runCsvExport(traverseX(emitIH06Equis, xs), path, FactIO/CsvFormat.default(), headers, Text/Charset.utf_8());
        Ok()


    def emitIH06Equis(src: IH06Tree): CsvExport[Unit] = 
        use FactIO/CsvExport.{flatMap, traverseX};
        let RoseTree(label, kids) = src;
        let* _ = emitEquiNode(label);
        traverseX(emitIH06Equis, kids)

    def emitEquiNode(src: IH06Node): CsvExport[Unit] = 
        use FactIO/CsvRowSetter.{flatMap, return, putInt32!, putString!};
        match src { 
            case EquiNode(r) => { 
                let proc = {
                    let* _ = putString!(0, r.equiId);
                    let* _ = putInt32!(1, r.level);
                    let* _ = putString!(2, r.description);
                    let* _ = putString!(3, r.floc);
                    let* _ = putString!(4, r.superordinate);
                    return()
                };                
                FactIO/CsvExport.writeRow(proc)
            }
            case _ => FactIO/CsvExport.return()
        }


}