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

use FactIO.SQLiteRowEvaluator;
use FactIO/SQLiteImport.{newSQLiteStream, importRows};



use AssetLib/S4/FileIO/ClassList/Relations.Datatype;
use AssetLib/S4/FileIO/ClassList/Relations.Datatype.{Text, Date, IntNum, DecimalNum};
use AssetLib/S4/FileIO/ClassList/Relations.{ClassMember, Characteristic, SelectionValue, IntRange, DecimalRange};

namespace AssetLib/S4/FileIO/ClassList/SQLiteLoader {



    pub def loadCharacteristicsDb[r](path: System.FilePath): Result[#{ Characteristic, 
                                            SelectionValue, 
                                            IntRange, 
                                            DecimalRange, 
                                            ClassMember | r}, System.Error] & Impure =
        use Result.flatMap;
        let* r1     = loadCharacteristics(path);
        let* r2     = loadSelectionValues(path);
        let* r3     = loadIntRanges(path);
        let* r4     = loadDecimalRanges(path);
        let* r5     = loadClassMembers(path);
        Ok(solve r1 <+> r2 <+> r3 <+> r4 <+> r5)

    def getDatatypeByLabel(label: String): SQLiteRowEvaluator[Datatype] = 
        use FactIO/SQLiteRowEvaluator.{flatMap, return, getStringByLabel, throwError};
        let* str = getStringByLabel(label);
        match str { 
            case "Text"         => return(Text)
            case "Int"          => return(IntNum)
            case "Decimal"      => return(DecimalNum)
            case "Date"         => return(Date)
            case _              => throwError(System/Error.Generic("Unknown datatype: " + str))
        }


    /// ClassMember
    def loadClassMembers[r](path: System.FilePath): Result[#{ClassMember | r}, System.Error] & Impure = 
        use Result.flatMap;
        let query = "SELECT classname, charname FROM class_members";
        let* src = FactIO/SQLiteImport.newSQLiteStream(path, query);
        let* relns = FactIO/SQLiteImport.importRows(evalClassMember(), src);
        Ok(relns)

    def evalClassMember[r](): SQLiteRowEvaluator[#{ClassMember | r}] = 
        use FactIO/SQLiteRowEvaluator.{flatMap, return, getStringByLabel};
        let* className      = getStringByLabel("classname");
        let* charName       = getStringByLabel("charname");
        return( ClassMember(className, charName). )

    /// Characteristic
    def loadCharacteristics[r](path: System.FilePath): Result[#{Characteristic | r}, System.Error] & Impure = 
        use Result.flatMap;
        let query = "SELECT charname, datatype, num_chars, decimal_places FROM characteristics";
        let* src = FactIO/SQLiteImport.newSQLiteStream(path, query);
        let* relns = FactIO/SQLiteImport.importRows(evalCharacteristic(), src);
        Ok(relns)

    
    def evalCharacteristic[r](): SQLiteRowEvaluator[#{Characteristic | r}] = 
        use FactIO/SQLiteRowEvaluator.{flatMap, return, getStringByLabel, getInt32ByLabel, optional};
        let* charName       = getStringByLabel("charname");
        let* datatype       = getDatatypeByLabel("datatype");
        let* charLength     = getInt32ByLabel("num_chars");
        let* optPrecision   = optional(getInt32ByLabel("decimal_places"));
        return( Characteristic(charName, datatype, charLength, optPrecision). )

    /// SelectionValue
    def loadSelectionValues[r](path: System.FilePath): Result[#{SelectionValue | r}, System.Error] & Impure = 
        use Result.flatMap;
        let query = "SELECT charname, value FROM selection_values";
        let* src = FactIO/SQLiteImport.newSQLiteStream(path, query);
        let* relns = FactIO/SQLiteImport.importRows(evalSelectionValue(), src);
        Ok(relns)

    def evalSelectionValue[r](): SQLiteRowEvaluator[#{SelectionValue | r}] = 
        use FactIO/SQLiteRowEvaluator.{flatMap, return, getStringByLabel};
        let* charName       = getStringByLabel("charname");
        let* value          = getStringByLabel("value");
        return( SelectionValue(charName, value). )

    /// IntRange
    def loadIntRanges[r](path: System.FilePath): Result[#{IntRange | r}, System.Error] & Impure = 
        use Result.flatMap;
        let query = "SELECT charname, range_low, range_high FROM int_ranges";
        let* src = FactIO/SQLiteImport.newSQLiteStream(path, query);
        let* relns = FactIO/SQLiteImport.importRows(evalIntRange(), src);
        Ok(relns)

    def evalIntRange[r](): SQLiteRowEvaluator[#{IntRange | r}] = 
        use FactIO/SQLiteRowEvaluator.{flatMap, return, getStringByLabel, getInt32ByLabel};
        let* charName       = getStringByLabel("charname");
        let* low            = getInt32ByLabel("range_low");
        let* high           = getInt32ByLabel("range_high");
        return( IntRange(charName, low, high). )

    /// DecimalRange
    def loadDecimalRanges[r](path: System.FilePath): Result[#{DecimalRange | r}, System.Error] & Impure = 
        use Result.flatMap;
        let query = "SELECT charname, range_low, range_high FROM decimal_ranges";
        let* src = FactIO/SQLiteImport.newSQLiteStream(path, query);
        let* relns = FactIO/SQLiteImport.importRows(evalDecimalRange(), src);
        Ok(relns)

    def evalDecimalRange[r](): SQLiteRowEvaluator[#{DecimalRange | r}] = 
        use FactIO/SQLiteRowEvaluator.{flatMap, return, getStringByLabel, getFloat64ByLabel};
        let* charName       = getStringByLabel("charname");
        let* low            = getFloat64ByLabel("range_low");
        let* high           = getFloat64ByLabel("range_high");
        return( DecimalRange(charName, low, high). )
    

}