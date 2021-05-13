/*
 * Copyright 2021 Stephen Tetley
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


namespace AssetLib/GenS4/UploadRelations {

    use AssetLib/FileIO/S4/TransferFile/Datatypes.{ClassEquiRow, ValuaEquiRow};


    pub rel ClassEqui(equiId: String,
                        className: String,
                        classType: String)      /// Always "002"?

    pub rel ValuaEquiString(equiId: String,
                        classType: String,
                        characteristicId: String, 
                        stringValue: String,
                        intCounterValue: Int32)

    pub rel ValuaEquiInt(equiId: String,
                        classType: String,
                        characteristicId: String, 
                        intValue: Int32,
                        intCounterValue: Int32)

    pub rel ValuaEquiFloat(equiId: String,
                        classType: String,
                        characteristicId: String, 
                        floatValue: Float64,
                        intCounterValue: Int32)



    /// To Upload row...
    pub def toClassEquiRow(src: #{ClassEqui | r}): List[ClassEquiRow] = 
        let buildStep = (x, ac) -> classEquiToUpload(x) :: ac;
        fold ClassEqui Nil buildStep src


    def classEquiToUpload(x: (String, String, String)): ClassEquiRow = 
        let (x1, x2, x3) = x;
        { equi                  = x1
        , className             = x2
        , classType             = x3
        , internalClassNumber   = ""
        , status                = Some(1)
        }


    /// To Upload row...
    pub def textToValuaEquiRow(src: #{ValuaEquiString | r}): List[ValuaEquiRow] = 
        let buildStep = (x, ac) -> valuaEquiTextToUpload(x) :: ac;
        fold ValuaEquiString Nil buildStep src


    def valuaEquiTextToUpload(x: (String, String, String, String, Int32)): ValuaEquiRow = 
        let (x1, x2, x3, x4, x5) = x;
        { equi              = x1
        , classType         = x2
        , charId            = x3
        , charValue         = x4
        , code              = Some(1)
        , valueDescription  = x4
        , instanceCounter   = x5 - 1
        , intCounterValue   = x5
        , valueFrom         = "0"
        , valueTo           = "0"
        }

    pub def intToValuaEquiRow(src: #{ValuaEquiInt | r}): List[ValuaEquiRow] = 
        let buildStep = (x, ac) -> valuaEquiIntToUpload(x) :: ac;
        fold ValuaEquiInt Nil buildStep src


    def valuaEquiIntToUpload(x: (String, String, String, Int32, Int32)): ValuaEquiRow = 
        let (x1, x2, x3, x4, x5) = x;
        { equi              = x1
        , classType         = x2
        , charId            = x3
        , charValue         = ""
        , code              = Some(1)
        , valueDescription  = ToString.toString(x4)
        , instanceCounter   = x5 - 1
        , intCounterValue   = x5
        , valueFrom         = ToString.toString(x4)
        , valueTo           = "0"
        }

    pub def floatToValuaEquiRow(src: #{ValuaEquiFloat | r}): List[ValuaEquiRow] = 
        let buildStep = (x, ac) -> valuaEquiFloatToUpload(x) :: ac;
        fold ValuaEquiFloat Nil buildStep src


    def valuaEquiFloatToUpload(x: (String, String, String, Float64, Int32)): ValuaEquiRow = 
        let (x1, x2, x3, x4, x5) = x;
        { equi              = x1
        , classType         = x2
        , charId            = x3
        , charValue         = ""
        , code              = Some(1)
        , valueDescription  = Text/NumberFormatter.formatFloat64(4, x4)
        , instanceCounter   = x5 - 1
        , intCounterValue   = x5
        , valueFrom         = Text/NumberFormatter.formatFloat64(4, x4)
        , valueTo           = "0"
        }


}
