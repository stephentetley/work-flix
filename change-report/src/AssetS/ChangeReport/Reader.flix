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

namespace AssetS/ChangeReport/Reader {

    use Functor.{<$>};
    use Applicative.{<*>};
 
    use MonadLib/MonadOr.{optional};

    use Basis/System.Path;

    use SheetIO.WorkbookReader;
    use SheetIO.RowEvaluator;

    

    pub def readChangeReport(path: Path): Result[List[Map[String, String]], String] \ IO = region r1 {
        use SheetIO/WorkbookReader.{runXlsx};
        runXlsx(r1, readChangeReport1(), path)
    }

    def readChangeReport1(): WorkbookReader[r, ka, List[Map[String, String]]] \ { Read(r) } = 
        use SheetIO/WorkbookReader.{flatMap, point};
        let* hs = readHeaders();
        let* rs = readRows(hs);
        point(rs)


    def readHeaders(): WorkbookReader[r, ka, List[String]] \ Read(r) = 
        use SheetIO/WorkbookReader.{flatMap, point, getSheetNamed, withSheetReader};
        let* sheet1 = getSheetNamed("Data");
        let* hs = withSheetReader(SheetIO/SheetReader.getHeaders(2), sheet1);
        point(makeUniqueHeaders(hs))
        

    def readRows(headers: List[String]): WorkbookReader[r, ka, List[Map[String, String]]] \ Read(r) = 
        use SheetIO/WorkbookReader.{flatMap, point, getSheetNamed, withSheetReader};
        let* sheet1 = getSheetNamed("Data");
        let* rs     = withSheetReader(SheetIO/SheetReader.allRowsFrom(3, dataRow(headers)), sheet1);
        point(List.mapWithIndex((a, ix) -> annotateRow(ix+4, a), rs))

    def dataRow(headers: List[String]): RowEvaluator[r, ka, Map[String, String]] \ Read(r) =
        use SheetIO/RowEvaluator.{flatMap, point, getRowContents};
        let* cells = getRowContents();
        point(List.foldLeft2((acc, k, v) -> Map.insert(k, v, acc), Map.empty(), headers, cells))


    def makeUniqueHeaders(names: List[String]): List[String] =
        let step = (acc, key) -> { 
            let (col, counts, indices) = acc; 
            match Map.get(key, counts) {
                case None    => (col + 1, Map.insert(key, 1, counts), Map.insert(col, key, indices))
                case Some(i) => (col + 1, Map.insert(key, i + 1, counts), Map.insert(col, "${key}.${i}", indices))
            }
        };        
        let (_, _, cols) = List.foldLeft(step, (0, Map.empty(), Map.empty()), names);
        List.mapWithIndex((name, ix) -> Map.get(ix, cols) |> Option.getWithDefault(name), names)

    def annotateRow(rownum: Int32, m: Map[String, String]): Map[String, String] = 
        Map.insert("RowIx", ToString.toString(rownum), m) |> Map.remove("User Name")
        
}
