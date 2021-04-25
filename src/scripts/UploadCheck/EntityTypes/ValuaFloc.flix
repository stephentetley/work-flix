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

use AssetLib/FileIO/S4/EntityFile/Datatypes.{EntityData};
use AssetLib/FileIO/S4/EntityFile/Datatypes.EntityData.{EntityData};
use AssetLib/FileIO/S4/EntityFile/Datatypes.DataRow.{DataRow};

namespace UploadCheck/EntityTypes/ValuaFloc {

    /// relations are record + index so we can identify them

    rel ValuaFloc( ix: Int32, funcloc: String, classType: String
                , charId: String, charValue: String, code: Int32
                , valueDescription: String, intCounterValue: Int32
                , valueFrom: String, valueTo: String )


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

    type alias ValuaFlocFile = EntityData[ValuaFlocRow]

    /// Always UTF-8?
    pub def parseFile(path: System.FilePath) : Result[ValuaFlocFile, System.Error] & Impure = 
        use Result.flatMap;
        let* ast = AssetLib/FileIO/S4/ChangeFile/Parser.parseFile(path);
        let* ans = AssetLib/FileIO/S4/ChangeFile/Evaluate.transform(evaluateRow(), ast);
        Ok(ans)

    // FUNCLOC	CLASSTYPE	CHARID	ATWRT	ATCOD	TEXTBEZ	VALCNT	ATFLV	ATFLB
    def evaluateRow(): RowWithHeadersParser[ValuaFlocRow] = 
        use TextParser/RowWithHeadersParser.{flatMap};
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


    def makeValuaFloc[r](ix: Int32, row: ValuaFlocRow): #{ ValuaFloc | r } = 
        ValuaFloc( ix
                , row.funcloc
                , row.classType
                , row.charId
                , row.charValue
                , row.code
                , row.valueDescription
                , row.intCounterValue
                , row.valueFrom
                , row.valueTo
                ).

    pub def getRelations[r](src: ValuaFlocFile): #{ ValuaFloc | r } = 
        let ChangeFile(body) = src;
        let step = (ac, x) -> { 
            let (ix, db) = ac;
            let r1 = makeValuaFloc(ix, x);
            (ix + 1, db <+> r1)
        };
        let (_, rels) = List.foldLeft(step, (1, #{ }), body.dataRows);
        solve rels


}