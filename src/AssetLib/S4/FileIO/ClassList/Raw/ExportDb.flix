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

use FactIO.JdbcExport;
use FactIO.JdbcWriteList;
use FactIO.JdbcRowSetter;

use AssetLib/Common/Utils.{foldMapRel};
use AssetLib/S4/FileIO/ClassList/Raw/Datatypes.{ClassList, Class, Characteristic, Datatype, Refinement};
use AssetLib/S4/FileIO/ClassList/Raw/Datatypes.Datatype.{Text, Date, NumInt, NumDecimal};
use AssetLib/S4/FileIO/ClassList/Raw/Datatypes.Refinement.{ListOfValues, IntRange, DecimalRange};
use AssetLib/S4/FileIO/ClassList/Raw/Parser.{parseFile};
use AssetLib/S4/FileIO/ClassList/Raw/Builder.{buildClassList};



namespace AssetLib/S4/FileIO/ClassList/Raw/ExportDb { 

    // These are transitory relations, so the _Rel suffix is not a burden
    
    type alias ClassMember1 = {className: String, charName: String}
    
    type alias Characteristic1 = {charName: String, datatype: String, charLength: Int32, decimalPrec: Option[Int32]}
    
    type alias IntRange1 = {charName: String, low: Int32, high: Int32}
    
    type alias DecimalRange1 = {charName: String, low: Float64, high: Float64}

    type alias SelectionValue1 = {charName: String, value: String}

    pub def parseFlocClassList(path: System.FilePath, cs: Text.Charset): JdbcExport[ClassList] = 
        use FactIO/JdbcExport.{flatMap, return, liftActionResult};
        use AssetLib/S4/FileIO/ClassList/Raw/Datatypes.SourceType.{FlocClasses};
        let* ast    = liftActionResult(_ -> parseFile(path, FlocClasses, cs));
        let ans     = buildClassList(ast);
        return(ans)

    pub def parseEquiClassList(path: System.FilePath, cs: Text.Charset): JdbcExport[ClassList] = 
        use FactIO/JdbcExport.{flatMap, return, liftActionResult};
        use AssetLib/S4/FileIO/ClassList/Raw/Datatypes.SourceType.{EquiClasses};
        let* ast    = liftActionResult(_ -> parseFile(path, EquiClasses, cs));
        let ans     = buildClassList(ast);
        return(ans)
        
    pub def outputTables(prefix: String, src: ClassList): JdbcExport[Unit] =
        use FactIO/JdbcExport.{flatMap, return, setAutoCommitOff, close, liftAction};
        let* _      = setAutoCommitOff();
        let* _      = liftAction(_ -> Console.printLine("ClassMembers"));
        let* _      = collectClassMembers(src) |> writeClassMembers(prefix);
        let* _      = liftAction(_ -> Console.printLine("Characteristics"));
        let* _      = collectCharacteristics(src) |> writeCharacteristics(prefix);
        let* _      = liftAction(_ -> Console.printLine("IntRanges"));
        let* _      = collectIntRanges(src) |> writeIntRanges(prefix);
        let* _      = liftAction(_ -> Console.printLine("DecimalRanges"));
        let* _      = collectDecimalRanges(src) |> writeDecimalRanges(prefix);
        let* _      = liftAction(_ -> Console.printLine("SelectionValues"));
        let* _      = collectSelectionValues(src) |> writeSelectionValues(prefix);        
        return()


    // Traversals

    // Collect ClassMembers
    // Call solve to remove duplicates
    def collectClassMembers(src: ClassList): List[ClassMember1] =
        let cmp = (x,y) -> x.className == y.className && x.charName == y.charName;
        List.flatMap(classMember1, src.classes) |> List.distinctWith(cmp)

    // One-to-many
    def classMember1(src: Class): List[ClassMember1] =
        List.map(r ->  {className = src.name, charName = r.name}, src.characteristics)
        

    // Collect Characteristics
    // Call solve to remove duplicates
    def collectCharacteristics(src: ClassList): List[Characteristic1] = 
        let cmp = (x,y) -> x.charName == y.charName && x.datatype == y.datatype;
        List.flatMap(characteristics, src.classes) |> List.distinctWith(cmp)

    // One-to-many
    def characteristics(src: Class): List[Characteristic1] =
        List.map(characteristic1, src.characteristics)

