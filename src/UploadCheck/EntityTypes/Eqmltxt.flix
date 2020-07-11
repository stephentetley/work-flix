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
use FactIO/FlatFile/RowWithHeadersEvaluator.{return, getString, getInt32, map};

use AssetLib/S4/FileIO/ChangeFile/Datatypes.{ChangeFile};

namespace UploadCheck/EntityTypes/Eqmltxt {

    

    type alias EqmltxtRow = 
        { equi: String
        , shortText: String
        , langCode: String
        , longText: String
        , moreTextExists: Bool
        }

    type alias EqmltxtFile = ChangeFile[EqmltxtRow]

    /// Always UTF-8?
    pub def parseFile(path: String) : Result[EqmltxtFile, System.Error] & Impure = 
        use Result.flatMap;
        let* ast = AssetLib/S4/FileIO/ChangeFile/Parser.parseFile(path);
        let* ans = AssetLib/S4/FileIO/ChangeFile/Evaluate.transform(evaluateRow(), ast);
        Ok(ans)

    

    def evaluateRow(): RowWithHeadersEvaluator[EqmltxtRow] = 
        use FactIO/FlatFile/RowWithHeadersEvaluator.{flatMap};
        let* equi           = getString("EQUI");
        let* shortText      = getString("SHORTXT");
        let* langCode       = getString("LANGUCODE");
        let* longText       = getString("EQ_LTXT");
        let* moreTextExists = getString("LTXTIND") |> map(readBool);
        return({  equi              = equi
                , shortText         = shortText
                , langCode          = langCode
                , longText          = longText
                , moreTextExists    = moreTextExists
            })

    def readBool(x: String): Bool = match x { 
        case ""     => false
        case "X"    => true
        case _      => false
    }

}