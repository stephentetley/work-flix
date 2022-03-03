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

namespace PDTKit/Aggregate/ExcelOutput {
    
    use SheetIO.RowSetter;
    use SheetIO.SheetWriter;

    use RelLib/Lattice/StringAttributes.{StringAttributes};
    use RelLib/Lattice/Int32StringAttributes.{Int32StringAttributes};

    use PDTKit/Aggregate/Schema.{TabSpec, AggregateRow};


    pub def outputExcel(relns: #{TabSpec, AggregateRow | r}, path: System.FilePath): Result[Unit, String] & Impure = 
        use Result.flatMap;
        let headers = makeHeaders(relns);
        let rows    = makeRows(relns);
        let groups  = groupTabs(headers, rows);
        SheetIO/SheetWriter.runXlsx(Foldable.foreachM(xyz -> let (x, y, z) = xyz; writeTab(x, y, z),  groups), path)

    def groupTabs(headers: Map[String, Array[String]], 
                    rows: Array[(String, Map[String, String])]): List[(String, Array[String], List[Map[String, String]])] & Impure = 
        let groups1 = rows |> Array.toList |> List.groupBy((p1, p2) -> fst(p1) == fst(p2));
        let step = xs -> match xs {
            case (classification, _) :: _   => match Map.get(classification, headers) {
                case None           => None
                case Some(hdrs)     => Some((classification, hdrs, xs |> List.map(snd)))
            }
            case _                          => None
        };
        List.filterMap(step, groups1)


    pub def makeHeaders(relns: #{TabSpec | r}): Map[String, Array[String]] & Impure = 
        query relns select (x1, x2) from TabSpec(x1; x2)
            |> Array.map(makeHeaders1)
            |> Array.toMap

    def makeHeaders1(x: (String, Int32StringAttributes)): (String, Array[String]) & Impure = 
        let (classification, attrs) = x;
        let headers = 
            attrs
                |> RelLib/Lattice/Int32StringAttributes.getAttributes1
                |> Map.toList
                |> List.map(snd)
                |> List.append(PDTKit/Aggregate/Rules.columnsPrefix())
                |> List.toArray;
        (classification, headers)

    pub def makeRows(relns: #{AggregateRow | r}): Array[(String, Map[String, String])] & Impure = 
        query relns select (x1, x2, x3, x4, x5) from AggregateRow(x1, x2, x3, x4; x5)
            |> Array.map(makeRow1)

    def makeRow1(x: (String, String, Int32, String, StringAttributes)): (String, Map[String, String]) = 
        let (classification, srcFile, itemNum, assetName, values) = x;
        let cells = 
            values
                |> RelLib/Lattice/StringAttributes.getAttributes1
                |> Map.insert("Source File", srcFile)
                |> Map.insert("Item", ToString.toString(itemNum))
                |> Map.insert("Asset Name", assetName);
        (classification, cells)


    pub def makeRowSetter(headings: List[String], cells: Map[String, String]): RowSetter[Unit] = 
        use Applicative.{*>, point};
        let step = (ac, k) -> {
            let (ix, ma) = ac; 
            match Map.get(k, cells) {
                case Some(v) => (ix+1, ma *> SheetIO/RowSetter.putStringAt!(ix, v))
                case None    => (ix+1, ma)
            }
        };
        List.foldLeft(step, (0, point()), headings) |> snd
        
    /// Note - SheetWriter needs bringing up to date...
    pub def writeTab(classification: String, headings: Array[String], rows: List[Map[String, String]]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, point, createSheet, liftAction, allRowsWithHeaders};
        let* s1         = createSheet(classification);
        let* headings1  = liftAction(_ -> Array.toList(headings));
        let* _          = allRowsWithHeaders(s1, headings, rows, makeRowSetter(headings1));
        point()

}
