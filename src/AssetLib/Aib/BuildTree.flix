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

use FactIO/Csv.CsvFormat;
use FactIO/Csv.CsvRowEvaluator;
use FactIO/Csv.CsvWriter;
use FactIO/Csv/Export.{new => newCsvWriter, writeRow, close};

namespace AssetLib/Aib/BuildTree {

    type alias StackElem = { reference: String, commonName: String }

    pub rel AibRow(ix: Int32, reference: String, shortName: String, commonName: String, parent: String)

    type alias Stack = List[StackElem]

    def top(x: Stack): Option[StackElem] = List.head(x)

    def pop(x: Stack): Stack = match x {
        case Nil => Nil
        case _ :: rs => rs
    }

    def push(reference: String, commonName: String, xs: Stack): Stack =
        { reference = reference, commonName = commonName} :: xs

    def getParent(commonName: String, stk: Stack): Option[(StackElem, Stack)] = match top(stk) { 
        case None => None
        case Some(t) if String.isPrefixOf(t.commonName, commonName) => Some((t, stk))
        case Some(_) => getParent(commonName, pop(stk))
    }

    def dropSlash1(shortName: String): String = 
        String.stripPrefix("/", shortName) |> x -> Option.getWithDefault(x, shortName)

    def readAibRow1[r](ix:Int32, stk: Stack): CsvRowEvaluator[(#{ AibRow | r }, Stack)] =
        use FactIO/Csv/RowEvaluator.{flatMap, return, map, getStringByLabel};
        let* reference      = getStringByLabel("Reference");
        let* commonName     = getStringByLabel("Common Name");
        let (parent, stk1)  = match getParent(commonName, stk) { 
            case None => ({reference = "", commonName = ""}, Nil)
            case Some(xy) => xy
        };
        let shortName       = 
            String.stripPrefix(parent.commonName, commonName) 
                |> x -> Option.getWithDefault(x, commonName)
                |> dropSlash1;
        let stk2 = push(reference, commonName, stk1);
        return(( AibRow(ix, reference, shortName, commonName, parent.reference). , stk2))

    pub def readAibRows[r](path: String): Result[#{ AibRow | r }, System.Error] & Impure =    
        use Result.flatMap;
        use FactIO/Csv/CsvFormat.{excel, withFirstRecordAsHeader};
        let* src = FactIO/Csv/Import.newCsvStreamWithBOM(path, excel().withFirstRecordAsHeader(), Text/Charset.utf_8());
        let* (reln, _) = FactIO/Csv/Import.importRowsWithCountAndAccum(readAibRow1, Nil, src);
        Ok(solve reln)

    /// Write

    def headers(): Array[String] & Impure = 
        [ "Index", "Reference", "Short Name", "Common Name", "Parent Ref" ]

    def getAibRowCells(x: (Int32, String, String, String, String)): Array[String] & Impure = 
        let (ix, reference, shortName, commonName, parentRef) = x;
        [ Int32.toString(ix), reference, shortName, commonName, parentRef ]

    pub def writeAibRows[r](src: #{ AibRow | r}, path: String): Result[Unit, System.Error] & Impure =         
        let buildStep = FactIO/Csv/Export.makeCsvBuildStep(getAibRowCells); 
        let builder: FactIO/Csv.CsvBuilder = fold AibRow FactIO/Csv/Export.emptyCsvBuilder() buildStep src;
        FactIO/Csv/Export.outputCsv(path, Text/Charset.utf_8(), headers(), builder)

}