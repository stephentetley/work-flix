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

use Data.Check.{Pass};
use Data/Check.{failure};

use BasicDb.DbMonad;
use BasicDb/DbMonad.{prepareStatement, psExecuteQuery, firstRow, rsClose};
use BasicDb.PreparedStatementSetter;

use AssetLib/S4/FileIO/UxlCsv/Datatypes.{EqClassification, FlocClassification};
use UploadCheck/Base/RowCheck.{RowCheck, RowChecker};
use UploadCheck/Base/RowCheck.RowChecker.{RowChecker};

namespace UploadCheck/SqlCheckers/SelectionValueCheck {

    pub def flocSelectionValue(): RowChecker[FlocClassification] = 
        RowChecker((row, ix) -> 
            let errMsg = "flocSelectionValue failed - `${row.charValue}` not in list of values for ${row.characteristicName}";
            BasicDb/DbMonad.map(x -> if (x) Pass else failure({ rowIndex = ix, failMessage = errMsg }), 
                                flocSelectionValueHelper(row.characteristicName, row.charValue))
        )

    def flocSelectionValueHelper(charname: String, value: String): DbMonad[Bool] = 
        use BasicDb/DbMonad.{return, flatMap};
        let* a1 = isRestricted("floc", charname);
        if (a1) isRestrictedValue("floc", charname, value) else return(true) 

    pub def equiSelectionValue(): RowChecker[EqClassification] = 
        RowChecker((row, ix) -> 
            let errMsg = "equiSelectionValue failed - `${row.charValue}` not in list of values for ${row.characteristicName}";
            BasicDb/DbMonad.map(x -> if (x) Pass else failure({ rowIndex = ix, failMessage = errMsg }), 
                                equiSelectionValueHelper(row.characteristicName, row.charValue))
        )

    pub def equiSelectionValueHelper(charname: String, value: String): DbMonad[Bool] = 
        use BasicDb/DbMonad.{return, flatMap};
        let* a1 = isRestricted("equi", charname);
        if (a1) isRestrictedValue("equi", charname, value) else return(true) 

    def isRestricted(prefix: String, charname: String): DbMonad[Bool] = 
        use BasicDb/DbMonad.{flatMap, return};
        let* pstmt  = prepareStatement("SELECT COUNT(value) FROM ${prefix}_selection_values WHERE charname = ?;");
        let* rs     = psExecuteQuery(pstmt, BasicDb/PreparedStatementSetter.putString!(0,  charname));
        let* n      = firstRow(rs, BasicDb/RowEvaluator.getInt32(0));
        let* _      = rsClose(rs);
        return(n > 0)


    def isRestrictedValue(prefix: String, charname: String, value: String): DbMonad[Bool] = 
        use BasicDb/DbMonad.{flatMap, return};
        let* pstmt  = prepareStatement("SELECT COUNT(value) FROM ${prefix}_selection_values WHERE charname = ? AND value = ?;");
        let* rs     = psExecuteQuery(pstmt, restrictedValueSetter(charname, value));
        let* n      = firstRow(rs, BasicDb/RowEvaluator.getInt32(0));
        let* _      = rsClose(rs);
        return(n > 0)

    def restrictedValueSetter(charname: String, value: String):PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{return, flatMap, putString!};
        let* _ = putString!(0,  charname);
        let* _ = putString!(1,  value);
        return()

}