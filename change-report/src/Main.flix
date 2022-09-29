/*
 * Copyright 2022 Stephen Tetley
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


def main(): Int32 \ IO = 
    let inpath    = Basis/System/Path.newPath("G:/work/assets/change-requests/sample1.xlsx");
    match Result.flatMap(Main1.main1, inpath) { 
        case Ok()     => {println("done"); 0}
        case Err(msg) => {println("Error: ${msg}"); 1}
    }

namespace Main1 {

    use Basis/System.Path;



    pub def main1(inpath: Path): Result[Unit, String] \ IO = 
        use Result.flatMap;
        use AssetS/ChangeReport/Relations.{Change, SimpleRow, SourceRow};
        let outpath     = Basis/System/Path.putExtension(inpath, "sqlite");
        let* _          = AssetS/ChangeReport/InitDb.createCRDatabase(outpath);
        let* rows       = AssetS/ChangeReport/Reader.readChangeReport(inpath);
        List.foreach(println, List.take(5, rows));
        let db          = AssetS/ChangeReport/MakeRelations.makeRowRelations(rows);
        let sources     = query db select (x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13) from SourceRow(x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13);
        let* _          = AssetS/ChangeReport/StoreChanges.storeSourceRows(sources, outpath);
        let solns       = (solve db project SimpleRow) <+> AssetS/ChangeReport/DecodeChanges.decodeChanges();
        let changes     = query solns select (x1, x2, x3, x4, x5) from Change(x1, x2, x3, x4, x5);
        let* _          = AssetS/ChangeReport/StoreChanges.storeChanges(changes, outpath);
        Ok()
}
