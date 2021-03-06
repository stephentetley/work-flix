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




namespace UploadCheck/SqlCheckers/IntRangeCheck {

    use DataCheck.Check.{Pass};
    use DataCheck/Check.{failure};

    use BasicDb.DbMonad;
    use BasicDb/DbMonad.{prepareStatement, psExecuteQuery, optional, firstRow, rsClose};
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

    use AssetLib/S4/FileIO/UxlFile/Datatypes.{EqClassification, FlClassification};
    use UploadCheck/Base/RowCheck.{RowCheck, RowChecker};
    use UploadCheck/Base/RowCheck.RowChecker.{RowChecker};

    /// TODO should use a type check

    pub def flocIntRange(): RowChecker[FlClassification] = 
        RowChecker((row, ix) -> 
            let errMsg =  "flocIntRange failed - `${row.charValue}` not in value range for ${row.characteristicName}";
            BasicDb/DbMonad.map(x -> if (x) Pass else failure({sheetName = "Fl-Classification", rowIndex = ix, failMessage = errMsg}), 
                                flocIntRangeHelper(row.characteristicName, row.charValue))
        )

    def flocIntRangeHelper(charname: String, value: String): DbMonad[Bool] = 
        use BasicDb/DbMonad.{return};
        match Int32.fromString(value) {
            case Ok(x) => intRangeCheck("floc", charname, x)
            case Err(_) => return(true)
        }


    pub def equiIntRange(): RowChecker[EqClassification] = 
        RowChecker((row, ix) -> 
            let errMsg =  "equiIntRange failed - `${row.charValue}` not in value range for ${row.characteristicName}";
            BasicDb/DbMonad.map(x -> if (x) Pass else failure({sheetName = "Eq-Classification", rowIndex = ix, failMessage = errMsg}), 
                                equiIntRangeHelper(row.characteristicName, row.charValue))
        )


    def equiIntRangeHelper(charname: String, value: String): DbMonad[Bool] = 
        use BasicDb/DbMonad.{return};
        match Int32.fromString(value) {
            case Ok(x) => intRangeCheck("equi", charname, x)
            case Err(_) => return(true)
        }

    def intRangeCheck(classtype: String, charname: String, value: Int32): DbMonad[Bool] = 
        use BasicDb/DbMonad.{flatMap, return};
        let* pstmt  = prepareStatement("SELECT range_low, range_high FROM cf_int_ranges WHERE classtype = ? AND charname = ?");
        let* rs     = psExecuteQuery(pstmt, setPStmt!(classtype, charname));
        let* orng   = optional(firstRow(rs, evalRow()));
        let* _      = rsClose(rs);
        return(inRange(orng, value))

    def inRange(orng: Option[(Int32, Int32)], x: Int32): Bool = match orng {
        case Some((lo, hi)) => lo <= x and x <= hi
        case None => true           // No constraints, so true
    }


    def setPStmt!(classtype: String, charname: String): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{return, flatMap, putStringAt!};
        let* _ = putStringAt!(0,  classtype);
        let* _ = putStringAt!(0,  charname);
        return()


    def evalRow(): RowEvaluator[(Int32, Int32)] = 
        use BasicDb/RowEvaluator.{tuple2, getInt32At};
        tuple2(getInt32At(0), getInt32At(1))



}