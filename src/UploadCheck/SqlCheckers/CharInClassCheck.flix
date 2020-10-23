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
use BasicDb.RowEvaluator;

use AssetLib/S4/FileIO/UxlFile/Datatypes.{EqClassification, FlClassification};
use UploadCheck/Base/RowCheck.{RowCheck, RowChecker};
use UploadCheck/Base/RowCheck.RowChecker.{RowChecker};

namespace UploadCheck/SqlCheckers/CharInClassCheck {

    
    pub def flocCharInClass(): RowChecker[FlClassification] = 
        RowChecker((row, ix) -> 
            let errMsg = "${row.functionalLocation} - flocCharInClass failed - ${row.characteristicName} not in class ${row.className}";
            BasicDb/DbMonad.map(x -> if (x) Pass else failure({sheetName = "Fl-Classification", rowIndex = ix, failMessage = errMsg}),
                                charInClassHelper("floc", row.characteristicName, row.className))
        )

    pub def equiCharInClass(): RowChecker[EqClassification] = 
        RowChecker((row, ix) -> 
            let errMsg = "${row.equiId} - equiCharInClass failed - ${row.characteristicName} not in class ${row.className}";
            BasicDb/DbMonad.map(x -> if (x) Pass else failure({sheetName = "Eq-Classification", rowIndex = ix, failMessage = errMsg}),
                                charInClassHelper("equi", row.characteristicName, row.className))
        )

    def charInClassHelper(classtype: String, charname: String, classname: String): DbMonad[Bool] = 
        use BasicDb/DbMonad.{flatMap, return};
        let* pstmt  = prepareStatement("SELECT COUNT(classname) FROM classlist_class_members WHERE classtype = ? AND classname = ? AND charname = ?");
        let* rs     = psExecuteQuery(pstmt, setPrepStmt!(classtype, charname, classname));
        let* n      = firstRow(rs, BasicDb/RowEvaluator.getInt32At(0));
        let* _      = rsClose(rs);
        return(n > 0)

    def setPrepStmt!(classtype: String, charname: String, classname: String): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!, putInt32At!};
        let* _ = putStringAt!(0,  classtype);
        let* _ = putStringAt!(1,  classname);
        let* _ = putStringAt!(2,  charname);
        return()

    

}