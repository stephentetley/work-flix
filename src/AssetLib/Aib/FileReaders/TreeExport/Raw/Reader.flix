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

use FactIO/Csv.{CsvRowEvaluator};
use FactIO/Csv/Import.{getRows};

use AssetLib/Aib/FileReaders/TreeExport/Raw/Datatypes.{AibTreeFile, AibRow};

/// Use FactIO but build a list rather than a set of relations.

namespace AssetLib/Aib/FileReaders/TreeExport/Raw/Reader {


    pub def readAibTreeFile(path: String): Result[AibTreeFile, System.Error] & Impure =    
        use Result.flatMap;
        use FactIO/Csv/CsvFormat.{excel, withFirstRecordAsHeader};
        let* src = FactIO/Csv/Import.newCsvStreamWithBOM(path, excel().withFirstRecordAsHeader(), Text/Charset.utf_8());
        let* xs = FactIO/Csv/Import.getRows(getAibRow(), src);
        Ok(xs)


    def getAibRow(): CsvRowEvaluator[AibRow] =
        use FactIO/Csv/RowEvaluator.{flatMap, return, getStringByLabel}; 
        let* reference      = getStringByLabel("Reference");
        let* commonName     = getStringByLabel("Common Name");
        return({reference = reference, commonName = commonName})

}