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



namespace AssetLib/FileIO/S4/TransferFile/Builtins {

    use AssetLib/FileIO/S4/TransferFile/Datatypes.EntityType.{ClassFloc, ValuaFloc, ClassEqui, ValuaEqui};
    use AssetLib/FileIO/S4/TransferFile/Datatypes.{ClassFlocRow, ValuaFlocRow, ClassEquiRow, ValuaEquiRow};

    use AssetLib/FileIO/S4/TransferFile.DownloadRowEvaluator;
    use AssetLib/FileIO/S4/TransferFile.UploadRowSetter;



    /// Note - it doesn't make sense to have outputters for Funcloc and Equi files.
    /// An update will use a use-case specific subset of the columns.

    /// IFLOTX

    pub type alias IflotxRow = 
        { funcloc :: String
        , shortText :: String
        , langCode :: String
        , longText :: String
        , moreTextExists :: Bool
        }
    

    pub def readIflotxFile(src: System.FilePath) : Result[List[IflotxRow], String] & Impure = 
        AssetLib/FileIO/S4/TransferFile/DownloadReader.readAllRows(evalIflotxRow(), src)

    /// Read
    def evalIflotxRow(): DownloadRowEvaluator[IflotxRow] = 
        use AssetLib/FileIO/S4/TransferFile/DownloadRowEvaluator.{getStringNamed, getS4BoolNamed};
        use AssetLib/FileIO/S4/TransferFile/DownloadRowEvaluator.{<&>, <*>};
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
            

    /// CLASSEQUI


    pub def readClassFlocFile(src: System.FilePath) : Result[List[ClassFlocRow], String] & Impure = 
        AssetLib/FileIO/S4/TransferFile/DownloadReader.readAllRows(evalClassFlocRow(), src)
        

    def evalClassFlocRow(): DownloadRowEvaluator[ClassFlocRow] = 
        use AssetLib/FileIO/S4/TransferFile/DownloadRowEvaluator.{optional, getStringNamed, getInt32Named};
        use AssetLib/FileIO/S4/TransferFile/DownloadRowEvaluator.{<&>, <*>};
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


    /// Don't write "CLINT" (internalClassNumber)
    pub def writeClassFlocFile(user: String,
                                rows: List[ClassFlocRow], 
                                outpath: System.FilePath): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        use AssetLib/FileIO/S4/TransferFile/UploadWriter.{outputUploadFile, execMapUploadRowSetter};
        let headers = ["FUNCLOC", "CLASS", "CLASSTYPE", "CLSTATUS1"];
        let* rows2 = execMapUploadRowSetter(headers, classFlocSetRow!, rows);
        outputUploadFile(ClassFloc, None, user, headers, rows2, outpath)

    def classFlocSetRow!(x: ClassFlocRow): UploadRowSetter[Unit] = 
        use AssetLib/FileIO/S4/TransferFile/UploadRowSetter.{flatMap, return, putStringNamed!};
        let* _  = putStringNamed!("FUNCLOC",    x.funcloc);
        let* _  = putStringNamed!("CLASS",      x.className);
        let* _  = putStringNamed!("CLASSTYPE",  x.classType);
        let* _  = putStringNamed!("CLSTATUS1",  Option.getWithDefault(Option.map(ToString.toString, x.status), ""));
        return()


    /// VALUAFLOC



    pub def readValuaFlocFile(src: System.FilePath): Result[List[ValuaFlocRow], String] & Impure = 
        AssetLib/FileIO/S4/TransferFile/DownloadReader.readAllRows(evalValuaFlocRow(), src)


