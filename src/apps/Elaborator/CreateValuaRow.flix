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

namespace Elaborator/CreateUploadRow {
    
    use Elaborator.ElaborateMonad;
    
    use AssetLib/S4/FileIO/TransferFile/Builtins.{ValuaFlocRow, ValuaEquiRow};

    /// ValuaFloc

    pub def nextStringValuaFloc(funcloc: String, charId: String, value: String): ElaborateMonad[ValuaFlocRow] = 
        use Elaborator/ElaborateMonad.{flatMap, return, nextValuaFlocCounter};
        let* imax   = nextValuaFlocCounter(funcloc, charId);
        return(stringValuaFloc(
                    { funcloc   = funcloc
                    , classType = "003"
                    , charId    = charId
                    , counter   = imax
                    , value     = value
                    }))

    
    def stringValuaFloc(x: {funcloc: String, classType: String, charId: String, counter: Int32, value: String}): ValuaFlocRow = 
        { funcloc           = x.funcloc
        , classType         = x.classType
        , charId            = x.charId
        , charValue         = x.value
        , code              = Some(1)
        , valueDescription  = x.value
        , intCounterValue   = x.counter
        , valueFrom         = ""
        , valueTo           = ""
        }

    pub def nextIntValuaFloc(funcloc: String, charId: String, value: Int32): ElaborateMonad[ValuaFlocRow] = 
        use Elaborator/ElaborateMonad.{flatMap, return, nextValuaFlocCounter};
        let* imax   = nextValuaFlocCounter(funcloc, charId);
        return(intValuaFloc(
                    { funcloc   = funcloc
                    , classType = "002"
                    , charId    = charId
                    , counter   = imax
                    , value     = value
                    }))

    
    def intValuaFloc(x: {funcloc: String, classType: String, charId: String, counter: Int32, value: Int32}): ValuaFlocRow = 
        { funcloc           = x.funcloc
        , classType         = x.classType
        , charId            = x.charId
        , charValue         = ""
        , code              = Some(1)
        , valueDescription  = Int32.toString(x.value)
        , intCounterValue   = x.counter
        , valueFrom         = Int32.toString(x.value)
        , valueTo           = "0"
        }

    pub def nextFloat64ValuaFloc(funcloc: String, charId: String, value: Float64): ElaborateMonad[ValuaFlocRow] = 
        use Elaborator/ElaborateMonad.{flatMap, return, nextValuaFlocCounter};
        let* imax   = nextValuaFlocCounter(funcloc, charId);
        return(float64ValuaFloc(
                    { funcloc   = funcloc
                    , classType = "002"
                    , charId    = charId
                    , counter   = imax
                    , value     = value
                    }))

    def float64ValuaFloc(x: { funcloc: String, classType: String, charId: String, counter: Int32, value: Float64}): ValuaFlocRow = 
        { funcloc           = x.funcloc
        , classType         = x.classType
        , charId            = x.charId
        , charValue         = ""
        , code              = Some(1)
        , valueDescription  = toDecimalString(2, x.value)
        , intCounterValue   = x.counter
        , valueFrom         = toDecimalString(2, x.value)
        , valueTo           = "0"
        }


    /// ValuaEqui

    pub def nextStringValuaEqui(equiId: String, charId: String, value: String): ElaborateMonad[ValuaEquiRow] = 
        use Elaborator/ElaborateMonad.{flatMap, return, nextValuaEquiCounter};
        let* imax   = nextValuaEquiCounter(equiId, charId);
        return(stringValuaEqui(
                    { equiId    = equiId
                    , classType = "002"
                    , charId    = charId
                    , counter   = imax
                    , value     = value
                    }))

    
    def stringValuaEqui(x: {equiId: String, classType: String, charId: String, counter: Int32, value: String}): ValuaEquiRow = 
        { equi = x.equiId
        , classType = x.classType
        , charId = x.charId
        , charValue = x.value
        , code = Some(1)
        , valueDescription = x.value
        , intCounterValue = x.counter
        , valueFrom = ""
        , valueTo = ""
        }


    pub def nextIntValuaEqui(equiId: String, charId: String, value: Int32): ElaborateMonad[ValuaEquiRow] = 
        use Elaborator/ElaborateMonad.{flatMap, return, nextValuaEquiCounter};
        let* imax   = nextValuaEquiCounter(equiId, charId);
        return(intValuaEqui(
                    { equiId    = equiId
                    , classType = "002"
                    , charId    = charId
                    , counter   = imax
                    , value     = value
                    }))

    
    def intValuaEqui(x: {equiId: String, classType: String, charId: String, counter: Int32, value: Int32}): ValuaEquiRow = 
        { equi = x.equiId
        , classType = x.classType
        , charId = x.charId
        , charValue = ""
        , code = Some(1)
        , valueDescription = Int32.toString(x.value)
        , intCounterValue = x.counter
        , valueFrom = Int32.toString(x.value)
        , valueTo = "0"
        }


    pub def nextFloat64ValuaEqui(equiId: String, charId: String, value: Float64): ElaborateMonad[ValuaEquiRow] = 
        use Elaborator/ElaborateMonad.{flatMap, return, nextValuaEquiCounter};
        let* imax   = nextValuaEquiCounter(equiId, charId);
        return(float64ValuaEqui(
                    { equiId    = equiId
                    , classType = "002"
                    , charId    = charId
                    , counter   = imax
                    , value     = value
                    }))

    def float64ValuaEqui(x: { equiId: String, classType: String, charId: String, counter: Int32, value: Float64}): ValuaEquiRow = 
        { equi = x.equiId
        , classType = x.classType
        , charId = x.charId
        , charValue = ""
        , code = Some(1)
        , valueDescription = toDecimalString(2, x.value)        /// We need TEXTBEZ and ATFLV!
        , intCounterValue = x.counter
        , valueFrom = toDecimalString(2, x.value)
        , valueTo = "0"
        }

    ///
    /// Return a decimal representation of `x`.
    ///
    pub def toDecimalString(decimalPlaces: Int32, x: Float64): String =
        toDecimalStringHelper(decimalPlaces, x) as & Pure

    ///
    /// Helper function for `toDecimalString`.
    ///
    def toDecimalStringHelper(decimalPlaces: Int32, x: Float64): String & Impure =
        import new java.text.DecimalFormat() as newDecimalFormat;
        import java.text.DecimalFormat.applyPattern(String);
        import java.text.DecimalFormat.setMinimumFractionDigits(Int32);
        import java.text.NumberFormat.format(Float64);
        let df = newDecimalFormat();
        df.applyPattern("###.###");
        df.setMinimumFractionDigits(decimalPlaces);
        let nf = df as ##java.text.NumberFormat;
        nf.format(x)

}
