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

namespace AssetLib/S4/FileIO/ClassList/ExportDb { 

    use FactIO.JdbcExport;
    use FactIO.JdbcWriteList;
    use FactIO.JdbcRowSetter;

    use AssetLib/Common/Utils.{foldMapRel};
    use AssetLib/S4/FileIO/ClassList/Datatypes.{ClassList, Class, Characteristic, Datatype, Refinement};
    use AssetLib/S4/FileIO/ClassList/Datatypes.Datatype.{Text, Date, NumInt, NumDecimal};
    use AssetLib/S4/FileIO/ClassList/Datatypes.Refinement.{ListOfValues, IntRange, DecimalRange};
    use AssetLib/S4/FileIO/ClassList/Parser.{parseFile};
    use AssetLib/S4/FileIO/ClassList/Builder.{buildClassList};

    type alias ClassMember1 = {classType: String, className: String, charName: String}
    
    type alias Characteristic1 = {classType: String, charName: String, datatype: String, charLength: Int32, decimalPrec: Option[Int32]}
    
    type alias IntRange1 = {classType: String, charName: String, low: Int32, high: Int32}
    
    type alias DecimalRange1 = {classType: String, charName: String, low: Float64, high: Float64}

    type alias SelectionValue1 = {classType: String, charName: String, value: String}

    pub def parseFlocClassList(path: System.FilePath, cs: Text.Charset): JdbcExport[ClassList] = 
        use FactIO/JdbcExport.{flatMap, return, liftActionResult};
        use AssetLib/S4/FileIO/ClassList/Datatypes.SourceType.{FlocClasses};
        let* ast    = liftActionResult(_ -> parseFile(path, FlocClasses, cs));
        let ans     = buildClassList(ast);
        return(ans)

    pub def parseEquiClassList(path: System.FilePath, cs: Text.Charset): JdbcExport[ClassList] = 
        use FactIO/JdbcExport.{flatMap, return, liftActionResult};
        use AssetLib/S4/FileIO/ClassList/Datatypes.SourceType.{EquiClasses};
        let* ast    = liftActionResult(_ -> parseFile(path, EquiClasses, cs));
        let ans     = buildClassList(ast);
        return(ans)


    pub def setupTables(): JdbcExport[Unit] =  
        use FactIO/JdbcExport.{flatMap, return, execute, prepareStatement, foldM, writeRow, commit};
        let* _          = execute("DROP TABLE IF EXISTS classlist_class_members");
        let* _          = execute(sqlCreateClassMembers());
        let* _          = execute("DROP TABLE IF EXISTS classlist_characteristics");
        let* _          = execute(sqlCreateCharacteristics());
        let* _          = execute("DROP TABLE IF EXISTS classlist_int_ranges");
        let* _          = execute(sqlCreateIntRanges());
        let* _          = execute("DROP TABLE IF EXISTS classlist_decimal_ranges");
        let* _          = execute(sqlCreateDecimalRanges());
        let* _          = execute("DROP TABLE IF EXISTS classlist_selection_values");
        let* _          = execute(sqlCreateSelectionValues());
        return()


    pub def outputTables(classType: String, src: ClassList): JdbcExport[Unit] =
        use FactIO/JdbcExport.{flatMap, return, setAutoCommitOff, close, liftAction};
        let* _      = setAutoCommitOff();
        let* _      = liftAction(_ -> Console.printLine("ClassMembers"));
        let* _      = collectClassMembers(classType, src) |> writeClassMembers;
        let* _      = liftAction(_ -> Console.printLine("Characteristics"));
        let* _      = collectCharacteristics(classType, src) |> writeCharacteristics;
        let* _      = liftAction(_ -> Console.printLine("IntRanges"));
        let* _      = collectIntRanges(classType, src) |> writeIntRanges;
        let* _      = liftAction(_ -> Console.printLine("DecimalRanges"));
        let* _      = collectDecimalRanges(classType, src) |> writeDecimalRanges;
        let* _      = liftAction(_ -> Console.printLine("SelectionValues"));
        let* _      = collectSelectionValues(classType, src) |> writeSelectionValues;
        return()


    // Traversals

    // Collect ClassMembers
    def collectClassMembers(ctype: String, src: ClassList): List[ClassMember1] =
        let cmp = (x,y) -> x.className == y.className && x.charName == y.charName;
        List.flatMap(classMember1(ctype), src.classes) |> List.distinctWith(cmp)

    // One-to-many
    def classMember1(ctype: String, src: Class): List[ClassMember1] =
        List.map(r ->  {classType = ctype, className = src.name, charName = r.name}, src.characteristics)
        

