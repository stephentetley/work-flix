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

use FactIO/Csv.CsvRowEvaluator;
use FactIO/Csv/Import.{newCsvStream, importRows};
use FactIO/Csv/CsvFormat.{withFirstRecordAsHeader};


use AssetLib/S4/FileIO/ClassList/Relations.Datatype;
use AssetLib/S4/FileIO/ClassList/Relations.Datatype.{Text, Date, IntNum, DecimalNum};
use AssetLib/S4/FileIO/ClassList/Relations.{EquiCharacteristic};

namespace AssetLib/S4/FileIO/ClassList/CsvLoader {

    def getDatatypeByIndex(ix: Int32): CsvRowEvaluator[Datatype] = 
        use FactIO/Csv/RowEvaluator.{flatMap, return, getStringByIndex, throwError};
        let* str = getStringByIndex(ix);
        match str { 
            case "Text"         => return(Text)
            case "IntNum"       => return(IntNum)
            case "DecimalNum"   => return(DecimalNum)
            case "Date"         => return(Date)
            case _              => throwError(System/Error.Generic("Unknown datatype: " + str))
        }

    def evalEquiCharacteristic[r](): CsvRowEvaluator[#{ EquiCharacteristic | r }] = 
        use FactIO/Csv/RowEvaluator.{flatMap, return, getStringByIndex, getInt32ByIndex, optional};
        let* classType      = getStringByIndex(0);
        let* className      = getStringByIndex(1);
        let* charName       = getStringByIndex(2);
        let* datatype       = getDatatypeByIndex(3);
        let* charLength     = getInt32ByIndex(4);
        let* optPrecision   = optional(getInt32ByIndex(5));
        return( EquiCharacteristic(classType, className, charName, datatype, charLength, optPrecision). )

    pub def loadEquiCharacteristic[r](path: String): Result[#{ EquiCharacteristic | r }, System.Error] & Impure = 
        use Result.flatMap;        
        let* src = newCsvStream(path, FactIO/Csv/CsvFormat.default().withFirstRecordAsHeader(), Text/Charset.utf_8());
        importRows(evalEquiCharacteristic(), src)

    // type alias DbPaths = { pathOfEqobjl: String
    //                     , pathOfFlocdes: String
    //                     , pathOfFloobjl: String
    //                     , pathOfManuf: String
    //                     , pathOfObj: String
    //                     }

    // pub def loadDb[r](paths: DbPaths): Result[#{ Eqobjl, Flocdes, Floobjl, Manuf, Obj | r }, System.Error] & Impure =
    //     use Result.flatMap;
    //     let* r1 = loadEqobjl(paths.pathOfEqobjl);
    //     let* r2 = loadFlocdes(paths.pathOfFlocdes);        
    //     let* r3 = loadFloobjl(paths.pathOfFloobjl);        
    //     let* r4 = loadManuf(paths.pathOfManuf);
    //     let* r5 = loadObj(paths.pathOfObj);
    //     Ok(solve r1 <+> r2 <+> r3 <+> r4 <+> r5)

}