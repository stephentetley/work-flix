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

namespace S4Download {

    pub opaque type DownloadRow = Map[String, String]

    def makeRow(headers: List[String], values: List[String]): DownloadRow = 
        let ans = List.zip(headers, values) |> List.toMap;
        DownloadRow(ans)


    pub def makeRows(x: S4Download/Parser.DownloadFile): List[DownloadRow] = 
        let S4Download/Parser/DownloadFile.DownloadFile(body) = x;
        let colnames = body.columnheaders;
        let rows = body.rows;
        List.map(makeRow(colnames), rows)


    pub def getValue(key: String, x: DownloadRow): String = 
        let DownloadRow(body) = x;
        Map.get(key, body) |> x -> Option.getWithDefault(x, "MISSING")

}