    // Collect Characteristics
    def collectCharacteristics(ctype: String, src: ClassList): List[Characteristic1] = 
        let cmp = (x,y) -> x.charName == y.charName && x.datatype == y.datatype;
        List.flatMap(characteristics(ctype), src.classes) |> List.distinctWith(cmp)

    // One-to-many
    def characteristics(ctype: String, src: Class): List[Characteristic1] =
        List.map(characteristic1(ctype), src.characteristics)

    // One-to-one
    def characteristic1(ctype: String,src: Characteristic):  Characteristic1 =
        let (typename, clength, prec) = deconsDatatype(src.datatype);
        {classType = ctype, charName = src.name, datatype = typename, charLength = clength, decimalPrec = prec} 
        
        
    def deconsDatatype(x: Datatype): (String, Int32, Option[Int32]) = match x { 
        case Text(d) => ("Text", d, None)
        case Date(d) => ("Date", d, None)
        case NumInt(d) => ("Int", d, None)
        case NumDecimal(d, p) => ("Decimal", d, Some(p)) 
    }
        

    // Collect Int Ranges
    // Call solve to remove duplicates
    def collectIntRanges(ctype: String, src: ClassList): List[IntRange1] = 
        List.flatMap(intRanges(ctype), src.classes)

    // One-to-many
    def intRanges(ctype: String, src: Class): List[IntRange1] =
        List.flatMap(intRange1(ctype), src.characteristics)

    // One-to-zero-or-one
    def intRange1(ctype: String, src: Characteristic): List[IntRange1] =
        match src.refinement {
            case Some(IntRange(lo,hi)) => {classType = ctype, charName = src.name, low = lo, high = hi} :: Nil
            case _ => Nil
        } 
    
    // Collect Decimal Ranges
    // Call solve to remove duplicates
    def collectDecimalRanges(ctype: String, src: ClassList): List[DecimalRange1] =
        List.flatMap(decimalRanges(ctype), src.classes)

    // One-to-many
    def decimalRanges(ctype: String, src: Class): List[DecimalRange1] =
        List.flatMap(decimalRange1(ctype), src.characteristics)

    // One-to-zero-or-one
    def decimalRange1(ctype: String, src: Characteristic):  List[DecimalRange1] =
        let name = src.name;
        match src.refinement {
            case Some(DecimalRange(lo,hi)) => {classType = ctype, charName = name, low = lo, high = hi} :: Nil
            case _ => Nil
        } 

    // Collect Selection Values
    // Call solve to remove duplicates
    def collectSelectionValues(ctype: String, src: ClassList):  List[SelectionValue1] = 
        List.flatMap(selectionValues(ctype), src.classes)

    // One-to-many
    def selectionValues(ctype: String, src: Class):  List[SelectionValue1] =
        List.flatMap(selectionValue1(ctype), src.characteristics)

    // One-to-zero-or-one
    def selectionValue1(ctype: String, src: Characteristic):  List[SelectionValue1] =
        let name = src.name;
        match src.refinement {
            case Some(ListOfValues(xs)) => List.map(x -> {classType = ctype, charName = name, value = x}, xs)
            case _ => Nil
        } 




    // Class Members

