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

    use Functor.{<$>};
    use Applicative.{<*>};

    use FlixSandbox/System.FilePath;

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
    

    pub def readIflotxFile(src: FilePath) : Result[List[IflotxRow], String] & Impure = 
        region r {
            AssetLib/FileIO/S4/TransferFile/DownloadReader.readAllRows(r, evalIflotxRow(), src)
        }            

    /// Read
    def evalIflotxRow(): DownloadRowEvaluator[r, IflotxRow] \ { Read(r) } = 
        use AssetLib/FileIO/S4/TransferFile/DownloadRowEvaluator.{getStringNamed, getS4BoolNamed};
        ((x1, x2, x3, x4, x5) ->
                { funcloc           = x1
                , shortText         = x2
                , langCode          = x3
                , longText          = x4
                , moreTextExists    = x5
            })
            <$> getStringNamed("EQUI")
            <*> getStringNamed("PLTXT")
            <*> getStringNamed("LANGUCODE")
            <*> getStringNamed("FL_LTXT")
            <*> getS4BoolNamed("KZMLA")
            

    /// CLASSEQUI


    pub def readClassFlocFile(src: FilePath) : Result[List[ClassFlocRow], String] & Impure = 
        region r {
            AssetLib/FileIO/S4/TransferFile/DownloadReader.readAllRows(r, evalClassFlocRow(), src)
        }
        

    def evalClassFlocRow(): DownloadRowEvaluator[r, ClassFlocRow] \ { Read(r) } = 
        use AssetLib/FileIO/S4/TransferFile/DownloadRowEvaluator.{optional, getStringNamed, getInt32Named};
        ((x1, x2, x3, x4, x5) ->
                { funcloc               = x1
                , className             = x2
                , classType             = x3
                , internalClassNumber   = x4
                , status                = x5
                })
            <$> getStringNamed("FUNCLOC")               /// Functional Location
            <*> getStringNamed("CLASS")                 /// Class 
            <*> getStringNamed("CLASSTYPE")             /// Class Type
            <*> getStringNamed("CLINT")                 /// Internal class no
            <*> optional(getInt32Named("CLSTATUS1"))             /// Status

    /// VALUAFLOC



    pub def readValuaFlocFile(src: FilePath): Result[List[ValuaFlocRow], String] & Impure = 
        region r {
            AssetLib/FileIO/S4/TransferFile/DownloadReader.readAllRows(r, evalValuaFlocRow(), src)
        }


    def evalValuaFlocRow(): DownloadRowEvaluator[r, ValuaFlocRow] \ { Read(r) } = 
        use AssetLib/FileIO/S4/TransferFile/DownloadRowEvaluator.{getStringNamed, getInt32Named, optional};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11) ->
                { funcloc           = x1
                , classType         = x2
                , charId            = x3
                , charValue         = x4
                , code              = x5
                , valueDescription  = x6
                , instanceCounter   = x7
                , intCounterValue   = x8
                , position          = x9
                , valueFrom         = x10
                , valueTo           = x11
                })
            <$> getStringNamed("FUNCLOC")               /// Functional Location
            <*> getStringNamed("CLASSTYPE")             /// Class Type
            <*> getStringNamed("CHARID")                /// Characteristic ID
            <*> getStringNamed("ATWRT")                 /// Characteristic Value
            <*> optional(getInt32Named("ATCOD"))        /// Code
            <*> getStringNamed("TEXTBEZ")               /// Description
            <*> getInt32Named("ATZIS")                  /// Instance counter
            <*> getInt32Named("VALCNT")                 /// Int counter values
            <*> getStringNamed("ATSRT")                 /// Position
            <*> getStringNamed("ATFLV")                 /// Value from
            <*> getStringNamed("ATFLB")                 /// Value to


    /// EQMLTXT

    pub type alias EqmltxtRow = 
        { equi :: String
        , shortText :: String
        , langCode :: String
        , longText :: String
        , moreTextExists :: Bool
        }
    

    pub def readEqmltxtFile(src: FilePath): Result[List[EqmltxtRow], String] & Impure  = 
        region r {
            AssetLib/FileIO/S4/TransferFile/DownloadReader.readAllRows(r, evalEqmltxtRow(), src)
        }
        

    /// Read
    def evalEqmltxtRow(): DownloadRowEvaluator[r, EqmltxtRow] \ { Read(r) } = 
        use AssetLib/FileIO/S4/TransferFile/DownloadRowEvaluator.{getStringNamed, getS4BoolNamed};
        ((x1, x2, x3, x4, x5) ->
                { equi              = x1
                , shortText         = x2
                , langCode          = x3
                , longText          = x4
                , moreTextExists    = x5
            })
            <$> getStringNamed("EQUI")
            <*> getStringNamed("SHORTXT")
            <*> getStringNamed("LANGUCODE")
            <*> getStringNamed("EQ_LTXT")
            <*> getS4BoolNamed("LTXTIND")
            


    /// CLASSEQUI



    pub def readClassEquiFile(src: FilePath): Result[List[ClassEquiRow], String] & Impure = 
        region r {
            AssetLib/FileIO/S4/TransferFile/DownloadReader.readAllRows(r, evalClassEquiRow(), src)
        }
    
    def evalClassEquiRow(): DownloadRowEvaluator[r, ClassEquiRow] \ { Read(r) } = 
        use AssetLib/FileIO/S4/TransferFile/DownloadRowEvaluator.{optional, getStringNamed, getInt32Named};
        ((x1, x2, x3, x4, x5) ->
                { equi                  = x1
                , className             = x2
                , classType             = x3
                , internalClassNumber   = x4
                , status                = x5
                })
            <$> getStringNamed("EQUI")                  /// Equipment
            <*> getStringNamed("CLASS")                 /// Class 
            <*> getStringNamed("CLASSTYPE")             /// Class Type
            <*> getStringNamed("CLINT")                 /// Internal class no
            <*> optional(getInt32Named("CLSTATUS1"))              /// Status


    /// VALUAEQUI

    pub def readValuaEquiFile(path: FilePath) : Result[List[ValuaEquiRow], String] & Impure =
        region r {
            AssetLib/FileIO/S4/TransferFile/DownloadReader.readAllRows(r, evalValuaEquiRow(), path)
        }

    /// Read
    def evalValuaEquiRow(): DownloadRowEvaluator[r, ValuaEquiRow] \ { Read(r) }= 
        use AssetLib/FileIO/S4/TransferFile/DownloadRowEvaluator.{optional, getStringNamed, getInt32Named};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11) ->
                { equi              = x1
                , classType         = x2
                , charId            = x3
                , charValue         = x4
                , code              = x5
                , valueDescription  = x6
                , instanceCounter   = x7
                , intCounterValue   = x8
                , position          = x9
                , valueFrom         = x10
                , valueTo           = x11
                })
            <$> getStringNamed("EQUI")                  /// Equipment
            <*> getStringNamed("CLASSTYPE")             /// Class Type
            <*> getStringNamed("CHARID")                /// Characteristic ID
            <*> getStringNamed("ATWRT")                 /// Characteristic Value
            <*> optional(getInt32Named("ATCOD"))        /// Code
            <*> getStringNamed("TEXTBEZ")               /// Description
            <*> getInt32Named("ATZIS")                  /// Instance counter
            <*> getInt32Named("VALCNT")                 /// Int counter values
            <*> getStringNamed("ATSRT")                 /// Position
            <*> getStringNamed("ATFLV")                 /// Value from
            <*> getStringNamed("ATFLB")                 /// Value to


}