    // One-to-one
    def characteristic1(src: Characteristic):  Characteristic1 =
        let (typename, clength, prec) = deconsDatatype(src.datatype);
        {charName = src.name, datatype = typename, charLength = clength, decimalPrec = prec} 
        
        
    def deconsDatatype(x: Datatype): (String, Int32, Option[Int32]) = match x { 
        case Text(d) => ("Text", d, None)
        case Date(d) => ("Date", d, None)
        case NumInt(d) => ("Int", d, None)
        case NumDecimal(d, p) => ("Decimal", d, Some(p)) 
    }
        

    // Collect Int Ranges
    // Call solve to remove duplicates
    def collectIntRanges(src: ClassList): List[IntRange1] = 
        List.flatMap(intRanges, src.classes)

    // One-to-many
    def intRanges(src: Class): List[IntRange1] =
        List.flatMap(intRange1, src.characteristics)

    // One-to-zero-or-one
    def intRange1(src: Characteristic): List[IntRange1] =
        match src.refinement {
            case Some(IntRange(lo,hi)) => {charName = src.name, low = lo, high = hi} :: Nil
            case _ => Nil
        } 
    
    // Collect Decimal Ranges
    // Call solve to remove duplicates
    def collectDecimalRanges(src: ClassList): List[DecimalRange1] =
        List.flatMap(decimalRanges, src.classes)

    // One-to-many
    def decimalRanges(src: Class): List[DecimalRange1] =
        List.flatMap(decimalRange1, src.characteristics)

    // One-to-zero-or-one
    def decimalRange1(src: Characteristic):  List[DecimalRange1] =
        let name = src.name;
        match src.refinement {
            case Some(DecimalRange(lo,hi)) => {charName = name, low = lo, high = hi} :: Nil
            case _ => Nil
        } 

    // Collect Selection Values
    // Call solve to remove duplicates
    def collectSelectionValues(src: ClassList):  List[SelectionValue1] = 
        List.flatMap(selectionValues, src.classes)

    // One-to-many
    def selectionValues(src: Class):  List[SelectionValue1] =
        List.flatMap(selectionValue1, src.characteristics)

    // One-to-zero-or-one
    def selectionValue1(src: Characteristic):  List[SelectionValue1] =
        let name = src.name;
        match src.refinement {
            case Some(ListOfValues(xs)) => List.map(x -> {charName = name, value = x}, xs)
            case _ => Nil
        } 


    // Class Members

