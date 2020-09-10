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


namespace UploadCheck/SqlCheckers/EquiIntRangeCheck {


    pub def equiIntRangeCheck(charname: String, value: String): DbMonad[Bool] = 
        use BasicDb/DbMonad.{return};
        match Int32.fromString(value) {
            case Ok(x) => intRangeCheck(charname, x)
            case Err(_) => return(true)
        }

    def intRangeCheck(charname: String, value: Int32): DbMonad[Bool] = 
        use BasicDb/DbMonad.{flatMap, return};
        let* pstmt  = prepareStatement("SELECT range_low, range_high FROM equi_int_ranges WHERE charname = ?");
        let* rs     = psExecuteQuery(pstmt, setPStmt!(charname));
        let* orng   = optional(firstRow(rs, evalRow()));
        let* _      = rsClose(rs);
        return(inRange(orng, value))

    def inRange(orng: Option[(Int32, Int32)], x: Int32): Bool = match orng {
        case Some((lo, hi)) => lo <= x && x <= hi
        case None => true           // No constraints, so true
    }


    def setPStmt!(charname: String): PreparedStatementSetter[Unit] = 
        BasicDb/PreparedStatementSetter.putString!(0,  charname)


    def evalRow(): RowEvaluator[(Int32, Int32)] = 
        use BasicDb/RowEvaluator.{tuple2, getInt32};
        tuple2(getInt32(0), getInt32(1))


    // rel Restricted(charname: String)

    // def isRestricted[r](db: #{IntRange, Restricted | r}, charname: String): Bool = 
    //     let rules = #{
    //         Restricted(name) :- IntRange(name, _, _).
    //     };
    //     (solve db <+> rules) |= Restricted(charname).

    
    // def isRestrictedValue[r](db: #{IntRange, Restricted | r}, charname: String, value: Int32): Bool = 
    //     let rules = #{
    //         Restricted(name) :- IntRange(name, low, high), if low <= value && value <= high.
    //     };
    //     (solve db <+> rules) |= Restricted(charname).

}