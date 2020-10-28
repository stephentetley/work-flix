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

    use AssetLib/S4/FileIO/DownloadFile.RowEvaluator;
    

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

}