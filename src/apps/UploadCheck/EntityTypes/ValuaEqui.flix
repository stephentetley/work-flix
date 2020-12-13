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
use AssetLib/S4/FileIO/EntityFile/Datatypes.EntityData.{EntityData};
use AssetLib/S4/FileIO/EntityFile/Datatypes.DataRow.{DataRow};

namespace UploadCheck/EntityTypes/ValuaEqui {

    rel ValuaEqui( ix: Int32, equi: String, classType: String
                , charId: String, charValue: String, code: Int32
                , valueDescription: String, intCounterValue: Int32
                , valueFrom: String, valueTo: String )

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

    type alias ValuaEquiFile = ChangeData[ValuaEquiRow]

    /// Always UTF-8?
    pub def parseFile(path: System.FilePath) : Result[ValuaEquiFile, System.Error] & Impure = 
        use Result.flatMap;
        let* ast = AssetLib/S4/FileIO/ChangeFile/Parser.parseFile(path);
        let* ans = AssetLib/S4/FileIO/ChangeFile/Evaluate.transform(evaluateRow(), ast);
        Ok(ans)

    def evaluateRow(): RowWithHeadersParser[ValuaEquiRow] = 
        use TextParser/RowWithHeadersParser.{flatMap};
        let* equi           = getString("EQUI");
        let* classType      = getString("CLASSTYPE");
        let* charId         = getString("CHARID");
        let* charValue      = getString("ATWRT");
        let* code           = getInt32("ATCOD");
        let* descr          = getString("TEXTBEZ");
        let* intCount       = getInt32("VALCNT");
        let* valueFrom      = getString("ATFLV");
        let* valueTo        = getString("ATFLB");
        return({  equi              = equi
                , classType         = classType
                , charId            = charId
                , charValue         = charValue
                , code              = code
                , valueDescription  = descr
                , intCounterValue   = intCount
                , valueFrom         = valueFrom
                , valueTo           = valueTo
            })



    pub def makeValuaEqui[r](ix: Int32, row: ValuaEquiRow): #{ ValuaEqui | r } = #{
        ValuaEqui( ix
                , row.equi
                , row.classType
                , row.charId
                , row.charValue
                , row.code
                , row.valueDescription
                , row.intCounterValue
                , row.valueFrom
                , row.valueTo
                ).
    }

    pub def getRelations[r](src: ValuaEquiFile): #{ ValuaEqui | r } = 
        let ChangeFile(body) = src;
        let step = (ac, x) -> { 
            let (ix, db) = ac;
            let r1 = makeValuaEqui(ix, x);
            (ix + 1, db <+> r1)
        };
        let (_, rels) = List.foldLeft(step, (1, #{ }), body.dataRows);
        solve rels

}