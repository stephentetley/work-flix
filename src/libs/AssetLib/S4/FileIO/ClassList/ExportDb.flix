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

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;


    use AssetLib/S4/FileIO/ClassList/Datatypes.{ClassList, Class, Characteristic, Datatype, Refinement};
    use AssetLib/S4/FileIO/ClassList/Datatypes.Datatype.{Text, Date, NumInt, NumDecimal};
    use AssetLib/S4/FileIO/ClassList/Datatypes.Refinement.{ListOfValues, IntRange, DecimalRange};
    use AssetLib/S4/FileIO/ClassList/Parser.{parseFile};
    use AssetLib/S4/FileIO/ClassList/Builder.{buildClassList};



    type alias ClassListTableNames = 
        { classMembers: String
        , characteristicDefs: String
        , intRanges: String
        , decimalRanges: String
        , selectionValues: String
        }

    pub def defaultTableNames(): ClassListTableNames = 
        { classMembers          = "cf_members"
        , characteristicDefs    = "cf_char_defs"
        , intRanges             = "cf_int_ranges"
        , decimalRanges         = "cf_decimal_ranges"
        , selectionValues       = "cf_selection_values"
        }


    pub def storeFlocClassFile(tableNames: ClassListTableNames, dropTable: Bool, src: System.FilePath, cs: Text.Charset) : DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, whenTrue, setAutoCommit, commit};
        let* xs     = parseFlocClassList(src, cs);
        let* _      = whenTrue(dropTable, setupTables(tableNames));
        let* _      = populateTables(tableNames, "floc", xs);
        return()

    pub def storeEquiClassFile(tableNames: ClassListTableNames, dropTable: Bool, src: System.FilePath, cs: Text.Charset) : DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, whenTrue, setAutoCommit, commit};
        let* xs     = parseEquiClassList(src, cs);
        let* _      = whenTrue(dropTable, setupTables(tableNames));
        let* _      = populateTables(tableNames, "equi", xs);
        return()



    type alias ClassMember1 = {classType: String, className: String, charName: String}
    
    type alias CharacteristicDef1 = {classType: String, charName: String, datatype: String, charLength: Int32, decimalPrec: Option[Int32]}
    
    type alias IntRange1 = {classType: String, charName: String, low: Int32, high: Int32}
    
    type alias DecimalRange1 = {classType: String, charName: String, low: Float64, high: Float64}

    type alias SelectionValue1 = {classType: String, charName: String, value: String}



    def parseFlocClassList(path: System.FilePath, cs: Text.Charset): DbMonad[ClassList] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult};
        use AssetLib/S4/FileIO/ClassList/Datatypes.SourceType.{FlocClasses};
        let* ast    = liftActionResult(_ -> parseFile(path, FlocClasses, cs));
        let ans     = buildClassList(ast);
        return(ans)

    def parseEquiClassList(path: System.FilePath, cs: Text.Charset): DbMonad[ClassList] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult};
        use AssetLib/S4/FileIO/ClassList/Datatypes.SourceType.{EquiClasses};
        let* ast    = liftActionResult(_ -> parseFile(path, EquiClasses, cs));
        let ans     = buildClassList(ast);
        return(ans)


    def setupTables(x: ClassListTableNames): DbMonad[Unit] =  
        use BasicDb/DbMonad.{flatMap, return, execute, setAutoCommit, commit};
        let* _      = setAutoCommit(false);
        let* _      = execute("DROP TABLE IF EXISTS ${x.classMembers};");
        let* _      = execute(createTableClassMembersSql(x.classMembers));
        let* _      = execute("DROP TABLE IF EXISTS ${x.characteristicDefs};");
        let* _      = execute(createTableCharacteristicDefsSql(x.characteristicDefs));
        let* _      = execute("DROP TABLE IF EXISTS ${x.intRanges};");
        let* _      = execute(createTableIntRangeSql(x.intRanges));
        let* _      = execute("DROP TABLE IF EXISTS ${x.decimalRanges};");
        let* _      = execute(createTableDecimalRangeSql(x.decimalRanges));
        let* _      = execute("DROP TABLE IF EXISTS ${x.selectionValues};");
        let* _      = execute(createTableSelectionValueSql(x.selectionValues));
        let* _      = commit();
        return()


    def populateTables(x: ClassListTableNames, classType: String, src: ClassList): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, return, setAutoCommit, commit, liftAction};
        let* _      = setAutoCommit(false);
        let* _      = liftAction(_ -> Console.printLine("${classType} class members"));
        let* _      = collectClassMembers(classType, src) |> writeClassMembers(x.classMembers);
        let* _      = liftAction(_ -> Console.printLine("${classType} characteristic defs"));
        let* _      = collectCharacteristics(classType, src) |> writeCharacteristicDefs(x.characteristicDefs);
        let* _      = liftAction(_ -> Console.printLine("${classType} int ranges"));
        let* _      = collectIntRanges(classType, src) |> writeIntRanges(x.intRanges);
        let* _      = liftAction(_ -> Console.printLine("${classType} decimal ranges"));
        let* _      = collectDecimalRanges(classType, src) |> writeDecimalRanges(x.decimalRanges);        
        let* _      = liftAction(_ -> Console.printLine("${classType} selection values"));
        let* _      = collectSelectionValues(classType, src) |> writeSelectionValues(x.selectionValues);
        let* _      = commit();
        return()


    // Traversals

    // Collect ClassMembers
    def collectClassMembers(ctype: String, src: ClassList): List[ClassMember1] =
        let cmp = (x,y) -> x.className == y.className and x.charName == y.charName;
        List.flatMap(classMember1(ctype), src.classes) |> List.distinctWith(cmp)

    // One-to-many
    def classMember1(ctype: String, src: Class): List[ClassMember1] =
        List.map(r ->  {classType = ctype, className = src.name, charName = r.name}, src.characteristics)
        

    // Collect Characteristics
    def collectCharacteristics(ctype: String, src: ClassList): List[CharacteristicDef1] = 
        let cmp = (x,y) -> x.charName == y.charName and x.datatype == y.datatype;
        List.flatMap(characteristics(ctype), src.classes) |> List.distinctWith(cmp)

    // One-to-many
    def characteristics(ctype: String, src: Class): List[CharacteristicDef1] =
        List.map(characteristic1(ctype), src.characteristics)

    // One-to-one
    def characteristic1(ctype: String,src: Characteristic):  CharacteristicDef1 =
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

    def writeClassMembers(tableName: String, rows: List[ClassMember1]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, prepareStatement, foldLeftM, psExecuteUpdate, commit};
        let* stmt       = prepareStatement("INSERT OR IGNORE INTO ${tableName} (classtype, classname, charname) VALUES(?, ?, ?)");
        let* nrows      = foldLeftM((ac, x) -> { let* n = psExecuteUpdate(stmt, classMemberRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)



    /// A RowSetter for the body of a ClassMember
    def classMemberRowSetter(x: ClassMember1): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!};
        let* _ = putStringAt!(0, x.classType);
        let* _ = putStringAt!(1, x.className);
        let* _ = putStringAt!(2, x.charName);
        return()


    // Characteristics

    def writeCharacteristicDefs(tableName: String, rows: List[CharacteristicDef1]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, prepareStatement, foldLeftM, psExecuteUpdate, commit};
        let* stmt       = prepareStatement("INSERT OR IGNORE INTO ${tableName} (classtype, charname, datatype, num_chars, decimal_places) VALUES(?,?,?,?,?)");
        let* nrows      = foldLeftM((ac, x) -> { let* n = psExecuteUpdate(stmt, characteristicDefRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)

    /// A RowSetter for the body of a Characteristic
    def characteristicDefRowSetter(x: CharacteristicDef1): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!, putInt32At!, putOptionInt32At!};
        let* _ = putStringAt!(0, x.classType);
        let* _ = putStringAt!(1, x.charName);
        let* _ = putStringAt!(2, x.datatype);
        let* _ = putInt32At!(3, x.charLength);
        let* _ = putOptionInt32At!(4, x.decimalPrec);
        return()

    // Int Ranges

    def writeIntRanges(tableName: String, rows: List[IntRange1]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, prepareStatement, foldLeftM, psExecuteUpdate, commit};
        let* stmt       = prepareStatement("INSERT OR IGNORE INTO ${tableName} (classtype, charname, range_low, range_high) VALUES(?,?,?,?)");
        let* nrows      = foldLeftM((ac, x) -> { let* n = psExecuteUpdate(stmt, intRangeRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)

    /// A RowSetter for IntRange
    def intRangeRowSetter(x: IntRange1): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!, putInt32At!};
        let* _ = putStringAt!(0, x.classType);
        let* _ = putStringAt!(1, x.charName);
        let* _ = putInt32At!(2, x.low);
        let* _ = putInt32At!(3, x.high);
        return()


    // Decimal Ranges

    def writeDecimalRanges(tableName: String, rows: List[DecimalRange1]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, prepareStatement, foldLeftM, psExecuteUpdate, commit};
        let* stmt       = prepareStatement("INSERT OR IGNORE INTO ${tableName} (classtype, charname, range_low, range_high) VALUES(?,?,?,?)");
        let* nrows      = foldLeftM((ac, x) -> { let* n = psExecuteUpdate(stmt, decimalRangeRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)

    
    /// A RowSetter for DecimalRange1
    def decimalRangeRowSetter(x: DecimalRange1): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!, putFloat64At!};
        let* _ = putStringAt!(0, x.classType);
        let* _ = putStringAt!(1, x.charName);
        let* _ = putFloat64At!(2, x.low);
        let* _ = putFloat64At!(3, x.high);
        return()

    // Selection Values

    def writeSelectionValues(tableName: String, rows: List[SelectionValue1]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, prepareStatement, foldLeftM, psExecuteUpdate, commit};
        let* stmt       = prepareStatement("INSERT OR IGNORE INTO ${tableName} (classtype, charname, value) VALUES(?,?,?)");
        let* nrows      = foldLeftM((ac, x) -> { let* n = psExecuteUpdate(stmt, selectionValueRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)


    /// A RowSetter for SelectionValue1
    def selectionValueRowSetter(x: SelectionValue1): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!};
        let* _ = putStringAt!(0, x.classType);
        let* _ = putStringAt!(1, x.charName);
        let* _ = putStringAt!(2, x.value);
        return()



    // SQL DDL

    def createTableClassMembersSql(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "classtype       TEXT NOT NULL,"
                :: "classname       TEXT NOT NULL,"
                :: "charname        TEXT NOT NULL,"
                :: "UNIQUE(classtype, charname, classname)"
                :: ")"
                :: Nil
        )

    def createTableCharacteristicDefsSql(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "classtype       TEXT NOT NULL,"
                :: "charname        TEXT NOT NULL,"
                :: "datatype        TEXT NOT NULL,"
                :: "num_chars       INTEGER NOT NULL,"
                :: "decimal_places  INTEGER,"
                :: "UNIQUE(classtype, charname, datatype)"
                :: ")"
                :: Nil
        )


    def createTableIntRangeSql(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "classtype       TEXT NOT NULL,"
                :: "charname        TEXT NOT NULL,"
                :: "range_low       INTEGER NOT NULL,"
                :: "range_high      INTEGER NOT NULL,"
                :: "UNIQUE(classtype, charname)"
                :: ")"
                :: Nil
        )

    def createTableDecimalRangeSql(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "classtype       TEXT NOT NULL,"
                :: "charname        TEXT NOT NULL,"
                :: "range_low       DECIMAL NOT NULL,"
                :: "range_high      DECIMAL NOT NULL,"
                :: "UNIQUE(classtype, charname)"
                :: ")"
                :: Nil
        )

    def createTableSelectionValueSql(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "classtype       TEXT NOT NULL,"
                :: "charname        TEXT NOT NULL,"
                :: "value           TEXT NOT NULL,"
                :: "UNIQUE(classtype, charname, value)"
                :: ")"
                :: Nil
        )

} 