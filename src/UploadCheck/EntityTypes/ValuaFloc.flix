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

use FactIO/FlatFile.RowWithHeadersEvaluator;
use FactIO/FlatFile/RowWithHeadersEvaluator.{return, getString, getInt32};

use AssetLib/S4/FileIO/ChangeFile/Datatypes.{ChangeFile};

namespace UploadCheck/EntityTypes/ValuaFloc {


    type alias ValuaFlocRow = 
        { funcloc: String
        , classType: String
        , charId: String
        , charValue: String
        , code: Int32
        , valueDescription: String
        , intCounterValue: Int32
        , valueFrom: String
        , valueTo: String
        }

    type alias ValuaFlocFile = ChangeFile[ValuaFlocRow]

    /// Always UTF-8?
    pub def parseFile(path: String) : Result[ValuaFlocFile, System.Error] & Impure = 
        use Result.flatMap;
        let* ast = AssetLib/S4/FileIO/ChangeFile/Parser.parseFile(path);
        let* ans = AssetLib/S4/FileIO/ChangeFile/Evaluate.transform(evaluateRow(), ast);
        Ok(ans)

    // FUNCLOC	CLASSTYPE	CHARID	ATWRT	ATCOD	TEXTBEZ	VALCNT	ATFLV	ATFLB
    def evaluateRow(): RowWithHeadersEvaluator[ValuaFlocRow] = 
        use FactIO/FlatFile/RowWithHeadersEvaluator.{flatMap};
        let* funcloc        = getString("FUNCLOC");
        let* classType      = getString("CLASSTYPE");
        let* charId         = getString("CHARID");
        let* charValue      = getString("ATWRT");
        let* code           = getInt32("ATCOD");
        let* descr          = getString("TEXTBEZ");
        let* intCount       = getInt32("VALCNT");
        let* valueFrom      = getString("ATFLV");
        let* valueTo        = getString("ATFLB");
        return({  funcloc           = funcloc
                , classType         = classType
                , charId            = charId
                , charValue         = charValue
                , code              = code
                , valueDescription  = descr
                , intCounterValue   = intCount
                , valueFrom         = valueFrom
                , valueTo           = valueTo
            })

}