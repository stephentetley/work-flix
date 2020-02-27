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

rel AibRef(sapId: String, aibId: String)
rel FlocInfo(floc: String, objType: String)
rel EquiInfo(floc: String, objType: String, manufacturer: String, model:String)


namespace CsvLoader {

    def readEquiCsv1[r](row: CsvRow): CsvResult[#{ EquiAib | r }] = 
        Validation.pipeV2(
            CsvImport.getStringByIndex(row, 0),
            CsvImport.getStringByIndex(row, 10),
            (x,y) -> EquiAib(x, y).
        )

    pub def importEquiAibs[r](path: String): Result[#{ EquiAib | r }, String] =    
        match CsvImport.newCsvSource(path, CsvFormat.Default, true) {
            case Err(msg) => Err(msg)
            case Ok(src) => 
                match CsvImport.collect(readEquiCsv1, src) {
                    case Err(msg) => Err(msg)
                    case Ok(relns) => Ok(relns)
                }
        }


}