    def writeClassMembers(prefix: String, rows: List[ClassMember1]): JdbcExport[Int32] =
        use FactIO/JdbcExport.{flatMap, return, execute, prepareStatement, foldM, writeRow, commit};
        let* _          = execute("DROP TABLE IF EXISTS ${prefix}_class_members");
        let* _          = execute(sqlCreateClassMembers(prefix));
        let* stmt       = prepareStatement("INSERT OR IGNORE INTO ${prefix}_class_members(classname, charname) VALUES(?,?)");
        let* nrows      = foldM((ac, x) -> { let* n = writeRow(stmt, classMemberRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)



    /// A RowSetter for the body of a ClassMember
    def classMemberRowSetter(x: ClassMember1): JdbcRowSetter[Unit] = 
        use FactIO/JdbcRowSetter.{flatMap, return, putString!};
        let* _ = putString!(0, x.className);
        let* _ = putString!(1, x.charName);
        return()


    // Characteristics

    def writeCharacteristics(prefix: String, rows: List[Characteristic1]): JdbcExport[Int32] =
        use FactIO/JdbcExport.{flatMap, return, execute, prepareStatement, foldM, writeRow, commit};
        let* _          = execute("DROP TABLE IF EXISTS ${prefix}_characteristics");
        let* _          = execute(sqlCreateCharacteristics(prefix));
        let* stmt       = prepareStatement("INSERT OR IGNORE INTO ${prefix}_characteristics(charname, datatype, num_chars, decimal_places) VALUES(?,?,?,?)");
        let* nrows      = foldM((ac, x) -> { let* n = writeRow(stmt, characteristicRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)

    /// A RowSetter for the body of a Characteristic
    def characteristicRowSetter(x: Characteristic1): JdbcRowSetter[Unit] = 
        use FactIO/JdbcRowSetter.{flatMap, return, putString!, putInt32!, putOptionInt32!};
        let* _ = putString!(0, x.charName);
        let* _ = putString!(1, x.datatype);
        let* _ = putInt32!(2, x.charLength);
        let* _ = putOptionInt32!(3, x.decimalPrec);
        return()

    // Int Ranges

    def writeIntRanges(prefix: String, rows: List[IntRange1]): JdbcExport[Int32] =
        use FactIO/JdbcExport.{flatMap, return, execute, prepareStatement, foldM, writeRow, commit};
        let* _          = execute("DROP TABLE IF EXISTS ${prefix}_int_ranges");
        let* _          = execute(sqlCreateIntRanges(prefix));
        let* stmt       = prepareStatement("INSERT OR IGNORE INTO ${prefix}_int_ranges(charname, range_low, range_high) VALUES(?,?,?)");
        let* nrows      = foldM((ac, x) -> { let* n = writeRow(stmt, intRangeRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)

    /// A RowSetter for IntRange
    def intRangeRowSetter(x: IntRange1): JdbcRowSetter[Unit] = 
        use FactIO/JdbcRowSetter.{flatMap, return, putString!, putInt32!};
        let* _ = putString!(0, x.charName);
        let* _ = putInt32!(1, x.low);
        let* _ = putInt32!(2, x.high);
        return()


    // Decimal Ranges

    def writeDecimalRanges(prefix: String, rows: List[DecimalRange1]): JdbcExport[Int32] =
        use FactIO/JdbcExport.{flatMap, return, execute, prepareStatement, foldM, writeRow, commit};
        let* _          = execute("DROP TABLE IF EXISTS ${prefix}_decimal_ranges");
        let* _          = execute(sqlCreateDecimalRanges(prefix));
        let* stmt       = prepareStatement("INSERT OR IGNORE INTO ${prefix}_decimal_ranges(charname, range_low, range_high) VALUES(?,?,?)");
        let* nrows      = foldM((ac, x) -> { let* n = writeRow(stmt, decimalRangeRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)

    
    /// A RowSetter for DecimalRange1
    def decimalRangeRowSetter(x: DecimalRange1): JdbcRowSetter[Unit] = 
        use FactIO/JdbcRowSetter.{flatMap, return, putString!, putFloat64!};
        let* _ = putString!(0, x.charName);
        let* _ = putFloat64!(1, x.low);
        let* _ = putFloat64!(2, x.high);
        return()

    // Selection Values

    def writeSelectionValues(prefix: String, rows: List[SelectionValue1]): JdbcExport[Int32] =
        use FactIO/JdbcExport.{flatMap, return, execute, prepareStatement, foldM, writeRow, commit};
        let* _          = execute("DROP TABLE IF EXISTS ${prefix}_selection_values");
        let* _          = execute(sqlCreateSelectionValues(prefix));
        let* stmt       = prepareStatement("INSERT OR IGNORE INTO ${prefix}_selection_values(charname, value) VALUES(?,?)");
        let* nrows      = foldM((ac, x) -> { let* n = writeRow(stmt, selectionValueRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)


    /// A RowSetter for SelectionValue1
    def selectionValueRowSetter(x: SelectionValue1): JdbcRowSetter[Unit] = 
        use FactIO/JdbcRowSetter.{flatMap, return, putString!};
        let* _ = putString!(0, x.charName);
        let* _ = putString!(1, x.value);
        return()



    // SQL DDL

    def sqlCreateClassMembers(prefix: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${prefix}_class_members ("
                :: "classname       TEXT NOT NULL,"
                :: "charname        TEXT NOT NULL,"
                :: "UNIQUE(charname, classname)"
                :: ")"
                :: Nil
        )

    def sqlCreateCharacteristics(prefix: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${prefix}_characteristics ("
                :: "charname       TEXT    PRIMARY KEY NOT NULL UNIQUE,"
                :: "datatype       TEXT    NOT NULL,"
                :: "num_chars      INTEGER NOT NULL,"
                :: "decimal_places INTEGER"
                :: ")"
                :: Nil
        )


    def sqlCreateIntRanges(prefix: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${prefix}_int_ranges ("
                :: "charname   TEXT    NOT NULL,"
                :: "range_low  INTEGER NOT NULL,"
                :: "range_high INTEGER NOT NULL,"
                :: "UNIQUE(charname, range_low, range_high)"
                :: ")"
                :: Nil
        )

    def sqlCreateDecimalRanges(prefix: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${prefix}_decimal_ranges ("
                :: "charname   TEXT    NOT NULL,"
                :: "range_low  DECIMAL NOT NULL,"
                :: "range_high DECIMAL NOT NULL,"
                :: "UNIQUE(charname, range_low, range_high)"
                :: ")"
                :: Nil
        )

    def sqlCreateSelectionValues(prefix: String): String =
        String.unwords(
            "CREATE TABLE ${prefix}_selection_values ("
                :: "charname TEXT NOT NULL,"
                :: "value    TEXT NOT NULL,"
                :: "UNIQUE(charname, value)"
                :: ")"
                :: Nil
        )

} 