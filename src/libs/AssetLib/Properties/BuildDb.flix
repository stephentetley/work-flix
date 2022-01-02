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

namespace AssetLib/Properties/BuildDb {

    use SheetIO/Reader.{XlsxSource};

    use AssetLib/Properties/Relations.{StringProperty, IntProperty, FloatProperty};

    /// A temporary untyped property
    pub rel UniProperty(rowId: Int32, name: String, value: String)

    pub rel AibType(propName: String, aibType: String)

    pub def readAibExport(src: XlsxSource): Result[#{UniProperty | r}, String] & Impure = 
        use Result.flatMap;
        let* allRows = SheetIO/Reader.allRows(SheetIO/RowEvaluator.getRowContents(), src);
        match allRows { 
            case Nil          => Ok(#{})
            case hdrs :: rows => { 
                let headers = Array.map(String.toUpperCase, hdrs);
                RelLib/Relation.foldMapWithIndex(makeUniProperties(headers), rows) |> Ok
            }
        }
        

    pub def readAibTypes(src: System.FilePath): Result[#{AibType | r}, String] & Impure = 
        use Result.flatMap;
        use CsvIO/RowEvaluator.{getStringAt};
        let format = CsvIO/CsvFormat.defaultFormat(None) |> CsvIO/CsvFormat.putFirstRecordAsHeader;
        let eval = Applicative.product(getStringAt(0), getStringAt(1));
        let mk1 = xy -> {let (x,y) = xy; #{ AibType(x, y). }};
        let* rows = CsvIO/CsvReader.readCsv(format, Text/Charset.utf_8(), eval, src);
        RelLib/Relation.foldMap(mk1, rows) |> Ok


    
    def makeUniProperties(headers: Array[String], row: Array[String], rowNum: Int32): #{UniProperty | r} & Impure = 
        let step = (ac, a, b) -> ac <+> #{ UniProperty(rowNum, a, b). };
        Array.foldLeft2(step, #{}, headers, row)
    

}
