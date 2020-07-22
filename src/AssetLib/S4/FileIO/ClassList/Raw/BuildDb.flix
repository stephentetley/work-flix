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

use FactIO.SQLiteExport;
use FactIO.SQLiteWriteList;
use FactIO.SQLiteRowWriter;

namespace AssetLib/S4/FileIO/ClassList/Raw/BuildDb { 

    rel ClassMember(className: String, charName: String)
    rel Characteristic(charName: String, datatype: String, charLength: Int32, decimalPrec: Option[Int32])
    rel IntRange(charName: String, low: Int32, high: Int32)
    rel DecimalRange(charName: String, low: Float64, high: Float64)
    rel SelectionValue(charName: String, value: String)

    // Class Members

    pub def writeFlocClassMember[r](relns: #{ ClassMember | r}): SQLiteExport[Unit] =
        use FactIO/SQLiteExport.{flatMap, return, execute, emptySQLiteWriteList, execWriteList, commit};
        let* _          = execute("DROP TABLE IF EXISTS floc_class_members");
        let* _          = execute(sqlCreateFlocClassMembers());
        let stmt        = "INSERT INTO floc_class_members(classname, charname) VALUES(?,?)";
        let writes      = fold ClassMember emptySQLiteWriteList() writeClassMemberStep() relns;
        let* _          = execWriteList(stmt, writes);
        let* _          = commit();
        return()

    pub def writeEquiClassMember[r](relns: #{ ClassMember | r}): SQLiteExport[Unit] =
        use FactIO/SQLiteExport.{flatMap, return, execute, emptySQLiteWriteList, execWriteList, commit};
        let* _          = execute("DROP TABLE IF EXISTS equi_class_members");
        let* _          = execute(sqlCreateEquiClassMembers());
        let stmt        = "INSERT INTO equi_class_members(classname, charname) VALUES(?,?)";
        let writes      = fold ClassMember emptySQLiteWriteList() writeClassMemberStep() relns;
        let* _          = execWriteList(stmt, writes);
        let* _          = commit();
        return()


    def writeClassMemberStep(): ((String, String), SQLiteWriteList) -> SQLiteWriteList = 
        FactIO/SQLiteExport.makeSQLiteWriteStep(writeClassMemberRow)

    /// A RowWriter for the body of a ClassMember
    def writeClassMemberRow(src: (String, String)): SQLiteRowWriter[Unit] = 
        use FactIO/SQLiteRowWriter.{flatMap, return, putString!};
        let (classname, charname) = src;
        let* _ = putString!(0, classname);
        let* _ = putString!(1, charname);
        return()


    // Characteristics

    pub def writeFlocCharacteristics[r](relns: #{ Characteristic | r}): SQLiteExport[Unit] =
        use FactIO/SQLiteExport.{flatMap, return, execute, emptySQLiteWriteList, execWriteList, commit};
        let* _          = execute("DROP TABLE IF EXISTS floc_characteristics");
        let* _          = execute(sqlCreateFlocCharacteristics());
        let stmt        = "INSERT INTO floc_characteristics(charname, datatype, num_chars, decimal_places) VALUES(?,?,?,?)";
        let writes      = fold Characteristic emptySQLiteWriteList() writeCharacteristicStep() relns;
        let* _          = execWriteList(stmt, writes);
        let* _          = commit();
        return()

    pub def writeEquiCharacteristic[r](relns: #{ Characteristic | r}): SQLiteExport[Unit] =
        use FactIO/SQLiteExport.{flatMap, return, execute, emptySQLiteWriteList, execWriteList, commit};
        let* _          = execute("DROP TABLE IF EXISTS equi_characteristics");
        let* _          = execute(sqlCreateEquiCharacteristics());
        let stmt        = "INSERT INTO equi_characteristics(charname, datatype, num_chars, decimal_places) VALUES(?,?,?,?)";
        let writes      = fold Characteristic emptySQLiteWriteList() writeCharacteristicStep() relns;
        let* _          = execWriteList(stmt, writes);
        let* _          = commit();
        return()


    def writeCharacteristicStep(): ((String, String, Int32, Option[Int32]), SQLiteWriteList) -> SQLiteWriteList = 
        FactIO/SQLiteExport.makeSQLiteWriteStep(writeCharacteristicRow)

    /// A RowWriter for the body of a Characteristic
    def writeCharacteristicRow(src: (String, String, Int32, Option[Int32])): SQLiteRowWriter[Unit] = 
        use FactIO/SQLiteRowWriter.{flatMap, return, putString!, putInt32!, putOptionInt32!};
        let (charname, datatype, numChars, decimalPlaces) = src;
        let* _ = putString!(0, charname);
        let* _ = putString!(1, datatype);
        let* _ = putInt32!(2, numChars);
        let* _ = putOptionInt32!(3, decimalPlaces);
        return()

    // Int Ranges

    pub def writeFlocIntRanges[r](relns: #{ IntRange | r}): SQLiteExport[Unit] =
        use FactIO/SQLiteExport.{flatMap, return, execute, emptySQLiteWriteList, execWriteList, commit};
        let* _          = execute("DROP TABLE IF EXISTS floc_int_ranges");
        let* _          = execute(sqlCreateFlocIntRanges());
        let stmt        = "INSERT INTO floc_int_ranges(charname, range_high, range_low) VALUES(?,?,?)";
        let writes      = fold IntRange emptySQLiteWriteList() writeIntRangeStep() relns;
        let* _          = execWriteList(stmt, writes);
        let* _          = commit();
        return()

    pub def writeEquiIntRanges[r](relns: #{ IntRange | r}): SQLiteExport[Unit] =
        use FactIO/SQLiteExport.{flatMap, return, execute, emptySQLiteWriteList, execWriteList, commit};
        let* _          = execute("DROP TABLE IF EXISTS equi_int_ranges");
        let* _          = execute(sqlCreateEquiIntRanges());
        let stmt        = "INSERT INTO equi_int_ranges(charname, range_high, range_low) VALUES(?,?,?)";
        let writes      = fold IntRange emptySQLiteWriteList() writeIntRangeStep() relns;
        let* _          = execWriteList(stmt, writes);
        let* _          = commit();
        return()

    def writeIntRangeStep(): ((String, Int32, Int32), SQLiteWriteList) -> SQLiteWriteList = 
        FactIO/SQLiteExport.makeSQLiteWriteStep(writeIntRangeRow)

    /// A RowWriter for the body of IntRange
    def writeIntRangeRow(src: (String, Int32, Int32)): SQLiteRowWriter[Unit] = 
        use FactIO/SQLiteRowWriter.{flatMap, return, putString!, putInt32!};
        let (charname, low, high) = src;
        let* _ = putString!(0, charname);
        let* _ = putInt32!(1, low);
        let* _ = putInt32!(2, high);
        return()


    // Decimal Ranges

    pub def writeFlocDecimalRanges[r](relns: #{ DecimalRange | r}): SQLiteExport[Unit] =
        use FactIO/SQLiteExport.{flatMap, return, execute, emptySQLiteWriteList, execWriteList, commit};
        let* _          = execute("DROP TABLE IF EXISTS floc_decimal_ranges");
        let* _          = execute(sqlCreateFlocDecimalRanges());
        let stmt        = "INSERT INTO floc_decimal_ranges(charname, range_high, range_low) VALUES(?,?,?)";
        let writes      = fold DecimalRange emptySQLiteWriteList() writeDecimalRangeStep() relns;
        let* _          = execWriteList(stmt, writes);
        let* _          = commit();
        return()

    pub def writeEquiDecimalRanges[r](relns: #{ DecimalRange | r}): SQLiteExport[Unit] =
        use FactIO/SQLiteExport.{flatMap, return, execute, emptySQLiteWriteList, execWriteList, commit};
        let* _          = execute("DROP TABLE IF EXISTS equi_decimal_ranges");
        let* _          = execute(sqlCreateEquiDecimalRanges());
        let stmt        = "INSERT INTO equi_decimal_ranges(charname, range_high, range_low) VALUES(?,?,?)";
        let writes      = fold DecimalRange emptySQLiteWriteList() writeDecimalRangeStep() relns;
        let* _          = execWriteList(stmt, writes);
        let* _          = commit();
        return()

    def writeDecimalRangeStep(): ((String, Float64, Float64), SQLiteWriteList) -> SQLiteWriteList = 
        FactIO/SQLiteExport.makeSQLiteWriteStep(writeDecimalRangeRow)

    /// A RowWriter for the body of DecimalRange
    def writeDecimalRangeRow(src: (String, Float64, Float64)): SQLiteRowWriter[Unit] = 
        use FactIO/SQLiteRowWriter.{flatMap, return, putString!, putFloat64!};
        let (charname, low, high) = src;
        let* _ = putString!(0, charname);
        let* _ = putFloat64!(1, low);
        let* _ = putFloat64!(2, high);
        return()

    // Selection Values

    pub def writeFlocSelectionValues[r](relns: #{ SelectionValue | r}): SQLiteExport[Unit] =
        use FactIO/SQLiteExport.{flatMap, return, execute, emptySQLiteWriteList, execWriteList, commit};
        let* _          = execute("DROP TABLE IF EXISTS floc_selection_values");
        let* _          = execute(sqlCreateFlocSelectionValues());
        let stmt        = "INSERT INTO floc_selection_values(charname, value) VALUES(?,?)";
        let writes      = fold SelectionValue emptySQLiteWriteList() writeSelectionValueStep() relns;
        let* _          = execWriteList(stmt, writes);
        let* _          = commit();
        return()

    pub def writeEquiSelectionValues[r](relns: #{ SelectionValue | r}): SQLiteExport[Unit] =
        use FactIO/SQLiteExport.{flatMap, return, execute, emptySQLiteWriteList, execWriteList, commit};
        let* _          = execute("DROP TABLE IF EXISTS equi_selection_values");
        let* _          = execute(sqlCreateEquiSelectionValues());
        let stmt        = "INSERT INTO equi_selection_values(charname, value) VALUES(?,?)";
        let writes      = fold SelectionValue emptySQLiteWriteList() writeSelectionValueStep() relns;
        let* _          = execWriteList(stmt, writes);
        let* _          = commit();
        return()

    def writeSelectionValueStep(): ((String, String), SQLiteWriteList) -> SQLiteWriteList = 
        FactIO/SQLiteExport.makeSQLiteWriteStep(writeSelectionValueRow)

    /// A RowWriter for the body of DecimalRange
    def writeSelectionValueRow(src: (String, String)): SQLiteRowWriter[Unit] = 
        use FactIO/SQLiteRowWriter.{flatMap, return, putString!};
        let (charname, value) = src;
        let* _ = putString!(0, charname);
        let* _ = putString!(1, value);
        return()



    // SQL DDL

    def sqlCreateFlocClassMembers(): String =
        String.unwords(
            "CREATE TABLE floc_class_members ("
                :: "classname       TEXT NOT NULL,"
                :: "charname        TEXT NOT NULL"
                :: ")"
                :: Nil
        )

    def sqlCreateEquiClassMembers(): String =
        String.unwords(
            "CREATE TABLE equi_class_members ("
                :: "classname       TEXT NOT NULL,"
                :: "charname        TEXT NOT NULL"
                :: ")"
                :: Nil
        )


    def sqlCreateFlocCharacteristics(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS floc_characteristics ("
                :: "charname       TEXT    PRIMARY KEY NOT NULL UNIQUE,"
                :: "datatype       TEXT    NOT NULL,"
                :: "num_chars      INTEGER NOT NULL,"
                :: "decimal_places INTEGER NOT NULL"
                :: ")"
                :: Nil
        )

    def _sqlCreateFlocClassMembers(): String =
        String.unwords(
            "CREATE TABLE floc_class_members ("
                :: "class          TEXT NOT NULL,"
                :: "characteristic TEXT NOT NULL"
                :: ");"
                :: Nil
        )

    def sqlCreateFlocIntRanges(): String =
        String.unwords(
            "CREATE TABLE floc_int_ranges ("
                :: "charname   TEXT    NOT NULL,"
                :: "range_low  INTEGER NOT NULL,"
                :: "range_high INTEGER NOT NULL"
                :: ")"
                :: Nil
        )

    def sqlCreateFlocDecimalRanges(): String =
        String.unwords(
            "CREATE TABLE floc_decimal_ranges ("
                :: "charname   TEXT    NOT NULL,"
                :: "range_low  DECIMAL NOT NULL,"
                :: "range_high DECIMAL NOT NULL"
                :: ")"
                :: Nil
        )

    def sqlCreateFlocSelectionValues(): String =
        String.unwords(
            "CREATE TABLE floc_selection_values ("
                :: "charname TEXT NOT NULL,"
                :: "value    TEXT NOT NULL"
                :: ")"
                :: Nil
        )
    
    def sqlCreateEquiCharacteristics(): String =
        String.unwords(
            "CREATE TABLE equi_characteristics ("
                :: "charname       TEXT    PRIMARY KEY NOT NULL UNIQUE,"
                :: "datatype       TEXT    NOT NULL,"
                :: "num_chars      INTEGER NOT NULL,"
                :: "decimal_places INTEGER NOT NULL"
                :: ")"
                :: Nil
        )

    def _sqlCreateEquiClassMembers(): String =
        String.unwords(
            "CREATE TABLE equi_class_members ("
                :: "class          TEXT NOT NULL,"
                :: "characteristic TEXT NOT NULL"
                :: ");"
                :: Nil
        )

    def sqlCreateEquiIntRanges(): String =
        String.unwords(
            "CREATE TABLE equi_int_ranges ("
                :: "charname   TEXT    NOT NULL,"
                :: "range_low  INTEGER NOT NULL,"
                :: "range_high INTEGER NOT NULL"
                :: ")"
                :: Nil
        )

    def sqlCreateEquiDecimalRanges(): String =
        String.unwords(
            "CREATE TABLE equi_decimal_ranges ("
                :: "charname   TEXT    NOT NULL,"
                :: "range_low  DECIMAL NOT NULL,"
                :: "range_high DECIMAL NOT NULL"
                :: ")"
                :: Nil
        )


    def sqlCreateEquiSelectionValues(): String =
        String.unwords(
            "CREATE TABLE equi_selection_values ("
                :: "charname TEXT NOT NULL,"
                :: "value    TEXT NOT NULL"
                :: ")"
                :: Nil
        )
} 