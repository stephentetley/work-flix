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

use AssetLib/Common/Utils.{foldMapRel};
use AssetLib/S4/FileIO/ClassList/Raw/Datatypes.{ClassList, Class, Characteristic, Datatype, Refinement};
use AssetLib/S4/FileIO/ClassList/Raw/Datatypes.Datatype.{Text, Date, NumInt, NumDecimal};
use AssetLib/S4/FileIO/ClassList/Raw/Datatypes.Refinement.{ListOfValues, IntRange, DecimalRange};
use AssetLib/S4/FileIO/ClassList/Raw/Parser.{parseFile};
use AssetLib/S4/FileIO/ClassList/Raw/Builder.{buildClassList};


namespace AssetLib/S4/FileIO/ClassList/Raw/ExportDb { 

    // These are transitory relations, so the _Rel suffix is not a burden
    
    rel ClassMemberRel(className: String, charName: String)
    rel CharacteristicRel(charName: String, datatype: String, charLength: Int32, decimalPrec: Option[Int32])
    rel IntRangeRel(charName: String, low: Int32, high: Int32)
    rel DecimalRangeRel(charName: String, low: Float64, high: Float64)
    rel SelectionValueRel(charName: String, value: String)

    pub def parseFlocClassList(path: System.FilePath, cs: Text.Charset): Result[ClassList, System.Error] & Impure = 
        use Result.{flatMap};
        use AssetLib/S4/FileIO/ClassList/Raw/Datatypes.SourceType.{FlocClasses};
        let* ast    = parseFile(path, FlocClasses, cs);
        let ans     = buildClassList(ast);
        Ok(ans)

    pub def parseEquiClassList(path: System.FilePath, cs: Text.Charset): Result[ClassList, System.Error]  & Impure = 
        use Result.{flatMap};
        use AssetLib/S4/FileIO/ClassList/Raw/Datatypes.SourceType.{EquiClasses};
        let* ast    = parseFile(path, EquiClasses, cs);
        let ans     = buildClassList(ast);
        Ok(ans)

    pub def outputDb(src: ClassList, outpath: System.FilePath): Result[Unit, System.Error] & Impure =         
        use FactIO/SQLiteExport.{runSQLiteExport};
        runSQLiteExport(writeOutput(src), outpath)
        
    def writeOutput(src: ClassList): SQLiteExport[Unit] =
        use FactIO/SQLiteExport.{flatMap, return, setAutoCommit, close, liftAction};
        let* _      = setAutoCommit(false);
        let* _      = liftAction(_ -> { Console.printLine("ClassMembers"); Ok() });
        let* _      = collectClassMembers(src) |> writeClassMembers;
        let* _      = liftAction(_ -> { Console.printLine("Characteristics"); Ok() });
        let* _      = collectCharacteristics(src) |> writeCharacteristics;
        let* _      = liftAction(_ -> { Console.printLine("IntRanges"); Ok() });
        let* _      = collectIntRanges(src) |> writeIntRanges;
        let* _      = liftAction(_ -> { Console.printLine("DecimalRanges"); Ok() });
        let* _      = collectDecimalRanges(src) |> writeDecimalRanges;
        let* _      = liftAction(_ -> { Console.printLine("SelectionValues"); Ok() });
        let* _      = collectSelectionValues(src) |> writeSelectionValues;
        let* _      = close();
        return()


    // Traversals

    // Collect ClassMembers
    // Call solve to remove duplicates
    def collectClassMembers[r](src: ClassList):  #{ClassMemberRel | r} = 
        foldMapRel(classMember1, src.classes)

    // One-to-many
    def classMember1[r](src: Class):  #{ClassMemberRel | r} =
        let className = src.name;
        foldMapRel(r ->  { let name = r.name; ClassMemberRel(className, name). }, src.characteristics)


    // Collect Characteristics
    // Call solve to remove duplicates
    def collectCharacteristics[r](src: ClassList):  #{CharacteristicRel | r} = 
        solve foldMapRel(characteristics, src.classes)

    // One-to-many
    def characteristics[r](src: Class):  #{CharacteristicRel | r} =
        foldMapRel(characteristic1, src.characteristics)

    // One-to-one
    def characteristic1[r](src: Characteristic):  #{CharacteristicRel | r} =
        let name = src.name;
        let (typename, clength, prec) = deconsDatatype(src.datatype);
        CharacteristicRel(name, typename, clength, prec). 
        

    def deconsDatatype(x: Datatype): (String, Int32, Option[Int32]) = match x { 
        case Text(d) => ("Text", d, None)
        case Date(d) => ("Date", d, None)
        case NumInt(d) => ("Int", d, None)
        case NumDecimal(d, p) => ("Decimal", d, Some(p)) 
    }
        

    // Collect Int Ranges
    // Call solve to remove duplicates
    def collectIntRanges[r](src: ClassList):  #{IntRangeRel | r} = 
        solve foldMapRel(intRanges, src.classes)

    // One-to-many
    def intRanges[r](src: Class):  #{IntRangeRel | r} =
        foldMapRel(intRange1, src.characteristics)

    // One-to-zero-or-one
    def intRange1[r](src: Characteristic):  #{IntRangeRel | r} =
        let name = src.name;
        match src.refinement {
            case Some(IntRange(lo,hi)) => IntRangeRel(name, lo, hi).
            case _ => #{}
        } 
    
    // Collect Decimal Ranges
    // Call solve to remove duplicates
    def collectDecimalRanges[r](src: ClassList):  #{DecimalRangeRel | r} = 
        solve foldMapRel(decimalRanges, src.classes)

