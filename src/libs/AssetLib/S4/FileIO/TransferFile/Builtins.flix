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



namespace AssetLib/S4/FileIO/TransferFile/Builtins {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;

    use AssetLib/S4/FileIO/TransferFile/Datatypes.EntityType.{ClassEqui, ValuaEqui};    
    use AssetLib/S4/FileIO/TransferFile.RowEvaluator;
    use AssetLib/S4/FileIO/TransferFile.RowSetter;

    /// IFLOTX

    type alias IflotxRow = 
        { funcloc: String
        , shortText: String
        , langCode: String
        , longText: String
        , moreTextExists: Bool
        }
    

    /// DropTable is a parameter as we might want to be loading more than one file
    pub def storeIflotxFile(tableName: String, dropTable: Bool, src: System.FilePath) : DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult};
        use AssetLib/S4/FileIO/TransferFile/Evaluate.{readAllRows};
        let* xs = liftActionResult(_ -> readAllRows(evalIflotxRow(), src));
        let* _  = dbWriteIflotxRows(tableName, dropTable, xs);
        return()

    /// Read
    def evalIflotxRow(): RowEvaluator[IflotxRow] = 
        use AssetLib/S4/FileIO/TransferFile/RowEvaluator.{getStringNamed, getS4BoolNamed};
        use AssetLib/S4/FileIO/TransferFile/RowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5) ->
                { funcloc           = x1
                , shortText         = x2
                , langCode          = x3
                , longText          = x4
                , moreTextExists    = x5
            })
            <&> getStringNamed("EQUI")
            <*> getStringNamed("PLTXT")
            <*> getStringNamed("LANGUCODE")
            <*> getStringNamed("FL_LTXT")
            <*> getS4BoolNamed("KZMLA")
            

    /// Write SQL
    pub def initIflotxTable(tableName: String): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, execute, setAutoCommit, commit};
        let* _      = setAutoCommit(false);
        let* _      = execute("DROP TABLE IF EXISTS ${tableName};");
        let* _      = execute(createTableIflotxRowSql(tableName));
        let* _      = commit();
        return()

    def dbWriteIflotxRows(tableName: String, dropTable: Bool, xs: List[IflotxRow]): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, whenTrue, prepareStatement, setAutoCommit, psExecuteUpdate, mapM, commit};
        let* _      = setAutoCommit(false);
        let* _      = whenTrue(dropTable, initIflotxTable(tableName));
        let* pstmt  = prepareStatement(insertIflotxRowSql(tableName));
        let* _      = mapM(x -> psExecuteUpdate(pstmt, setIflotxRowPStmt!(x)), xs);
        let* _      = commit();
        return()
    
    def setIflotxRowPStmt!(x: IflotxRow): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!, putInt32At!};
        let* _ = putStringAt!(0,  x.funcloc);
        let* _ = putStringAt!(1,  x.shortText);
        let* _ = putStringAt!(2,  x.langCode);
        let* _ = putStringAt!(3,  x.longText);
        let* _ = putInt32At!(4,  if (x.moreTextExists) 1 else 0);
        return()

    def insertIflotxRowSql(tableName: String): String =
        "INSERT INTO ${tableName}"
            + " (funcloc, short_text, lang_code, long_text, more_text_exists)"
            + " VALUES(?,?,?, ?,?);"

    def createTableIflotxRowSql(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "funcloc                 TEXT NOT NULL,"
                :: "short_text              TEXT,"
                :: "lang_code               TEXT NOT NULL,"
                :: "long_text               TEXT,"
                :: "more_text_exists        INTEGER NOT NULL"
                :: ");"
                :: Nil
        )

    /// CLASSEQUI

    type alias ClassFlocRow = 
        { funcloc: String
        , className: String
        , classType: String
        , internalClassNumber: String
        , status: Option[Int32]
        }

    
    pub def storeClassFlocFile(tableName: String, dropTable: Bool, src: System.FilePath) : DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult};
        use AssetLib/S4/FileIO/TransferFile/Evaluate.{readAllRows};
        let* xs = liftActionResult(_ -> readAllRows(evalClassFlocRow(), src));
        let* _  = dbWriteClassFlocRows(tableName, dropTable, xs);
        return()
    
    def evalClassFlocRow(): RowEvaluator[ClassFlocRow] = 
        use AssetLib/S4/FileIO/TransferFile/RowEvaluator.{optional, getStringNamed, getInt32Named};
        use AssetLib/S4/FileIO/TransferFile/RowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5) ->
                { funcloc               = x1
                , className             = x2
                , classType             = x3
                , internalClassNumber   = x4
                , status                = x5
                })
            <&> getStringNamed("FUNCLOC")               /// Functional Location
            <*> getStringNamed("CLASS")                 /// Class 
            <*> getStringNamed("CLASSTYPE")             /// Class Type
            <*> getStringNamed("CLINT")                 /// Internal class no
            <*> optional(getInt32Named("CLSTATUS1"))             /// Status

    /// Write SQL
    pub def initClassFlocTable(tableName: String): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, execute, setAutoCommit, commit};
        let* _      = setAutoCommit(false);
        let* _      = execute("DROP TABLE IF EXISTS ${tableName};");
        let* _      = execute(createTableClassFlocRowSql(tableName));
        let* _      = commit();
        return()

    def dbWriteClassFlocRows(tableName: String, dropTable: Bool, xs: List[ClassFlocRow]): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, whenTrue, prepareStatement, setAutoCommit, psExecuteUpdate, mapM, commit};
        let* _      = setAutoCommit(false);
        let* _      = whenTrue(dropTable, initClassFlocTable(tableName));
        let* pstmt  = prepareStatement(insertClassFlocRowSql(tableName));
        let* _      = mapM(x -> psExecuteUpdate(pstmt, setClassFlocRowPStmt!(x)), xs);
        let* _      = commit();
        return()
    
    def setClassFlocRowPStmt!(x: ClassFlocRow): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!, putInt32At!, putOptionInt32At!};
        let* _ = putStringAt!(0,  x.funcloc);
        let* _ = putStringAt!(1,  x.className);
        let* _ = putStringAt!(2,  x.classType);
        let* _ = putStringAt!(3,  x.internalClassNumber);
        let* _ = putOptionInt32At!(4,  x.status);
        return()

    def insertClassFlocRowSql(tableName: String): String =
        "INSERT INTO ${tableName}"
            + " (funcloc, class_name, class_type, internal_class_number, status)"
            + " VALUES(?,?,?, ?,?);"

    def createTableClassFlocRowSql(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "funcloc                 TEXT NOT NULL,"
                :: "class_name              TEXT NOT NULL,"
                :: "class_type              TEXT NOT NULL,"
                :: "internal_class_number   TEXT,"
                :: "status                  INTEGER"
                :: ");"
                :: Nil
        )



    /// CLASSFLOC

   type alias ValuaFlocRow = 
        { funcloc: String
        , classType: String
        , charId: String
        , charValue: String
        , code: Option[Int32]
        , valueDescription: String
        , intCounterValue: Int32
        , valueFrom: String
        , valueTo: String
        }

    pub def storeValuaFlocFile(tableName: String, dropTable: Bool, src: System.FilePath) : DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult};
        use AssetLib/S4/FileIO/TransferFile/Evaluate.{readAllRows};
        let* xs = liftActionResult(_ -> readAllRows(evalValuaFlocRow(), src));
        let* _  = dbWriteValuaFlocRows(tableName, dropTable, xs);
        return()


    /// Read

    def evalValuaFlocRow(): RowEvaluator[ValuaFlocRow] = 
        use AssetLib/S4/FileIO/TransferFile/RowEvaluator.{getStringNamed, getInt32Named, optional};
        use AssetLib/S4/FileIO/TransferFile/RowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9) ->
                { funcloc           = x1
                , classType         = x2
                , charId            = x3
                , charValue         = x4
                , code              = x5
                , valueDescription  = x6
                , intCounterValue   = x7
                , valueFrom         = x8
                , valueTo           = x9
                })
            <&> getStringNamed("FUNCLOC")               /// Functional Location
            <*> getStringNamed("CLASSTYPE")             /// Class Type
            <*> getStringNamed("CHARID")                /// Characteristic ID
            <*> getStringNamed("ATWRT")                 /// Characteristic Value
            <*> optional(getInt32Named("ATCOD"))        /// Code
            <*> getStringNamed("TEXTBEZ")               /// Description
            <*> getInt32Named("VALCNT")                 /// Int counter values
            <*> getStringNamed("ATFLV")                 /// Value from
            <*> getStringNamed("ATFLB")                 /// Value to


    /// Write SQL
    pub def initValuaFlocTable(tableName: String): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, execute, setAutoCommit, commit};
        let* _      = setAutoCommit(false);
        let* _      = execute("DROP TABLE IF EXISTS ${tableName};");
        let* _      = execute(createTableValuaFlocRowSql(tableName));
        let* _      = commit();
        return()

    def dbWriteValuaFlocRows(tableName: String, dropTable: Bool, xs: List[ValuaFlocRow]): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, whenTrue, prepareStatement, setAutoCommit, psExecuteUpdate, mapM, commit};
        let* _      = setAutoCommit(false);
        let* _      = whenTrue(dropTable, initValuaFlocTable(tableName));
        let* pstmt  = prepareStatement(insertValuaFlocRowSql(tableName));
        let* _      = mapM(x -> psExecuteUpdate(pstmt, setValuaFlocRowPStmt!(x)), xs);
        let* _      = commit();
        return()
    
    def setValuaFlocRowPStmt!(x: ValuaFlocRow): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!, putInt32At!, putOptionInt32At!};
        let* _ = putStringAt!(0,  x.funcloc);
        let* _ = putStringAt!(1,  x.classType);
        let* _ = putStringAt!(2,  x.charId);
        let* _ = putStringAt!(3,  x.charValue);
        let* _ = putOptionInt32At!(4,  x.code);
        let* _ = putStringAt!(5,  x.valueDescription);
        let* _ = putInt32At!(6,  x.intCounterValue);
        let* _ = putStringAt!(7,  x.valueFrom);
        let* _ = putStringAt!(8,  x.valueTo);
        return()




    def insertValuaFlocRowSql(tableName: String): String =
        "INSERT INTO ${tableName}"
            + " (funcloc, class_type, char_id, char_value, code, value_description, int_counter_value, value_from, value_to)"
            + " VALUES(?,?,?, ?,?,?, ?,?,?)"

    def createTableValuaFlocRowSql(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "funcloc             TEXT NOT NULL,"
                :: "class_type          TEXT NOT NULL,"
                :: "char_id             TEXT NOT NULL,"
                :: "char_value          TEXT,"
                :: "code                INTEGER,"
                :: "value_description   TEXT,"
                :: "int_counter_value   INTEGER NOT NULL,"
                :: "value_from          TEXT,"
                :: "value_to            TEXT"
                :: ")"
                :: Nil
        )


    /// EQMLTXT

    type alias EqmltxtRow = 
        { equi: String
        , shortText: String
        , langCode: String
        , longText: String
        , moreTextExists: Bool
        }
    

    /// DropTable is a parameter as we might want to be loading more than one file
    pub def storeEqmltxtFile(tableName: String, dropTable: Bool, src: System.FilePath) : DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult};
        use AssetLib/S4/FileIO/TransferFile/Evaluate.{readAllRows};
        let* xs = liftActionResult(_ -> readAllRows(evalEqmltxtRow(), src));
        let* _  = dbWriteEqmltxtRows(tableName, dropTable, xs);
        return()

    /// Read
    def evalEqmltxtRow(): RowEvaluator[EqmltxtRow] = 
        use AssetLib/S4/FileIO/TransferFile/RowEvaluator.{getStringNamed, getS4BoolNamed};
        use AssetLib/S4/FileIO/TransferFile/RowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5) ->
                { equi              = x1
                , shortText         = x2
                , langCode          = x3
                , longText          = x4
                , moreTextExists    = x5
            })
            <&> getStringNamed("EQUI")
            <*> getStringNamed("SHORTXT")
            <*> getStringNamed("LANGUCODE")
            <*> getStringNamed("EQ_LTXT")
            <*> getS4BoolNamed("LTXTIND")
            

    /// Write SQL

    pub def initEqmltxtTable(tableName: String): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, whenTrue, execute, setAutoCommit, commit};
        let* _      = setAutoCommit(false);
        let* _      = execute("DROP TABLE IF EXISTS ${tableName}");
        let* _      = execute(createTableEqmltxtRowSql(tableName));
        let* _      = commit();
        return()

    def dbWriteEqmltxtRows(tableName: String, dropTable: Bool, xs: List[EqmltxtRow]): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, whenTrue, prepareStatement, setAutoCommit, psExecuteUpdate, mapM, commit};
        let* _      = setAutoCommit(false);
        let* _      = whenTrue(dropTable, initEqmltxtTable(tableName));
        let* pstmt  = prepareStatement(insertEqmltxtRowSql(tableName));
        let* _      = mapM(x -> psExecuteUpdate(pstmt, setEqmltxtRowPStmt!(x)), xs);
        let* _      = commit();
        return()
    
    def setEqmltxtRowPStmt!(x: EqmltxtRow): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!, putInt32At!};
        let* _ = putStringAt!(0,  x.equi);
        let* _ = putStringAt!(1,  x.shortText);
        let* _ = putStringAt!(2,  x.langCode);
        let* _ = putStringAt!(3,  x.longText);
        let* _ = putInt32At!(4,  if (x.moreTextExists) 1 else 0);
        return()

    def insertEqmltxtRowSql(tableName: String): String =
        "INSERT INTO ${tableName}"
            + " (equi, short_text, lang_code, long_text, more_text_exists)"
            + " VALUES(?,?,?, ?,?);"

    def createTableEqmltxtRowSql(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "equi                    TEXT NOT NULL,"
                :: "short_text              TEXT,"
                :: "lang_code               TEXT NOT NULL,"
                :: "long_text               TEXT,"
                :: "more_text_exists        INTEGER NOT NULL"
                :: ");"
                :: Nil
        )


    /// CLASSEQUI

    /// Note status appears to be optional.
    type alias ClassEquiRow = 
        { equi: String
        , className: String
        , classType: String
        , internalClassNumber: String
        , status: Option[Int32]
        }

    
    pub def outputClassEquiFile(user: String,
                                rows: List[ClassEquiRow], 
                                outpath: System.FilePath): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        use AssetLib/S4/FileIO/TransferFile/EmitUploadFile.{outputUploadFile, execMapRowSetter};
        let headers = ["EQUI", "CLASS", "CLASSTYPE", "CLINT", "CLSTATUS1"];
        let* rows2 = execMapRowSetter(headers, classEquiSetRow!, rows);
        outputUploadFile(ClassEqui, "", user, headers, rows2, outpath)

    def classEquiSetRow!(x: ClassEquiRow): RowSetter[Unit] = 
        use AssetLib/S4/FileIO/TransferFile/RowSetter.{flatMap, return, putStringNamed!, 
            putInt32Named!, putPaddedInt32Named!};
        let* _  = putStringNamed!("EQUI",       x.equi);
        let* _  = putStringNamed!("CLASS",  x.className);
        let* _  = putStringNamed!("CLASSTYPE",  x.classType);
        let* _  = putStringNamed!("CLINT",  x.internalClassNumber);
        let* _  = putStringNamed!("CLSTATUS1",      Option.getWithDefault(Option.map(ToString.toString, x.status), ""));
        return()


    pub def storeClassEquiFile(tableName: String, dropTable: Bool, src: System.FilePath) : DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult};
        use AssetLib/S4/FileIO/TransferFile/Evaluate.{readAllRows};
        let* xs = liftActionResult(_ -> readAllRows(evalClassEquiRow(), src));
        let* _  = dbWriteClassEquiRows(tableName, dropTable, xs);
        return()
    
    def evalClassEquiRow(): RowEvaluator[ClassEquiRow] = 
        use AssetLib/S4/FileIO/TransferFile/RowEvaluator.{optional, getStringNamed, getInt32Named};
        use AssetLib/S4/FileIO/TransferFile/RowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5) ->
                { equi                  = x1
                , className             = x2
                , classType             = x3
                , internalClassNumber   = x4
                , status                = x5
                })
            <&> getStringNamed("EQUI")                  /// Equipment
            <*> getStringNamed("CLASS")                 /// Class 
            <*> getStringNamed("CLASSTYPE")             /// Class Type
            <*> getStringNamed("CLINT")                 /// Internal class no
            <*> optional(getInt32Named("CLSTATUS1"))              /// Status

    /// Write SQL
    pub def initClassEquiTable(tableName: String): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, whenTrue, execute, setAutoCommit, commit};
        let* _      = setAutoCommit(false);
        let* _      = execute("DROP TABLE IF EXISTS ${tableName};");
        let* _      = execute(createTableClassEquiRowSql(tableName));
        let* _      = commit();
        return()

    def dbWriteClassEquiRows(tableName: String, dropTable: Bool, xs: List[ClassEquiRow]): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, whenTrue, prepareStatement, setAutoCommit, psExecuteUpdate, mapM, commit};
        let* _      = setAutoCommit(false);
        let* _      = whenTrue(dropTable, initClassEquiTable(tableName));
        let* pstmt  = prepareStatement(insertClassEquiRowSql(tableName));
        let* _      = mapM(x -> psExecuteUpdate(pstmt, setClassEquiRowPStmt!(x)), xs);
        let* _      = commit();
        return()
    
    def setClassEquiRowPStmt!(x: ClassEquiRow): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!, putInt32At!, putOptionInt32At!};
        let* _ = putStringAt!(0,  x.equi);
        let* _ = putStringAt!(1,  x.className);
        let* _ = putStringAt!(2,  x.classType);
        let* _ = putStringAt!(3,  x.internalClassNumber);
        let* _ = putOptionInt32At!(4,  x.status);
        return()

    def insertClassEquiRowSql(tableName: String): String =
        "INSERT INTO ${tableName}"
            + " (equi, class_name, class_type, internal_class_number, status)"
            + " VALUES(?,?,?, ?,?);"

    def createTableClassEquiRowSql(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "equi                    TEXT NOT NULL,"
                :: "class_name              TEXT NOT NULL,"
                :: "class_type              TEXT NOT NULL,"
                :: "internal_class_number   TEXT,"
                :: "status                  INTEGER"
                :: ");"
                :: Nil
        )

    /// VALUAEQUI


    type alias ValuaEquiRow = 
        { equi: String
        , classType: String
        , charId: String
        , charValue: String
        , code: Option[Int32]
        , valueDescription: String
        , intCounterValue: Int32
        , valueFrom: String
        , valueTo: String
        }

    pub def outputValuaEquiFile(user: String,
                                rows: List[ValuaEquiRow], 
                                outpath: System.FilePath): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        use AssetLib/S4/FileIO/TransferFile/EmitUploadFile.{outputUploadFile, execMapRowSetter};
        let headers = ["EQUI", "CLASSTYPE", "CHARID", "ATWRT", "ATCOD", "TEXTBEZ", "VALCNT", "ATFLV", "ATFLB"];
        let* rows2 = execMapRowSetter(headers, valuaEquiSetRow!, rows);
        outputUploadFile(ValuaEqui, "", user, headers, rows2, outpath)

    def valuaEquiSetRow!(x: ValuaEquiRow): RowSetter[Unit] = 
        use AssetLib/S4/FileIO/TransferFile/RowSetter.{flatMap, return, putStringNamed!, 
            putInt32Named!, putPaddedInt32Named!};
        let* _  = putStringNamed!("EQUI",       x.equi);
        let* _  = putStringNamed!("CLASSTYPE",  x.classType);
        let* _  = putStringNamed!("CHARID",     x.charId);
        let* _  = putStringNamed!("ATWRT",      x.charValue);
        let* _  = putStringNamed!("ATCOD",      Option.getWithDefault(Option.map(ToString.toString, x.code), ""));
        let* _  = putStringNamed!("TEXTBEZ",    x.valueDescription);
        let* _  = putPaddedInt32Named!("VALCNT", 4, x.intCounterValue);
        let* _  = putStringNamed!("ATFLV",      x.valueFrom);
        let* _  = putStringNamed!("ATFLB",      x.valueTo);
        return()    

    pub def readValuaEquiFile(path: System.FilePath) : Result[List[ValuaEquiRow], String] & Impure =         
        use AssetLib/S4/FileIO/TransferFile/Evaluate.{readAllRows};
        readAllRows(evalValuaEquiRow(), path)
        

    pub def storeValuaEquiFile(tableName: String, dropTable: Bool, src: System.FilePath) : DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult};
        use AssetLib/S4/FileIO/TransferFile/Evaluate.{readAllRows};
        let* xs = liftActionResult(_ -> readAllRows(evalValuaEquiRow(), src));
        let* _  = dbWriteValuaEquiRows(tableName, dropTable, xs);
        return()


    /// Read
    def evalValuaEquiRow(): RowEvaluator[ValuaEquiRow] = 
        use AssetLib/S4/FileIO/TransferFile/RowEvaluator.{optional, getStringNamed, getInt32Named};
        use AssetLib/S4/FileIO/TransferFile/RowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9) ->
                { equi              = x1
                , classType         = x2
                , charId            = x3
                , charValue         = x4
                , code              = x5
                , valueDescription  = x6
                , intCounterValue   = x7
                , valueFrom         = x8
                , valueTo           = x9
                })
            <&> getStringNamed("EQUI")                  /// Equipment
            <*> getStringNamed("CLASSTYPE")             /// Class Type
            <*> getStringNamed("CHARID")                /// Characteristic ID
            <*> getStringNamed("ATWRT")                 /// Characteristic Value
            <*> optional(getInt32Named("ATCOD"))        /// Code
            <*> getStringNamed("TEXTBEZ")               /// Description
            <*> getInt32Named("VALCNT")                 /// Int counter values
            <*> getStringNamed("ATFLV")                 /// Value from
            <*> getStringNamed("ATFLB")                 /// Value to


    /// Write SQL
    pub def initValuaEquiTable(tableName: String): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, execute, setAutoCommit, commit};
        let* _      = setAutoCommit(false);
        let* _      = execute("DROP TABLE IF EXISTS ${tableName};");
        let* _      = execute(createTableValuaEquiRowSql(tableName));
        let* _      = commit();
        return()

    def dbWriteValuaEquiRows(tableName: String, dropTable: Bool, xs: List[ValuaEquiRow]): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, whenTrue, execute, prepareStatement, setAutoCommit, psExecuteUpdate, mapM, commit};
        let* _      = setAutoCommit(false);
        let* _      = whenTrue(dropTable, initValuaEquiTable(tableName));
        let* pstmt  = prepareStatement(insertValuaEquiRowSql(tableName));
        let* _      = mapM(x -> psExecuteUpdate(pstmt, setValuaEquiRowPStmt!(x)), xs);
        let* _      = commit();
        return()
    
    def setValuaEquiRowPStmt!(x: ValuaEquiRow): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!, putInt32At!, putOptionInt32At!};
        let* _ = putStringAt!(0,  x.equi);
        let* _ = putStringAt!(1,  x.classType);
        let* _ = putStringAt!(2,  x.charId);
        let* _ = putStringAt!(3,  x.charValue);
        let* _ = putOptionInt32At!(4,  x.code);
        let* _ = putStringAt!(5,  x.valueDescription);
        let* _ = putInt32At!(6,  x.intCounterValue);
        let* _ = putStringAt!(7,  x.valueFrom);
        let* _ = putStringAt!(8,  x.valueTo);
        return()




    def insertValuaEquiRowSql(tableName: String): String =
        "INSERT INTO ${tableName}"
            + " (equi, class_type, char_id, char_value, code, value_description, int_counter_value, value_from, value_to)"
            + " VALUES(?,?,?, ?,?,?, ?,?,?)"

    def createTableValuaEquiRowSql(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "equi                TEXT NOT NULL,"
                :: "class_type          TEXT NOT NULL,"
                :: "char_id             TEXT NOT NULL,"
                :: "char_value          TEXT,"
                :: "code                INTEGER,"
                :: "value_description   TEXT,"
                :: "int_counter_value   INTEGER NOT NULL,"
                :: "value_from          TEXT,"
                :: "value_to            TEXT"
                :: ")"
                :: Nil
        )


}