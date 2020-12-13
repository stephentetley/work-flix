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

use BasicDb.DbMonad;
use BasicDb/DbMonad.{prepareStatement, psExecuteQuery, optional, firstRow, rsClose};
use BasicDb.PreparedStatementSetter;
use BasicDb.RowEvaluator;

use UploadCheck/Base/Common.Datatype;
use UploadCheck/Base/Common.{decodeDatatype};

namespace UploadCheck/SqlCheckers/SqlCommon {


    pub def getFlocDatatype(charname: String): DbMonad[Option[Datatype]] = getDatatype("floc", charname)

    pub def getEquiDatatype(charname: String): DbMonad[Option[Datatype]] = getDatatype("equi", charname)

    def getDatatype(classtype: String, charname: String): DbMonad[Option[Datatype]] = 
        use BasicDb/DbMonad.{flatMap, return};
        let* pstmt  = prepareStatement("SELECT DISTINCT datatype FROM cf_char_defs WHERE classtype = ? AND charname = ?");        
        let* rs     = psExecuteQuery(pstmt, datatypeSetter(classtype,  charname));
        let* ans    = optional(firstRow(rs, BasicDb/RowEvaluator.getStringAt(0)));
        let* _      = rsClose(rs);
        return(Option.flatMap(decodeDatatype, ans))

    def datatypeSetter(classtype: String, charname: String):PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{return, flatMap, putStringAt!};
        let* _ = putStringAt!(0,  classtype);
        let* _ = putStringAt!(1,  charname);
        return()

    

} 