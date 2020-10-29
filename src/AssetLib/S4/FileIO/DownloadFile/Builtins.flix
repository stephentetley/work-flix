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



namespace AssetLib/S4/FileIO/DownloadFile/Builtins {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;

    use AssetLib/S4/FileIO/DownloadFile.RowEvaluator;
    
    /// CLASSFLOC

    type alias ClassFlocRow = 
        { funcloc: String
        , className: String
        , classType: String
        , status: Int32
        }


    /// EQMLTXT

    type alias EqmltxtRow = 
        { equi: String
        , shortText: String
        , langCode: String
        , longText: String
        , moreTextExists: Bool
        }

    pub def readEqmltxtRows(src: System.FilePath) : Result[List[EqmltxtRow], System.Error] & Impure = 
        AssetLib/S4/FileIO/DownloadFile/Evaluate.allRows(evalEqmltxtRow(), src)

    

    def evalEqmltxtRow(): RowEvaluator[EqmltxtRow] = 
        use AssetLib/S4/FileIO/DownloadFile/RowEvaluator.{getStringNamed, getS4BoolNamed};
        use AssetLib/S4/FileIO/DownloadFile/RowEvaluator.{<&>, <*>};
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
            



    /// CLASSEQUI

    type alias ClassEquiRow = 
        { equi: String
        , className: String
        , classType: String
        , internalClassNumber: String
        , status: Int32
        }

    pub def readClassEquiRows(src: System.FilePath) : Result[List[ClassEquiRow], System.Error] & Impure = 
        AssetLib/S4/FileIO/DownloadFile/Evaluate.allRows(evalClassEquiRow(), src)
            
    
    def evalClassEquiRow(): RowEvaluator[ClassEquiRow] = 
        use AssetLib/S4/FileIO/DownloadFile/RowEvaluator.{getStringNamed, getInt32Named};
        use AssetLib/S4/FileIO/DownloadFile/RowEvaluator.{<&>, <*>};
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
            <*> getInt32Named("CLSTATUS1")              /// Status


    /// VALUAEQUI


    type alias ValuaEquiRow = 
        { equi: String
        , classType: String
        , charId: String
        , charValue: String
        , code: Int32
        , valueDescription: String
        , intCounterValue: Int32
        , valueFrom: String
        , valueTo: String
        }

    /// Read

    pub def readValuaEquiRow(src: System.FilePath) : Result[List[ValuaEquiRow], System.Error] & Impure = 
        AssetLib/S4/FileIO/DownloadFile/Evaluate.allRows(evalValuaEquiRow(), src)

    def evalValuaEquiRow(): RowEvaluator[ValuaEquiRow] = 
        use AssetLib/S4/FileIO/DownloadFile/RowEvaluator.{getStringNamed, getInt32Named};
        use AssetLib/S4/FileIO/DownloadFile/RowEvaluator.{<&>, <*>};
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
            <*> getInt32Named("ATCOD")                  /// Code
            <*> getStringNamed("TEXTBEZ")               /// Description
            <*> getInt32Named("VALCNT")                 /// Int counter values
            <*> getStringNamed("ATFLV")                 /// Value from
            <*> getStringNamed("ATFLB")                 /// Value to


    /// Write SQL

    pub def dbWriteValuaEquiRows(tableName: String, dropTable: Bool, xs: List[ValuaEquiRow]): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, whenTrue, execute, prepareStatement, setAutoCommit, psExecuteUpdate, mapM, commit};
        let* _      = whenTrue(dropTable, execute("DROP TABLE IF EXISTS ${tableName};"));
        let* _      = whenTrue(dropTable, execute(createTableValuaEquiRowSql(tableName)));
        let* pstmt  = prepareStatement(insertValuaEquiRowSql(tableName));
        let* _      = setAutoCommit(false);
        let* _      = mapM(x -> psExecuteUpdate(pstmt, setValuaEquiRowPStmt!(x)), xs);
        let* _      = commit();
        return()
    
    def setValuaEquiRowPStmt!(x: ValuaEquiRow): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!, putInt32At!};
        let* _ = putStringAt!(0,  x.equi);
        let* _ = putStringAt!(1,  x.classType);
        let* _ = putStringAt!(2,  x.charId);
        let* _ = putStringAt!(3,  x.charValue);
        let* _ = putInt32At!(4,  x.code);
        let* _ = putStringAt!(5,  x.valueDescription);
        let* _ = putInt32At!(6,  x.intCounterValue);
        let* _ = putStringAt!(7,  x.valueFrom);
        let* _ = putStringAt!(8,  x.valueTo);
        return()




    def insertValuaEquiRowSql(tableName: String): String =
        "INSERT INTO ${tableName}"
            + " (equi, class_type, char_id, char_value, code, value_description, int_counter_value, int_counter_value, value_from, value_to)"
            + " VALUES(?,?,?, ?,?,?, ?,?,?)"

    def createTableValuaEquiRowSql(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "equi                TEXT NOT NULL,"
                :: "class_type          TEXT NOT NULL,"
                :: "char_id             TEXT NOT NULL,"
                :: "char_value          TEXT,"
                :: "code                INTEGER NOT NULL,"
                :: "value_description   TEXT,"
                :: "int_counter_value   INTEGER NOT NULL,"
                :: "value_from          TEXT,"
                :: "value_to            TEXT"
                :: ")"
                :: Nil
        )


}