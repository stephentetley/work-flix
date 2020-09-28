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
use BasicDb/DbMonad.{prepareStatement, psExecuteQuery, optional, firstRow, rsClose};
use BasicDb.PreparedStatementSetter;
use BasicDb.RowEvaluator;

use AssetLib/S4/FileIO/UxlFile/Datatypes.{EqClassification, FlClassification};
use UploadCheck/Base/RowCheck.{RowCheck, RowChecker};
use UploadCheck/Base/RowCheck.RowChecker.{RowChecker};
use UploadCheck/Base/Common.Datatype;
use UploadCheck/Base/Common.Datatype.{Text, Date, Integer, Decimal};
use UploadCheck/Base/Common.{datatypeName};
use UploadCheck/SqlCheckers/SqlCommon.{getFlocDatatype, getEquiDatatype};

namespace UploadCheck/SqlCheckers/TypeCheck {

    pub def flocTypeCheck(): RowChecker[FlClassification] = 
        use BasicDb/DbMonad.{return, flatMap, map};
        RowChecker((row, ix) -> {
            let* tyname = map(getTypeName, getEquiDatatype(row.characteristicName));
            let errMsg  = "flocTypeCheck failed - `${row.charValue}` not is not a ${tyname} for ${row.characteristicName}";
            let* ans    = flocTypeCheckHelper(row.characteristicName, row.charValue);
            if (ans) return(Pass) else return(failure({ rowIndex = ix, failMessage = errMsg }))                                
        })


    pub def equiTypeCheck(): RowChecker[EqClassification] = 
        use BasicDb/DbMonad.{return, flatMap, map};
        RowChecker((row, ix) -> {
            let* tyname = map(getTypeName, getEquiDatatype(row.characteristicName));
            let errMsg  = "equiTypeCheck failed - `${row.charValue}` not is not a ${tyname} for ${row.characteristicName}";
            let* ans    = equiTypeCheckHelper(row.characteristicName, row.charValue);
            if (ans) return(Pass) else return(failure({ rowIndex = ix, failMessage = errMsg }))                                
        })

    def getTypeName(x: Option[Datatype]): String = 
        Option.getWithDefault(Option.map(datatypeName, x), "<ERR>")

    def flocTypeCheckHelper(charname: String, value: String): DbMonad[Bool] = 
        use BasicDb/DbMonad.{return, liftAction, ifSomeM};
        ifSomeM(
            getFlocDatatype(charname), 
            x -> return(typeCheck(x, value)),
            return(false)
        )

    def equiTypeCheckHelper(charname: String, value: String): DbMonad[Bool] = 
        use BasicDb/DbMonad.{return, liftAction, ifSomeM};
        ifSomeM(
            getEquiDatatype(charname), 
            x -> return(typeCheck(x, value)),
            return(false)
        )

    def typeCheck(ty: Datatype, value: String): Bool = match ty { 
        case Text => true 
        case Integer => checkInteger(value)
        case Decimal => checkDecimal(value)
        case Date => checkDate(value)
    }

   def checkInteger(value: String): Bool = 
        let patt = Text/Regex/Pattern.irrefutablePattern("[0-9]+");
        Text/Regex.matches(value, patt)
 
    def checkDecimal(value: String): Bool = 
        let patt = Text/Regex/Pattern.irrefutablePattern("[0-9]+(\.[0-9]*)?");
        Text/Regex.matches(value, patt)
 
    def checkDate(value: String): Bool = 
        let patt = Text/Regex/Pattern.irrefutablePattern("[0-3][0-9]\.[0-1][0-9]\.[1-2][0-9]{,3}");
        Text/Regex.matches(value, patt)
    
    

}