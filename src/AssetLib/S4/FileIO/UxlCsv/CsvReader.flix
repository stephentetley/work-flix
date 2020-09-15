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
    
use FactIO/CsvImport.{};
use FactIO.CsvRowEvaluator;

use AssetLib/S4/FileIO/UxlCsv/Datatypes.{FlClassification, EqClassification};

namespace AssetLib/S4/FileIO/UxlCsv/CsvReader {

    /// Note - the Csv input may trail with blank rows...

    pub def loadFlClassifications(path: System.FilePath): Result[List[FlClassification], System.Error] & Impure =    
        use Result.flatMap;
        use FactIO/CsvFormat.{excel};
        let* src0   = FactIO/CsvImport.newCsvStreamWithBOM(path, excel(), Text/Charset.utf_8());
        let src     = Data/Stream.drop(6, src0);
        let* xs     = FactIO/CsvImport.evaluateRowsSkipEmptyRows(evalFlClassification(), src);
        Ok(xs)


    def evalFlClassification(): CsvRowEvaluator[FlClassification] = 
        use FactIO/CsvRowEvaluator.{flatMap, return, getStringByIndex, getInt32ByIndex};
        let* floc                   = getStringByIndex(0);
        let* deleteInd              = getBool(1);
        let* classType              = getStringByIndex(2);
        let* className              = getStringByIndex(3);
        let* status                 = getInt32ByIndex(4);
        let* characteristicName     = getStringByIndex(5);
        let* charValue              = getStringByIndex(6);
        let* charDeleteInd          = getBool(7);
        return({ 
            functionalLocation = floc, 
            deletionInd = deleteInd, 
            classType = classType, 
            className = className, 
            status = status, 
            characteristicName = characteristicName, 
            charValue = charValue, 
            charDeletionInd = charDeleteInd
            })


    pub def loadEqClassifications(path: System.FilePath): Result[List[EqClassification], System.Error] & Impure =    
        use Result.flatMap;
        use FactIO/CsvFormat.{excel};
        let* src0   = FactIO/CsvImport.newCsvStreamWithBOM(path, excel(), Text/Charset.utf_8());
        let src     = Data/Stream.drop(6, src0);
        let* xs     = FactIO/CsvImport.evaluateRowsSkipEmptyRows(evalEqClassification(), src);
        Ok(xs)


    def evalEqClassification(): CsvRowEvaluator[EqClassification] = 
        use FactIO/CsvRowEvaluator.{flatMap, return, getStringByIndex, getInt32ByIndex};
        let* equiId                 = getStringByIndex(0);
        let* deleteInd              = getBool(1);
        let* classType              = getStringByIndex(2);
        let* className              = getStringByIndex(3);
        let* status                 = getInt32ByIndex(4);
        let* characteristicName     = getStringByIndex(5);
        let* charValue              = getStringByIndex(6);
        let* charDeleteInd          = getBool(7);
        return({ 
            equiId = equiId, 
            deleteInd = deleteInd, 
            classType = classType, 
            className = className, 
            status = status, 
            characteristicName = characteristicName, 
            charValue = charValue, 
            charDeleteInd = charDeleteInd
            })

    def getBool(ix: Int32): CsvRowEvaluator[Bool] = 
        use FactIO/CsvRowEvaluator.{flatMap, getStringByIndex, return};
        let* x = getStringByIndex(ix);
        if (x == "X") return(true) else return(false)

}