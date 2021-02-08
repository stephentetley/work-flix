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

namespace Elaborator/CreateUploadFile {
    
    use BasicDb.DbMonad;
    
    use AssetLib/S4/FileIO/TransferFile/Builtins.{ValuaEquiRow};

    ///  type alias ValuaEquiRow = 
    ///     { equi: String
    ///     , classType: String
    ///     , charId: String
    ///     , charValue: String
    ///     , code: Option[Int32]
    ///     , valueDescription: String
    ///     , intCounterValue: Int32
    ///     , valueFrom: String
    ///     , valueTo: String
    ///     }
    
    pub def stringValuaEqui(x: {equiId: String, classType: String, charId: String, counter: Int32, value: String}): ValuaEquiRow = 
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

    /// def nextValuaEqui(equiId: String, charId: String, value: String): DbMonad[ValuaEquiRow] = 
    ///     use BasicDb/DbMonad.{flatMap, return};
    ///     let* pstmt  = Elaborator/GetValuaMax.prepareValuaEquiMaxQuery();    /// TODO - cache...
    ///     let* imax   = Elaborator/GetValuaMax.getValuaEquiMax({valuaEquiMax = pstmt}, equiId, charId);

    ///     stringValuaEqui(
    ///         { equiId    = equiId
    ///         , classType = "002"
    ///         , charId    = "AI2_AIB_REFERENCE"
    ///         })


    /// /// AI2_AIB_REFERENCE
    /// def addAi2AibReference(equiId: String, value: String): DbMonad[ValuaEquiRow] = 
    ///     stringValuaEqui(
    ///         { equiId    = equiId
    ///         , classType = "002"
    ///         , charId    = "AI2_AIB_REFERENCE"
    ///         })

}
