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

use TextParser.RowWithHeadersParser;
use TextParser/RowWithHeadersParser.{return, getString, getInt32};

use AssetLib/S4/FileIO/EntityFile/Datatypes.{EntityData};

namespace UploadCheck/EntityTypes/ClassFloc {


    
    type alias ClassFlocRow = 
        { funcloc: String
        , className: String
        , classType: String
        , status: Int32
        }

    type alias ClassFlocFile = EntityData[ClassFlocRow]

    /// Always UTF-8?
    pub def parseFile(path: System.FilePath) : Result[ClassFlocFile, System.Error] & Impure = 
        use Result.flatMap;
        let* ast = AssetLib/S4/FileIO/ChangeFile/Parser.parseFile(path);
        let* ans = AssetLib/S4/FileIO/ChangeFile/Evaluate.transform(evaluateRow(), ast);
        Ok(ans)

    // *FUNCLOC	CLASS	CLASSTYPE	CLSTATUS1
    def evaluateRow(): RowWithHeadersParser[ClassFlocRow] = 
        use TextParser/RowWithHeadersParser.{flatMap};
        let* funcloc            = getString("FUNCLOC");
        let* className          = getString("CLASS");
        let* classType          = getString("CLASSTYPE");
        let* status             = getInt32("CLSTATUS1");
        return({  funcloc           = funcloc
                , className         = className
                , classType         = classType
                , status            = status
            })

}