    def writeClassMembers(rows: List[ClassMember1]): JdbcExport[Int32] =
        use FactIO/JdbcExport.{flatMap, return, prepareStatement, foldM, writeRow, commit};
        let* stmt       = prepareStatement("INSERT OR IGNORE INTO classlist_class_members(classtype, classname, charname) VALUES(?, ?, ?)");
        let* nrows      = foldM((ac, x) -> { let* n = writeRow(stmt, classMemberRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)



    /// A RowSetter for the body of a ClassMember
    def classMemberRowSetter(x: ClassMember1): JdbcRowSetter[Unit] = 
        use FactIO/JdbcRowSetter.{flatMap, return, putString!};
        let* _ = putString!(0, x.classType);
        let* _ = putString!(1, x.className);
        let* _ = putString!(2, x.charName);
        return()


    // Characteristics

    def writeCharacteristics(rows: List[Characteristic1]): JdbcExport[Int32] =
        use FactIO/JdbcExport.{flatMap, return, prepareStatement, foldM, writeRow, commit};
        let* stmt       = prepareStatement("INSERT OR IGNORE INTO classlist_characteristics(classtype, charname, datatype, num_chars, decimal_places) VALUES(?,?,?,?,?)");
        let* nrows      = foldM((ac, x) -> { let* n = writeRow(stmt, characteristicRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)

    /// A RowSetter for the body of a Characteristic
    def characteristicRowSetter(x: Characteristic1): JdbcRowSetter[Unit] = 
        use FactIO/JdbcRowSetter.{flatMap, return, putString!, putInt32!, putOptionInt32!};
        let* _ = putString!(0, x.classType);
        let* _ = putString!(1, x.charName);
        let* _ = putString!(2, x.datatype);
        let* _ = putInt32!(3, x.charLength);
        let* _ = putOptionInt32!(4, x.decimalPrec);
        return()

    // Int Ranges

    def writeIntRanges(rows: List[IntRange1]): JdbcExport[Int32] =
        use FactIO/JdbcExport.{flatMap, return, prepareStatement, foldM, writeRow, commit};
        let* stmt       = prepareStatement("INSERT OR IGNORE INTO classlist_int_ranges(classtype, charname, range_low, range_high) VALUES(?,?,?,?)");
        let* nrows      = foldM((ac, x) -> { let* n = writeRow(stmt, intRangeRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)

    /// A RowSetter for IntRange
    def intRangeRowSetter(x: IntRange1): JdbcRowSetter[Unit] = 
        use FactIO/JdbcRowSetter.{flatMap, return, putString!, putInt32!};
        let* _ = putString!(0, x.classType);
        let* _ = putString!(1, x.charName);
        let* _ = putInt32!(2, x.low);
        let* _ = putInt32!(3, x.high);
        return()


    // Decimal Ranges

    def writeDecimalRanges(rows: List[DecimalRange1]): JdbcExport[Int32] =
        use FactIO/JdbcExport.{flatMap, return, prepareStatement, foldM, writeRow, commit};
        let* stmt       = prepareStatement("INSERT OR IGNORE INTO classlist_decimal_ranges(classtype, charname, range_low, range_high) VALUES(?,?,?,?)");
        let* nrows      = foldM((ac, x) -> { let* n = writeRow(stmt, decimalRangeRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)

    
    /// A RowSetter for DecimalRange1
    def decimalRangeRowSetter(x: DecimalRange1): JdbcRowSetter[Unit] = 
        use FactIO/JdbcRowSetter.{flatMap, return, putString!, putFloat64!};
        let* _ = putString!(0, x.classType);
        let* _ = putString!(1, x.charName);
        let* _ = putFloat64!(2, x.low);
        let* _ = putFloat64!(3, x.high);
        return()

    // Selection Values

    def writeSelectionValues(rows: List[SelectionValue1]): JdbcExport[Int32] =
        use FactIO/JdbcExport.{flatMap, return, prepareStatement, foldM, writeRow, commit};
        let* stmt       = prepareStatement("INSERT OR IGNORE INTO classlist_selection_values(classtype, charname, value) VALUES(?,?,?)");
        let* nrows      = foldM((ac, x) -> { let* n = writeRow(stmt, selectionValueRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)


    /// A RowSetter for SelectionValue1
    def selectionValueRowSetter(x: SelectionValue1): JdbcRowSetter[Unit] = 
        use FactIO/JdbcRowSetter.{flatMap, return, putString!};
        let* _ = putString!(0, x.classType);
        let* _ = putString!(1, x.charName);
        let* _ = putString!(2, x.value);
        return()



    // SQL DDL

    def sqlCreateClassMembers(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS classlist_class_members ("
                :: "classtype       TEXT NOT NULL,"
                :: "classname       TEXT NOT NULL,"
                :: "charname        TEXT NOT NULL,"
                :: "UNIQUE(classtype, charname, classname)"
                :: ")"
                :: Nil
        )

    def sqlCreateCharacteristics(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS classlist_characteristics ("
                :: "classtype       TEXT NOT NULL,"
                :: "charname        TEXT NOT NULL,"
                :: "datatype        TEXT NOT NULL,"
                :: "num_chars       INTEGER NOT NULL,"
                :: "decimal_places  INTEGER,"
                :: "UNIQUE(classtype, charname, datatype)"
                :: ")"
                :: Nil
        )


    def sqlCreateIntRanges(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS classlist_int_ranges ("
                :: "classtype       TEXT NOT NULL,"
                :: "charname        TEXT NOT NULL,"
                :: "range_low       INTEGER NOT NULL,"
                :: "range_high      INTEGER NOT NULL,"
                :: "UNIQUE(classtype, charname)"
                :: ")"
                :: Nil
        )

    def sqlCreateDecimalRanges(): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS classlist_decimal_ranges ("
                :: "classtype       TEXT NOT NULL,"
                :: "charname        TEXT NOT NULL,"
                :: "range_low       DECIMAL NOT NULL,"
                :: "range_high      DECIMAL NOT NULL,"
                :: "UNIQUE(classtype, charname)"
                :: ")"
                :: Nil
        )

    def sqlCreateSelectionValues(): String =
        String.unwords(
            "CREATE TABLE classlist_selection_values ("
                :: "classtype       TEXT NOT NULL,"
                :: "charname        TEXT NOT NULL,"
                :: "value           TEXT NOT NULL,"
                :: "UNIQUE(classtype, charname, value)"
                :: ")"
                :: Nil
        )

} 