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

use FactIO.CsvRowEvaluator;
use FactIO/CsvImport.{newCsvStream, importRows};
use FactIO/CsvFormat.{withFirstRecordAsHeader};


use AssetLib/S4/FileIO/ClassList/Relations.Datatype;
use AssetLib/S4/FileIO/ClassList/Relations.Datatype.{Text, Date, IntNum, DecimalNum};
use AssetLib/S4/FileIO/ClassList/Relations.{FlocCharacteristic, FlocRefinesChoice, FlocRefinesRange,
                                            EquiCharacteristic, EquiRefinesChoice, EquiRefinesRange};

namespace AssetLib/S4/FileIO/ClassList/CsvLoader {

    def getDatatypeByIndex(ix: Int32): CsvRowEvaluator[Datatype] = 
        use FactIO/CsvRowEvaluator.{flatMap, return, getStringByIndex, throwError};
        let* str = getStringByIndex(ix);
        match str { 
            case "Text"         => return(Text)
            case "IntNum"       => return(IntNum)
            case "DecimalNum"   => return(DecimalNum)
            case "Date"         => return(Date)
            case _              => throwError(System/Error.Generic("Unknown datatype: " + str))
        }

    /// FlocCharacteristic
    def evalFlocCharacteristic[r](): CsvRowEvaluator[#{ FlocCharacteristic | r }] = 
        use FactIO/CsvRowEvaluator.{flatMap, return, getStringByIndex, getInt32ByIndex, optional};
        let* classType      = getStringByIndex(0);
        let* className      = getStringByIndex(1);
        let* charName       = getStringByIndex(2);
        let* datatype       = getDatatypeByIndex(3);
        let* charLength     = getInt32ByIndex(4);
        let* optPrecision   = optional(getInt32ByIndex(5));
        return( FlocCharacteristic(classType, className, charName, datatype, charLength, optPrecision). )

    pub def loadFlocCharacteristic[r](path: String): Result[#{ EquiCharacteristic | r }, System.Error] & Impure = 
        use Result.flatMap;        
        let* src = newCsvStream(path, FactIO/CsvFormat.default().withFirstRecordAsHeader(), Text/Charset.utf_8());
        importRows(evalFlocCharacteristic(), src)


    /// FlocRefinesChoice
    def evalFlocRefinesChoice[r](): CsvRowEvaluator[#{ FlocRefinesChoice | r }] = 
        use FactIO/CsvRowEvaluator.{flatMap, return, getStringByIndex, getInt32ByIndex, optional};
        let* classType      = getStringByIndex(0);
        let* className      = getStringByIndex(1);
        let* charName       = getStringByIndex(2);
        let* value          = getStringByIndex(3);
        return( FlocRefinesChoice(classType, className, charName, value). )

    pub def loadFlocRefinesChoice[r](path: String): Result[#{ EquiRefinesChoice | r }, System.Error] & Impure = 
        use Result.flatMap;        
        let* src = newCsvStream(path, FactIO/CsvFormat.default().withFirstRecordAsHeader(), Text/Charset.utf_8());
        importRows(evalFlocRefinesChoice(), src)


    /// FlocRefinesRange
    def evalFlocRefinesRange[r](): CsvRowEvaluator[#{ FlocRefinesRange | r }] = 
        use FactIO/CsvRowEvaluator.{flatMap, return, getStringByIndex, getInt32ByIndex, optional};
        let* classType      = getStringByIndex(0);
        let* className      = getStringByIndex(1);
        let* charName       = getStringByIndex(2);
        let* low            = getInt32ByIndex(3);
        let* high           = getInt32ByIndex(4);
        return( FlocRefinesRange(classType, className, charName, low, high). )

    pub def loadFlocRefinesRange[r](path: String): Result[#{ FlocRefinesRange | r }, System.Error] & Impure = 
        use Result.flatMap;        
        let* src = newCsvStream(path, FactIO/CsvFormat.default().withFirstRecordAsHeader(), Text/Charset.utf_8());
        importRows(evalFlocRefinesRange(), src)

    /// EquiCharacteristic
    def evalEquiCharacteristic[r](): CsvRowEvaluator[#{ EquiCharacteristic | r }] = 
        use FactIO/CsvRowEvaluator.{flatMap, return, getStringByIndex, getInt32ByIndex, optional};
        let* classType      = getStringByIndex(0);
        let* className      = getStringByIndex(1);
        let* charName       = getStringByIndex(2);
        let* datatype       = getDatatypeByIndex(3);
        let* charLength     = getInt32ByIndex(4);
        let* optPrecision   = optional(getInt32ByIndex(5));
        return( EquiCharacteristic(classType, className, charName, datatype, charLength, optPrecision). )

    pub def loadEquiCharacteristic[r](path: String): Result[#{ EquiCharacteristic | r }, System.Error] & Impure = 
        use Result.flatMap;        
        let* src = newCsvStream(path, FactIO/CsvFormat.default().withFirstRecordAsHeader(), Text/Charset.utf_8());
        importRows(evalEquiCharacteristic(), src)


    /// EquiRefinesChoice
    def evalEquiRefinesChoice[r](): CsvRowEvaluator[#{ EquiRefinesChoice | r }] = 
        use FactIO/CsvRowEvaluator.{flatMap, return, getStringByIndex, getInt32ByIndex, optional};
        let* classType      = getStringByIndex(0);
        let* className      = getStringByIndex(1);
        let* charName       = getStringByIndex(2);
        let* value          = getStringByIndex(3);
        return( EquiRefinesChoice(classType, className, charName, value). )

    pub def loadEquiRefinesChoice[r](path: String): Result[#{ EquiRefinesChoice | r }, System.Error] & Impure = 
        use Result.flatMap;        
        let* src = newCsvStream(path, FactIO/CsvFormat.default().withFirstRecordAsHeader(), Text/Charset.utf_8());
        importRows(evalEquiRefinesChoice(), src)


    /// EquiRefinesRange
    def evalEquiRefinesRange[r](): CsvRowEvaluator[#{ EquiRefinesRange | r }] = 
        use FactIO/CsvRowEvaluator.{flatMap, return, getStringByIndex, getInt32ByIndex, optional};
        let* classType      = getStringByIndex(0);
        let* className      = getStringByIndex(1);
        let* charName       = getStringByIndex(2);
        let* low            = getInt32ByIndex(3);
        let* high           = getInt32ByIndex(4);
        return( EquiRefinesRange(classType, className, charName, low, high). )

    pub def loadEquiRefinesRange[r](path: String): Result[#{ EquiRefinesRange | r }, System.Error] & Impure = 
        use Result.flatMap;        
        let* src = newCsvStream(path, FactIO/CsvFormat.default().withFirstRecordAsHeader(), Text/Charset.utf_8());
        importRows(evalEquiRefinesRange(), src)



    type alias DbPaths = { pathOfFlocCharacteristic: String
                        , pathOfFlocRefinesChoice: String
                        , pathOfFlocRefinesRange: String
                        , pathOfEquiCharacteristic: String
                        , pathOfEquiRefinesChoice: String
                        , pathOfEquiRefinesRange: String
                        }

    pub def loadDb[r](paths: DbPaths): Result[#{ FlocCharacteristic, FlocRefinesChoice, FlocRefinesRange, EquiCharacteristic, EquiRefinesChoice, EquiRefinesRange | r }, System.Error] & Impure =
        use Result.flatMap;
        let* r1 = loadFlocCharacteristic(paths.pathOfFlocCharacteristic);
        let* r2 = loadFlocRefinesChoice(paths.pathOfFlocRefinesChoice);        
        let* r3 = loadFlocRefinesRange(paths.pathOfFlocRefinesRange);        
        let* r4 = loadEquiCharacteristic(paths.pathOfEquiCharacteristic);
        let* r5 = loadEquiRefinesChoice(paths.pathOfEquiRefinesChoice);
        let* r6 = loadEquiRefinesRange(paths.pathOfEquiRefinesRange);
        Ok(solve r1 <+> r2 <+> r3 <+> r4 <+> r5 <+> r6)

}