    def evalValuaFlocRow(): DownloadRowEvaluator[ValuaFlocRow] = 
        use AssetLib/FileIO/S4/TransferFile/DownloadRowEvaluator.{getStringNamed, getInt32Named, optional};
        use AssetLib/FileIO/S4/TransferFile/DownloadRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10) ->
                { funcloc           = x1
                , classType         = x2
                , charId            = x3
                , charValue         = x4
                , code              = x5
                , valueDescription  = x6
                , instanceCounter   = x7
                , intCounterValue   = x8
                , valueFrom         = x9
                , valueTo           = x10
                })
            <&> getStringNamed("FUNCLOC")               /// Functional Location
            <*> getStringNamed("CLASSTYPE")             /// Class Type
            <*> getStringNamed("CHARID")                /// Characteristic ID
            <*> getStringNamed("ATWRT")                 /// Characteristic Value
            <*> optional(getInt32Named("ATCOD"))        /// Code
            <*> getStringNamed("TEXTBEZ")               /// Description
            <*> getInt32Named("ATZIS")                  /// Instance counter
            <*> getInt32Named("VALCNT")                 /// Int counter values
            <*> getStringNamed("ATFLV")                 /// Value from
            <*> getStringNamed("ATFLB")                 /// Value to




    pub def writeValuaFlocFile(user: String,
                                rows: List[ValuaFlocRow], 
                                outpath: System.FilePath): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        use AssetLib/FileIO/S4/TransferFile/UploadWriter.{outputUploadFile, execMapUploadRowSetter};
        let headers = ["FUNCLOC", "CLASSTYPE", "CHARID", "ATWRT", "ATCOD", "TEXTBEZ", "ATZIS", "VALCNT", "ATFLV", "ATFLB"];
        let* rows2 = execMapUploadRowSetter(headers, valuaFlocSetRow!, rows);
        outputUploadFile(ValuaFloc, None, user, headers, rows2, outpath)

    def valuaFlocSetRow!(x: ValuaFlocRow): UploadRowSetter[Unit] = 
        use AssetLib/FileIO/S4/TransferFile/UploadRowSetter.{flatMap, return, putStringNamed!, 
            putInt32Named!, putPaddedInt32Named!};
        let* _  = putStringNamed!("FUNCLOC",    x.funcloc);
        let* _  = putStringNamed!("CLASSTYPE",  x.classType);
        let* _  = putStringNamed!("CHARID",     x.charId);
        let* _  = putStringNamed!("ATWRT",      x.charValue);
        let* _  = putStringNamed!("ATCOD",      Option.getWithDefault(Option.map(ToString.toString, x.code), ""));
        let* _  = putStringNamed!("TEXTBEZ",    x.valueDescription);
        let* _  = putPaddedInt32Named!("ATZIS", 3, x.instanceCounter);
        let* _  = putPaddedInt32Named!("VALCNT", 4, x.intCounterValue);
        let* _  = putStringNamed!("ATFLV",      x.valueFrom);
        let* _  = putStringNamed!("ATFLB",      x.valueTo);
        return()   



    /// EQMLTXT

    pub type alias EqmltxtRow = 
        { equi :: String
        , shortText :: String
        , langCode :: String
        , longText :: String
        , moreTextExists :: Bool
        }
    

    pub def readEqmltxtFile(src: System.FilePath): Result[List[EqmltxtRow], String] & Impure = 
        AssetLib/FileIO/S4/TransferFile/DownloadReader.readAllRows(evalEqmltxtRow(), src)
        

    /// Read
    def evalEqmltxtRow(): DownloadRowEvaluator[EqmltxtRow] = 
        use AssetLib/FileIO/S4/TransferFile/DownloadRowEvaluator.{getStringNamed, getS4BoolNamed};
        use AssetLib/FileIO/S4/TransferFile/DownloadRowEvaluator.{<&>, <*>};
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



    pub def readClassEquiFile(src: System.FilePath): Result[List[ClassEquiRow], String] & Impure = 
        AssetLib/FileIO/S4/TransferFile/DownloadReader.readAllRows(evalClassEquiRow(), src)
    
    def evalClassEquiRow(): DownloadRowEvaluator[ClassEquiRow] = 
        use AssetLib/FileIO/S4/TransferFile/DownloadRowEvaluator.{optional, getStringNamed, getInt32Named};
        use AssetLib/FileIO/S4/TransferFile/DownloadRowEvaluator.{<&>, <*>};
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


    /// Don't write "CLINT" (internalClassNumber)
    pub def writeClassEquiFile(user: String,
                                rows: List[ClassEquiRow], 
                                outpath: System.FilePath): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        use AssetLib/FileIO/S4/TransferFile/UploadWriter.{outputUploadFile, execMapUploadRowSetter};
        let headers = ["EQUI", "CLASS", "CLASSTYPE", "CLSTATUS1"];
        let* rows2 = execMapUploadRowSetter(headers, classEquiSetRow!, rows);
        outputUploadFile(ClassEqui, None, user, headers, rows2, outpath)

    def classEquiSetRow!(x: ClassEquiRow): UploadRowSetter[Unit] = 
        use AssetLib/FileIO/S4/TransferFile/UploadRowSetter.{flatMap, return, putStringNamed!};
        let* _  = putStringNamed!("EQUI",       x.equi);
        let* _  = putStringNamed!("CLASS",  x.className);
        let* _  = putStringNamed!("CLASSTYPE",  x.classType);
        let* _  = putStringNamed!("CLSTATUS1",      Option.getWithDefault(Option.map(ToString.toString, x.status), ""));
        return()

    /// VALUAEQUI



    pub def readValuaEquiFile(path: System.FilePath) : Result[List[ValuaEquiRow], String] & Impure =         
        AssetLib/FileIO/S4/TransferFile/DownloadReader.readAllRows(evalValuaEquiRow(), path)
        
    /// Read
    def evalValuaEquiRow(): DownloadRowEvaluator[ValuaEquiRow] = 
        use AssetLib/FileIO/S4/TransferFile/DownloadRowEvaluator.{optional, getStringNamed, getInt32Named};
        use AssetLib/FileIO/S4/TransferFile/DownloadRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10) ->
                { equi              = x1
                , classType         = x2
                , charId            = x3
                , charValue         = x4
                , code              = x5
                , valueDescription  = x6
                , instanceCounter   = x7
                , intCounterValue   = x8
                , valueFrom         = x9
                , valueTo           = x10
                })
            <&> getStringNamed("EQUI")                  /// Equipment
            <*> getStringNamed("CLASSTYPE")             /// Class Type
            <*> getStringNamed("CHARID")                /// Characteristic ID
            <*> getStringNamed("ATWRT")                 /// Characteristic Value
            <*> optional(getInt32Named("ATCOD"))        /// Code
            <*> getStringNamed("TEXTBEZ")               /// Description
            <*> getInt32Named("ATZIS")                  /// Instance counter
            <*> getInt32Named("VALCNT")                 /// Int counter values
            <*> getStringNamed("ATFLV")                 /// Value from
            <*> getStringNamed("ATFLB")                 /// Value to



    pub def writeValuaEquiFile(user: String,
                                rows: List[ValuaEquiRow], 
                                outpath: System.FilePath): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        use AssetLib/FileIO/S4/TransferFile/UploadWriter.{outputUploadFile, execMapUploadRowSetter};
        let headers = ["EQUI", "CLASSTYPE", "CHARID", "ATWRT", "ATCOD", "TEXTBEZ", "ATZIS", "VALCNT","ATFLV", "ATFLB"];
        let* rows2 = execMapUploadRowSetter(headers, valuaEquiSetRow!, rows);
        outputUploadFile(ValuaEqui, None, user, headers, rows2, outpath)

    def valuaEquiSetRow!(x: ValuaEquiRow): UploadRowSetter[Unit] = 
        use AssetLib/FileIO/S4/TransferFile/UploadRowSetter.{flatMap, return, putStringNamed!, 
            putInt32Named!, putPaddedInt32Named!};
        let* _  = putStringNamed!("EQUI",       x.equi);
        let* _  = putStringNamed!("CLASSTYPE",  x.classType);
        let* _  = putStringNamed!("CHARID",     x.charId);
        let* _  = putStringNamed!("ATWRT",      x.charValue);
        let* _  = putStringNamed!("ATCOD",      Option.getWithDefault(Option.map(ToString.toString, x.code), ""));
        let* _  = putStringNamed!("TEXTBEZ",    x.valueDescription);
        let* _  = putPaddedInt32Named!("ATZIS", 3, x.instanceCounter);
        let* _  = putPaddedInt32Named!("VALCNT", 4, x.intCounterValue);
        let* _  = putStringNamed!("ATFLV",      x.valueFrom);
        let* _  = putStringNamed!("ATFLB",      x.valueTo);
        return()    

}
