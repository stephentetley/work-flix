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


namespace CsvLoader {

    /// Repeated attributes

    def readAiRepeatedAttribute1[r](row: CsvRow): CsvResult[#{ AiRepeatedAttribute | r }] = 
        Validation.pipeV3(
            CsvImport.getStringByIndex(row, 5),
            CsvImport.getStringByIndex(row, 7),
            CsvImport.getStringByIndex(row, 8),
            (x,y,z) -> AiRepeatedAttribute(x, y, z).
        )

    pub def importAiRepeatedAttributes[r](path: String): Result[#{ AiRepeatedAttribute | r }, String] =    
        Result.flatMap(
            csv -> CsvImport.collect(readAiRepeatedAttribute1, csv),
            CsvImport.newCsvSource(path, CsvFormat.Default, true)
        )
        
    /// TODO - change to byLabel once it is fixed...
    def readAideRepeatedAttribute1[r](row: CsvRow): CsvResult[#{ AideRepeatedAttribute | r }] = 
        Validation.pipeV3(
            CsvImport.getStringByIndex(row, 5),
            CsvImport.getStringByIndex(row, 8),
            CsvImport.getStringByIndex(row, 9),
            (x,y,z) -> AideRepeatedAttribute(x, y, z).
        )

    pub def importAideRepeatedAttributes[r](path: String): Result[#{ AideRepeatedAttribute | r }, String] =    
        Result.flatMap(
            csv -> CsvImport.collect(readAideRepeatedAttribute1, csv),
            CsvImport.newCsvSource(path, CsvFormat.Default, true)
        )

    /// Attributes

    def readAiAttribute1[r](row: CsvRow): CsvResult[#{ AiAttribute | r }] = 
        Validation.pipeV3(
            CsvImport.getStringByIndex(row, 5),
            CsvImport.getStringByIndex(row, 7),
            CsvImport.getStringByIndex(row, 8),
            (x,y,z) -> AiAttribute(x, y, z).
        )

    pub def importAiAttributes[r](path: String): Result[#{ AiAttribute | r }, String] =    
        Result.flatMap(
            csv -> CsvImport.collect(readAiAttribute1, csv),
            CsvImport.newCsvSource(path, CsvFormat.Default, true)
        )

    /// TODO - change to byLabel once it is fixed...
    def readAideAttribute1[r](row: CsvRow): CsvResult[#{ AideAttribute | r }] = 
        Validation.pipeV3(
            CsvImport.getStringByIndex(row, 5),
            CsvImport.getStringByIndex(row, 8),
            CsvImport.getStringByIndex(row, 9),
            (x,y,z) -> AideAttribute(x, y, z).
        )

    pub def importAideAttributes[r](path: String): Result[#{ AideAttribute | r }, String] =    
        Result.flatMap(
            csv -> CsvImport.collect(readAideAttribute1, csv),
            CsvImport.newCsvSource(path, CsvFormat.Default, true)
        )

    /// Assets

    def readAiAsset1[r](row: CsvRow): CsvResult[#{ AiAsset | r }] = 
        Validation.pipeV5(
            CsvImport.getStringByIndex(row, 5),
            CsvImport.getStringByIndex(row, 6),
            CsvImport.getStringByIndex(row, 8),
            CsvImport.getStringByIndex(row, 9),
            CsvImport.getStringByIndex(row, 10),
            (x,y,z, z2, z3) -> AiAsset(x, y, z, z2, z3).
        )

    pub def importAiAssets[r](path: String): Result[#{ AiAsset| r }, String] =    
        Result.flatMap(
            csv -> CsvImport.collect(readAiAsset1, csv),
            CsvImport.newCsvSource(path, CsvFormat.Default, true)
        )

    /// TODO - change to byLabel once it is fixed...
    def readAideAsset1[r](row: CsvRow): CsvResult[#{ AideAsset | r }] = 
        Validation.pipeV5(
            CsvImport.getStringByIndex(row, 5),
            CsvImport.getStringByIndex(row, 6),
            CsvImport.getStringByIndex(row, 9),
            CsvImport.getStringByIndex(row, 10),
            CsvImport.getStringByIndex(row, 11),
            (x,y,z, z2, z3) -> AideAsset(x, y, z, z2, z3).
        )

    pub def importAideAssets[r](path: String): Result[#{ AideAsset | r }, String] =    
        Result.flatMap(
            csv -> CsvImport.collect(readAideAsset1, csv),
            CsvImport.newCsvSource(path, CsvFormat.Default, true)
        )

}