    // One-to-many
    def decimalRanges[r](src: Class):  #{DecimalRangeRel | r} =
        foldMapRel(decimalRange1, src.characteristics)

    // One-to-zero-or-one
    def decimalRange1[r](src: Characteristic):  #{DecimalRangeRel | r} =
        let name = src.name;
        match src.refinement {
            case Some(DecimalRange(lo,hi)) => DecimalRangeRel(name, lo, hi).
            case _ => #{}
        } 

    // Collect Selection Values
    // Call solve to remove duplicates
    def collectSelectionValues[r](src: ClassList):  #{SelectionValueRel | r} = 
        solve AssetLib/Common/Utils.foldMapRel(selectionValues, src.classes)

    // One-to-many
    def selectionValues[r](src: Class):  #{SelectionValueRel | r} =
        AssetLib/Common/Utils.foldMapRel(selectionValue1, src.characteristics)

    // One-to-zero-or-one
    def selectionValue1[r](src: Characteristic):  #{SelectionValueRel | r} =        
        let name = src.name;
        match src.refinement {
            case Some(ListOfValues(xs)) => foldMapRel(r -> SelectionValueRel(name, r). , xs)
            case _ => #{}
        } 


    // Class Members

    def writeClassMembers[r](relns: #{ClassMemberRel | r}): SQLiteExport[Unit] =
        use FactIO/SQLiteExport.{flatMap, return, execute, emptySQLiteWriteList, execWriteList, commit};
        let* _          = execute("DROP TABLE IF EXISTS class_members");
        let* _          = execute(sqlCreateClassMembers());
        let stmt        = "INSERT INTO class_members(classname, charname) VALUES(?,?)";
        let writes      = fold ClassMemberRel emptySQLiteWriteList() writeClassMemberStep() relns;
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

    def writeCharacteristics[r](relns: #{CharacteristicRel | r}): SQLiteExport[Unit] =
        use FactIO/SQLiteExport.{flatMap, return, execute, emptySQLiteWriteList, execWriteList, commit};
        let* _          = execute("DROP TABLE IF EXISTS characteristics");
        let* _          = execute(sqlCreateCharacteristics());
        let stmt        = "INSERT INTO characteristics(charname, datatype, num_chars, decimal_places) VALUES(?,?,?,?)";
        let writes      = fold CharacteristicRel emptySQLiteWriteList() writeCharacteristicStep() relns;
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

    def writeIntRanges[r](relns: #{IntRangeRel | r}): SQLiteExport[Unit] =
        use FactIO/SQLiteExport.{flatMap, return, execute, emptySQLiteWriteList, execWriteList, commit};
        let* _          = execute("DROP TABLE IF EXISTS int_ranges");
        let* _          = execute(sqlCreateIntRanges());
        let stmt        = "INSERT INTO int_ranges(charname, range_low, range_high) VALUES(?,?,?)";
        let writes      = fold IntRangeRel emptySQLiteWriteList() writeIntRangeStep() relns;
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

    def writeDecimalRanges[r](relns: #{DecimalRangeRel | r}): SQLiteExport[Unit] =
        use FactIO/SQLiteExport.{flatMap, return, execute, emptySQLiteWriteList, execWriteList, commit};
        let* _          = execute("DROP TABLE IF EXISTS decimal_ranges");
        let* _          = execute(sqlCreateDecimalRanges());
        let stmt        = "INSERT INTO decimal_ranges(charname, range_low, range_high) VALUES(?,?,?)";
        let writes      = fold DecimalRangeRel emptySQLiteWriteList() writeDecimalRangeStep() relns;
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

    def writeSelectionValues[r](relns: #{SelectionValueRel | r}): SQLiteExport[Unit] =
        use FactIO/SQLiteExport.{flatMap, return, execute, emptySQLiteWriteList, execWriteList, commit};
        let* _          = execute("DROP TABLE IF EXISTS selection_values");
        let* _          = execute(sqlCreateSelectionValues());
        let stmt        = "INSERT INTO selection_values(charname, value) VALUES(?,?)";
        let writes      = fold SelectionValueRel emptySQLiteWriteList() writeSelectionValueStep() relns;
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

    def sqlCreateClassMembers(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS class_members ("
                :: "classname       TEXT NOT NULL,"
                :: "charname        TEXT NOT NULL"
                :: ")"
                :: Nil
        )

    def sqlCreateCharacteristics(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS characteristics ("
                :: "charname       TEXT    PRIMARY KEY NOT NULL UNIQUE,"
                :: "datatype       TEXT    NOT NULL,"
                :: "num_chars      INTEGER NOT NULL,"
                :: "decimal_places INTEGER"
                :: ")"
                :: Nil
        )


    def sqlCreateIntRanges(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS int_ranges ("
                :: "charname   TEXT    NOT NULL,"
                :: "range_low  INTEGER NOT NULL,"
                :: "range_high INTEGER NOT NULL"
                :: ")"
                :: Nil
        )

    def sqlCreateDecimalRanges(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS decimal_ranges ("
                :: "charname   TEXT    NOT NULL,"
                :: "range_low  DECIMAL NOT NULL,"
                :: "range_high DECIMAL NOT NULL"
                :: ")"
                :: Nil
        )

    def sqlCreateSelectionValues(): String =
        String.unwords(
            "CREATE TABLE selection_values ("
                :: "charname TEXT NOT NULL,"
                :: "value    TEXT NOT NULL"
                :: ")"
                :: Nil
        )
} 