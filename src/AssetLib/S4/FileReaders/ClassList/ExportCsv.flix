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

use FactIO/Csv.CsvWriter;
use FactIO/Csv/Export.{new => newCsvWriter, writeRow, close};

use AssetLib/S4/FileReaders/ClassList/Datatypes.{ClassList, Class, Characteristic, Datatype};
use AssetLib/S4/FileReaders/ClassList/Datatypes.Datatype.{Text, Date, NumInt, NumDecimal};
use AssetLib/S4/FileReaders/ClassList/Datatypes.Refinement.{ListOfValues, IntRange, DecimalRange};


namespace AssetLib/S4/FileReaders/ClassList/ExportCsv {

    def foreachR(fn: a ~> Result[Unit, System.Error], xs: List[a]): Result[Unit, System.Error] & Impure = match xs { 
        case x :: rs => match fn(x) {
            case Ok(_) => foreachR(fn, rs)
            case Err(e) => Err(e)
        }
        case Nil => Ok() 
    }

    pub type alias ExportCsvParams = { charset: Text.Charset
                                    , characteristicsPath: String
                                    , refinesValuesPath: String
                                    , refinesRangePath: String
                                    }

    pub def exportCsv(src: ClassList, params: ExportCsvParams): Result[Unit, System.Error] & Impure = 
        use Result.flatMap;
        let* _ = exportCharacteristicsCsv(src, params.characteristicsPath, params.charset);
        let* _ = exportRefinesValuesCsv(src, params.refinesValuesPath, params.charset);
        let* _ = exportRefinesRangeCsv(src, params.refinesRangePath, params.charset);
        Ok()

    pub def exportCharacteristicsCsv(src: ClassList, path: String, cs: Text.Charset): Result[Unit, System.Error] & Impure =
        use Result.flatMap;
        let headers = characteristicHeaders();
        let* writer = newCsvWriter(path, cs, headers);
        let* _ = foreachR(emitCharacteristics(writer), src.classes);
        let _ = writer.close();
        Ok()

    def characteristicHeaders(): Array[String] & Impure = 
        [ "Class Type", "Class Id", "Characteristic Id", "Datatype", "Char Length", "Decimal Prec" ]



    def emitCharacteristics(writer: CsvWriter, src: Class): Result[Unit, System.Error] & Impure = 
        foreachR(emitCharacteristic(writer, src.classType, src.name), src.characteristics)

    def emitCharacteristic(writer: CsvWriter, classType: String, className: String, src: Characteristic): Result[Unit, System.Error] & Impure = 
        let (typeName, len, prec) = match src.datatype {
            case Text(d) => ("Text", d, "")
            case Date(d) => ("Date", d, "")
            case NumInt(d) => ("Integer", d, "")
            case NumDecimal(d, p) => ("Decimal", d, Int32.toString(p))            
        };
        let row = [ classType, className, src.name, typeName, Int32.toString(len), prec ];
        writeRow(writer, row)


    pub def exportRefinesValuesCsv(src: ClassList, path: String, cs: Text.Charset): Result[Unit, System.Error] & Impure =
        use Result.flatMap;
        let headers = refinesValueHeaders();
        let* writer = newCsvWriter(path, cs, headers);
        let* _ = foreachR(emitRefinesValuesClass(writer), src.classes);
        let _ = writer.close();
        Ok() 
        
    def refinesValueHeaders(): Array[String] & Impure = 
        [ "Class Type", "Class Id", "Characteristic Id", "Value" ]


    def emitRefinesValuesClass(writer: CsvWriter, src: Class): Result[Unit, System.Error] & Impure = 
        foreachR(emitRefinesValues(writer, src.classType, src.name), src.characteristics)

    def emitRefinesValues(writer: CsvWriter, classType: String, className: String, src: Characteristic): Result[Unit, System.Error] & Impure = 
        let step = value -> {
            let row = [ classType, className, src.name, value ];
            writeRow(writer, row)
        };
        match src.refinement {
            case Some(ListOfValues(xs)) => foreachR(step, xs)
            case _ => Ok()
        }

    pub def exportRefinesRangeCsv(src: ClassList, path: String, cs: Text.Charset): Result[Unit, System.Error] & Impure =
        use Result.flatMap;
        let headers = refinesRangeHeaders();
        let* writer = newCsvWriter(path, cs, headers);
        let* _ = foreachR(emitRefinesRangeClass(writer), src.classes);
        let _ = writer.close();
        Ok() 

    def refinesRangeHeaders(): Array[String] & Impure = 
        [ "Class Type", "Class Id", "Characteristic Id", "Lowest", "Highest" ]


    def emitRefinesRangeClass(writer: CsvWriter, src: Class): Result[Unit, System.Error] & Impure = 
        foreachR(emitRefinesRange(writer, src.classType, src.name), src.characteristics)

    def emitRefinesRange(writer: CsvWriter, classType: String, className: String, src: Characteristic): Result[Unit, System.Error] & Impure = 
        let step = (lowest, highest) -> {
            let row = [ classType, className, src.name, Int32.toString(lowest), Int32.toString(highest) ];
            writeRow(writer, row)
        };
        match src.refinement {
            case Some(IntRange(lo, hi)) => step(lo, hi)
            case _ => Ok()
        }



}