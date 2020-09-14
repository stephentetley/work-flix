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

use UploadCheck/Base/RowCheck.{RowCheck};

namespace UploadCheck/SqlCheckers/CharInClassCheck {

    pub def flocCharInClass(charname: String, classname: String, rowIx: Int32): DbMonad[RowCheck] =
        let errMsg = "flocCharInClass failed - ${charname} not in class ${classname}";
        BasicDb/DbMonad.map(x -> if (x) Pass else failure({ rowIndex = rowIx, failMessage = errMsg }), 
                            flocCharInClassCheck(charname, classname))

    pub def flocCharInClassCheck(charname: String, classname: String): DbMonad[Bool] = 
        charInClassCheck("floc", charname, classname)


    pub def equiCharInClass(charname: String, classname: String, rowIx: Int32): DbMonad[RowCheck] =
        let errMsg = "equiCharInClass failed - ${charname} not in class ${classname}";
        BasicDb/DbMonad.map(x -> if (x) Pass else failure({ rowIndex = rowIx, failMessage = errMsg }), 
                            equiCharInClassCheck(charname, classname))


    pub def equiCharInClassCheck(charname: String, classname: String): DbMonad[Bool] = 
        charInClassCheck("equi", charname, classname)

    def charInClassCheck(prefix: String, charname: String, classname: String): DbMonad[Bool] = 
        use BasicDb/DbMonad.{flatMap, return};
        let* pstmt  = prepareStatement("SELECT COUNT(classname) FROM ${prefix}_class_members WHERE classname = ? AND charname = ?");
        let* rs     = psExecuteQuery(pstmt, setPrepStmt!(charname, classname));
        let* n      = firstRow(rs, BasicDb/RowEvaluator.getInt32(0));
        let* _      = rsClose(rs);
        return(n > 0)

    def setPrepStmt!(charname: String, classname: String): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putString!, putInt32!};
        let* _ = putString!(0,  classname);
        let* _ = putString!(1,  charname);
        return()

    

}