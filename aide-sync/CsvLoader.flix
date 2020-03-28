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

namespace AideSync/CsvLoader {

    /// Repeated attributes

    def readCteAiRepeatedAttribute1[r](row: CsvRow): CsvResult[#{ AiRepeatedAttribute | r }] = 
        ValidationExtras.pipeV4(
            CsvImport.getStringByIndex(row, 5),
            CsvImport.getStringByIndex(row, 7),
            CsvImport.getStringByIndex(row, 8),
            CsvImport.getStringByIndex(row, 9),
            (x,y,z1, z2) -> AiRepeatedAttribute(x, y, z1, z2).
        )

    pub def importCteAiRepeatedAttributes[r](path: String): Result[#{ AiRepeatedAttribute | r }, String] & Impure =
        use Result.flatMap;
        let* src = CsvImport.newCsvSource(path, CsvImport/CsvFormat.Default, true);
        CsvImport.iterate(readCteAiRepeatedAttribute1, src)
        
    /// TODO - change to byLabel once it is fixed...
    def readCteAideRepeatedAttribute1[r](row: CsvRow): CsvResult[#{ AideRepeatedAttribute | r }] = 
        ValidationExtras.pipeV4(
            CsvImport.getStringByIndex(row, 5),
            CsvImport.getStringByIndex(row, 8),
            CsvImport.getStringByIndex(row, 9),
            CsvImport.getStringByIndex(row, 10),
            (x,y,z1,z2) -> AideRepeatedAttribute(x, y, z1, z2).
        )

    pub def importCteAideRepeatedAttributes[r](path: String): Result[#{ AideRepeatedAttribute | r }, String] & Impure =    
        use Result.flatMap;
        let* src = CsvImport.newCsvSource(path, CsvImport/CsvFormat.Default, true);
        CsvImport.iterate(readCteAideRepeatedAttribute1, src)
        

    /// Attributes

    def readCteAiAttribute1[r](row: CsvRow): CsvResult[#{ AiAttribute | r }] = 
        ValidationExtras.pipeV3(
            CsvImport.getStringByIndex(row, 5),
            CsvImport.getStringByIndex(row, 7),
            CsvImport.getStringByIndex(row, 8),
            (x,y,z) -> AiAttribute(x, y, z).
        )

    pub def importCteAiAttributes[r](path: String): Result[#{ AiAttribute | r }, String] & Impure =    
        use Result.flatMap;
        let* src = CsvImport.newCsvSource(path, CsvImport/CsvFormat.Default, true);
        CsvImport.iterate(readCteAiAttribute1, src)


    /// TODO - change to byLabel once it is fixed...
    def readCteAideAttribute1[r](row: CsvRow): CsvResult[#{ AideAttribute | r }] = 
        ValidationExtras.pipeV3(
            CsvImport.getStringByIndex(row, 5),
            CsvImport.getStringByIndex(row, 8),
            CsvImport.getStringByIndex(row, 9),
            (x,y,z) -> AideAttribute(x, y, z).
        )

    pub def importCteAideAttributes[r](path: String): Result[#{ AideAttribute | r }, String] & Impure =
        use Result.flatMap;
        let* src = CsvImport.newCsvSource(path, CsvImport/CsvFormat.Default, true);
        CsvImport.iterate(readCteAideAttribute1, src)
        

    /// Assets

    def readCteAiAsset1[r](row: CsvRow): CsvResult[#{ AiAsset | r }] = 
        ValidationExtras.pipeV5(
            CsvImport.getStringByIndex(row, 5),
            CsvImport.getStringByIndex(row, 6),
            CsvImport.getStringByIndex(row, 8),
            CsvImport.getStringByIndex(row, 9),
            CsvImport.getStringByIndex(row, 10),
            (x,y,z1,z2,z3) -> AiAsset(x, y, z1, z2, z3).
        )

    pub def importCteAiAssets[r](path: String): Result[#{ AiAsset| r }, String] & Impure =
        use Result.flatMap;
        let* src = CsvImport.newCsvSource(path, CsvImport/CsvFormat.Default, true);
        CsvImport.iterate(readCteAiAsset1, src)


    /// TODO - change to byLabel once it is fixed...
    def readCteAideAsset1[r](row: CsvRow): CsvResult[#{ AideAsset | r }] = 
        ValidationExtras.pipeV5(
            CsvImport.getStringByIndex(row, 5),
            CsvImport.getStringByIndex(row, 6),
            CsvImport.getStringByIndex(row, 9),
            CsvImport.getStringByIndex(row, 10),
            CsvImport.getStringByIndex(row, 11),
            (x,y,z1,z2,z3) -> AideAsset(x, y, z1, z2, z3).
        )

    pub def importCteAideAssets[r](path: String): Result[#{ AideAsset | r }, String] & Impure =    
        use Result.flatMap;            
        let* src = CsvImport.newCsvSource(path, CsvImport/CsvFormat.Default, true);
        CsvImport.iterate(readCteAideAsset1, src)

}