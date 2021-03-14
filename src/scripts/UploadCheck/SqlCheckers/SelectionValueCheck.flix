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


namespace UploadCheck/SqlCheckers/SelectionValueCheck {

    use DataCheck.Check.{Pass};
    use DataCheck/Check.{failure};

    use BasicDb.DbMonad;
    use BasicDb/DbMonad.{prepareStatement, psExecuteQuery, firstRow, rsClose};
    use BasicDb.PreparedStatementSetter;

    use AssetLib/S4/FileIO/UxlFile/Datatypes.{EqClassification, FlClassification};
    use UploadCheck/Base/RowCheck.{RowCheck, RowChecker};
    use UploadCheck/Base/RowCheck.RowChecker.{RowChecker};

    pub def flocSelectionValue(): RowChecker[FlClassification] = 
        RowChecker((row, ix) -> 
            let errMsg = "${row.functionalLocation} - flocSelectionValue failed - `${row.charValue}` not in list of values for ${row.characteristicName}";
            BasicDb/DbMonad.map(x -> if (x) Pass else failure({sheetName = "Fl-Classification", rowIndex = ix, failMessage = errMsg}), 
                                flocSelectionValueHelper(row.characteristicName, row.charValue))
        )

    def flocSelectionValueHelper(charname: String, value: String): DbMonad[Bool] = 
        use BasicDb/DbMonad.{return, flatMap};
        let* a1 = isRestricted("floc", charname);
        if (a1) isRestrictedValue("floc", charname, value) else return(true) 

    pub def equiSelectionValue(): RowChecker[EqClassification] = 
        RowChecker((row, ix) -> 
            /// Binding and typing `s1` stops a runtime error, no idea why...
            let s1 = row.equiId: String; 
            let errMsg = "${s1} - equiSelectionValue failed - `${row.charValue}` not in list of values for ${row.characteristicName}";
            BasicDb/DbMonad.map(x -> if (x) Pass else failure({sheetName = "Eq-Classification", rowIndex = ix, failMessage = errMsg }), 
                                equiSelectionValueHelper(row.characteristicName, row.charValue))
        )

    def equiSelectionValueHelper(charname: String, value: String): DbMonad[Bool] = 
        use BasicDb/DbMonad.{return, flatMap};
        let* a1 = isRestricted("equi", charname);
        if (a1) isRestrictedValue("equi", charname, value) else return(true) 

    def isRestricted(classtype: String, charname: String): DbMonad[Bool] = 
        use BasicDb/DbMonad.{flatMap, return};
        let* pstmt  = prepareStatement("SELECT COUNT(value) FROM cf_selection_values WHERE classtype = ? AND charname = ?;");
        let* rs     = psExecuteQuery(pstmt, isRestrictedSetter(classtype,  charname));
        let* n      = firstRow(rs, BasicDb/RowEvaluator.getInt32At(0));
        let* _      = rsClose(rs);
        return(n > 0)

    def isRestrictedSetter(classtype: String, charname: String):PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{return, flatMap, putStringAt!};
        let* _ = putStringAt!(0,  classtype);
        let* _ = putStringAt!(1,  charname);
        return()


    def isRestrictedValue(classtype: String, charname: String, value: String): DbMonad[Bool] = 
        use BasicDb/DbMonad.{flatMap, return};
        let* pstmt  = prepareStatement("SELECT COUNT(value) FROM cf_selection_values WHERE classtype = ? AND charname = ? AND value = ?;");
        let* rs     = psExecuteQuery(pstmt, restrictedValueSetter(classtype, charname, value));
        let* n      = firstRow(rs, BasicDb/RowEvaluator.getInt32At(0));
        let* _      = rsClose(rs);
        return(n > 0)

    def restrictedValueSetter(classtype: String, charname: String, value: String):PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{return, flatMap, putStringAt!};
        let* _ = putStringAt!(0,  classtype);
        let* _ = putStringAt!(1,  charname);
        let* _ = putStringAt!(2,  value);
        return()

}