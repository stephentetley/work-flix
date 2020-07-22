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
use AssetLib/S4/FileIO/ClassList/Relations.{FlocCharacteristic, FlocSelectionValue, 
                            FlocIntRange, FlocDecimalRange,
                            EquiCharacteristic, EquiSelectionValue, 
                            EquiIntRange, EquiDecimalRange, 
                            FlocClassMember, EquiClassMember};

namespace AssetLib/S4/FileIO/ClassList/SQLiteLoader {



    pub def loadDb[r](path: System.FilePath): Result[#{ FlocCharacteristic, EquiCharacteristic,
                                                        FlocSelectionValue, EquiSelectionValue,
                                                        FlocIntRange, EquiIntRange,
                                                        FlocDecimalRange, EquiDecimalRange, 
                                                        FlocClassMember, EquiClassMember | r}, System.Error] & Impure =
        use Result.flatMap;
        let* r1     = loadFlocCharacteristics(path);
        let* r2     = loadEquiCharacteristics(path);
        let* r3     = loadFlocSelectionValues(path);
        let* r4     = loadEquiSelectionValues(path);
        let* r5     = loadFlocIntRanges(path);
        let* r6     = loadEquiIntRanges(path);
        let* r7     = loadFlocDecimalRanges(path);
        let* r8     = loadEquiDecimalRanges(path);
        let* r9     = loadFlocClassMembers(path);
        let* r10    = loadEquiClassMembers(path);
        Ok(solve r1 <+> r2 <+> r3 <+> r4 <+> r5 <+> r6 <+> r7 <+> r8 <+> r9 <+> r10)

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


    /// FlocClassMember
    def loadFlocClassMembers[r](path: System.FilePath): Result[#{FlocClassMember | r}, System.Error] & Impure = 
        use Result.flatMap;
        use System/FilePath.{toString};
        let query = "SELECT classname, charname FROM floc_class_members";
        let* src = FactIO/SQLiteImport.newSQLiteStream(path.toString(), query);
        let* relns = FactIO/SQLiteImport.importRows(evalFlocClassMember(), src);
        Ok(relns)

    def evalFlocClassMember[r](): SQLiteRowEvaluator[#{FlocClassMember | r}] = 
        use FactIO/SQLiteRowEvaluator.{flatMap, return, getStringByLabel};
        let* className      = getStringByLabel("classname");
        let* charName       = getStringByLabel("charname");
        return( FlocClassMember(className, charName). )

    /// EquiClassMember
    def loadEquiClassMembers[r](path: System.FilePath): Result[#{EquiClassMember | r}, System.Error] & Impure = 
        use Result.flatMap;
        use System/FilePath.{toString};
        let query = "SELECT classname, charname FROM equi_class_members";
        let* src = FactIO/SQLiteImport.newSQLiteStream(path.toString(), query);
        let* relns = FactIO/SQLiteImport.importRows(evalEquiClassMember(), src);
        Ok(relns)

    def evalEquiClassMember[r](): SQLiteRowEvaluator[#{EquiClassMember | r}] = 
        use FactIO/SQLiteRowEvaluator.{flatMap, return, getStringByLabel};
        let* className      = getStringByLabel("classname");
        let* charName       = getStringByLabel("charname");
        return( EquiClassMember(className, charName). )


    /// FlocCharacteristic
    def loadFlocCharacteristics[r](path: System.FilePath): Result[#{FlocCharacteristic | r}, System.Error] & Impure = 
        use Result.flatMap;
        use System/FilePath.{toString};
        let query = "SELECT charname, datatype, num_chars, decimal_places FROM floc_characteristics";
        let* src = FactIO/SQLiteImport.newSQLiteStream(path.toString(), query);
        let* relns = FactIO/SQLiteImport.importRows(evalFlocCharacteristic(), src);
        Ok(relns)

    
    def evalFlocCharacteristic[r](): SQLiteRowEvaluator[#{FlocCharacteristic | r}] = 
        use FactIO/SQLiteRowEvaluator.{flatMap, return, getStringByLabel, getInt32ByLabel, optional};
        let* charName       = getStringByLabel("charname");
        let* datatype       = getDatatypeByLabel("datatype");
        let* charLength     = getInt32ByLabel("num_chars");
        let* optPrecision   = optional(getInt32ByLabel("decimal_places"));
        return( FlocCharacteristic(charName, datatype, charLength, optPrecision). )

    /// EquiCharacteristic
    def loadEquiCharacteristics[r](path: System.FilePath): Result[#{EquiCharacteristic | r}, System.Error] & Impure = 
        use Result.flatMap;
        use System/FilePath.{toString};
        let query = "SELECT charname, datatype, num_chars, decimal_places FROM equi_characteristics";
        let* src = FactIO/SQLiteImport.newSQLiteStream(path.toString(), query);
        let* relns = FactIO/SQLiteImport.importRows(evalEquiCharacteristic(), src);
        Ok(relns)

    
    def evalEquiCharacteristic[r](): SQLiteRowEvaluator[#{EquiCharacteristic | r}] = 
        use FactIO/SQLiteRowEvaluator.{flatMap, return, getStringByLabel, getInt32ByLabel, optional};
        let* charName       = getStringByLabel("charname");
        let* datatype       = getDatatypeByLabel("datatype");
        let* charLength     = getInt32ByLabel("num_chars");
        let* optPrecision   = optional(getInt32ByLabel("decimal_places"));
        return( EquiCharacteristic(charName, datatype, charLength, optPrecision). )


    /// FlocSelectionValue
    def loadFlocSelectionValues[r](path: System.FilePath): Result[#{FlocSelectionValue | r}, System.Error] & Impure = 
        use Result.flatMap;
        use System/FilePath.{toString};
        let query = "SELECT charname, value FROM floc_selection_values";
        let* src = FactIO/SQLiteImport.newSQLiteStream(path.toString(), query);
        let* relns = FactIO/SQLiteImport.importRows(evalFlocSelectionValue(), src);
        Ok(relns)

    def evalFlocSelectionValue[r](): SQLiteRowEvaluator[#{FlocSelectionValue | r}] = 
        use FactIO/SQLiteRowEvaluator.{flatMap, return, getStringByLabel};
        let* charName       = getStringByLabel("charname");
        let* value          = getStringByLabel("value");
        return( FlocSelectionValue(charName, value). )

    /// EquiSelectionValue
    def loadEquiSelectionValues[r](path: System.FilePath): Result[#{EquiSelectionValue | r}, System.Error] & Impure = 
        use Result.flatMap;
        use System/FilePath.{toString};
        let query = "SELECT charname, value FROM equi_selection_values";
        let* src = FactIO/SQLiteImport.newSQLiteStream(path.toString(), query);
        let* relns = FactIO/SQLiteImport.importRows(evalEquiSelectionValue(), src);
        Ok(relns)

    def evalEquiSelectionValue[r](): SQLiteRowEvaluator[#{EquiSelectionValue | r}] = 
        use FactIO/SQLiteRowEvaluator.{flatMap, return, getStringByLabel};
        let* charName       = getStringByLabel("charname");
        let* value          = getStringByLabel("value");
        return( EquiSelectionValue(charName, value). )


    /// FlocIntRange
    def loadFlocIntRanges[r](path: System.FilePath): Result[#{FlocIntRange | r}, System.Error] & Impure = 
        use Result.flatMap;
        use System/FilePath.{toString};
        let query = "SELECT charname, range_low, range_high FROM floc_int_ranges";
        let* src = FactIO/SQLiteImport.newSQLiteStream(path.toString(), query);
        let* relns = FactIO/SQLiteImport.importRows(evalFlocIntRange(), src);
        Ok(relns)

    def evalFlocIntRange[r](): SQLiteRowEvaluator[#{FlocIntRange | r}] = 
        use FactIO/SQLiteRowEvaluator.{flatMap, return, getStringByLabel, getInt32ByLabel};
        let* charName       = getStringByLabel("charname");
        let* low            = getInt32ByLabel("range_low");
        let* high           = getInt32ByLabel("range_high");
        return( FlocIntRange(charName, low, high). )

    /// EquiIntRange
    def loadEquiIntRanges[r](path: System.FilePath): Result[#{EquiIntRange | r}, System.Error] & Impure = 
        use Result.flatMap;
        use System/FilePath.{toString};
        let query = "SELECT charname, range_low, range_high FROM equi_int_ranges";
        let* src = FactIO/SQLiteImport.newSQLiteStream(path.toString(), query);
        let* relns = FactIO/SQLiteImport.importRows(evalEquiIntRange(), src);
        Ok(relns)

    def evalEquiIntRange[r](): SQLiteRowEvaluator[#{EquiIntRange | r}] = 
        use FactIO/SQLiteRowEvaluator.{flatMap, return, getStringByLabel, getInt32ByLabel};
        let* charName       = getStringByLabel("charname");
        let* low            = getInt32ByLabel("range_low");
        let* high           = getInt32ByLabel("range_high");
        return( EquiIntRange(charName, low, high). )

    /// FlocDecimalRange
    def loadFlocDecimalRanges[r](path: System.FilePath): Result[#{FlocDecimalRange | r}, System.Error] & Impure = 
        use Result.flatMap;
        use System/FilePath.{toString};
        let query = "SELECT charname, range_low, range_high FROM floc_decimal_ranges";
        let* src = FactIO/SQLiteImport.newSQLiteStream(path.toString(), query);
        let* relns = FactIO/SQLiteImport.importRows(evalFlocDecimalRange(), src);
        Ok(relns)

    def evalFlocDecimalRange[r](): SQLiteRowEvaluator[#{FlocDecimalRange | r}] = 
        use FactIO/SQLiteRowEvaluator.{flatMap, return, getStringByLabel, getFloat64ByLabel};
        let* charName       = getStringByLabel("charname");
        let* low            = getFloat64ByLabel("range_low");
        let* high           = getFloat64ByLabel("range_high");
        return( FlocDecimalRange(charName, low, high). )
    
    /// EquiDecimalRange
    def loadEquiDecimalRanges[r](path: System.FilePath): Result[#{EquiDecimalRange | r}, System.Error] & Impure = 
        use Result.flatMap;
        use System/FilePath.{toString};
        let query = "SELECT charname, range_low, range_high FROM equi_decimal_ranges";
        let* src = FactIO/SQLiteImport.newSQLiteStream(path.toString(), query);
        let* relns = FactIO/SQLiteImport.importRows(evalEquiDecimalRange(), src);
        Ok(relns)

    def evalEquiDecimalRange[r](): SQLiteRowEvaluator[#{EquiDecimalRange | r}] = 
        use FactIO/SQLiteRowEvaluator.{flatMap, return, getStringByLabel, getFloat64ByLabel};
        let* charName       = getStringByLabel("charname");
        let* low            = getFloat64ByLabel("range_low");
        let* high           = getFloat64ByLabel("range_high");
        return( EquiDecimalRange(charName, low, high). )
}