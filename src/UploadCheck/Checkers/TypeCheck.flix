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

use Text/Regex/Pattern.{irrefutableCompile => irrefutablePattern};


use AssetLib/S4/FileIO/ClassList/Relations.Datatype; 
use AssetLib/S4/FileIO/ClassList/Relations.Datatype.{Text, IntNum, DecimalNum, Date};
use UploadCheck/EntityTypes/ValuaEqui.{ValuaEqui};

namespace UploadCheck/Checkers/TypeCheck {

    // Dummy while we see if this can be extracted from the host system...
    rel EquiType(charId: String, datatype: Datatype, charLength: Int32, decimalPrec: Option[Int32])

    // def regexNum(): Text/Regex.Pattern = irrefutablePattern("\d+")



    /// This will be read from file in due course
    /// EASTING and NORTHING are really ranges
    pub def tempTypeDb[r](): #{ EquiType | r } = #{
        EquiType("MANUFACTURERS_ASSET_LIFE_YR", IntNum, 5, None).
        EquiType("AI2_AIB_REFERENCE", Text, 11, None).
        EquiType("EASTING", IntNum, 5, None).
        EquiType("NORTHING", IntNum, 5, None).
    }

    rel TypeFail(ix: Int32, charId: String, value: String, valueType: Datatype)
    rel Value(ix: Int32, charId: String, value: String, valueType: Datatype)


    pub def typecheck[r](): #{ TypeFail, Value | r } = #{

        TypeFail(ix, charId, value, IntNum) :-
            Value(ix, charId, value, IntNum), if !checkIntValue(value).

    }

 

    pub def deriveValues[r](): #{ Value, ValuaEqui, EquiType | r } =  #{

        Value(ix, charId, charValue, Text) :-
            ValuaEqui(ix, _, _, charId, charValue, _, _, _, _, _),
            EquiType(charId, Text, _, _). 

        Value(ix, charId, charValue, Date) :-
            ValuaEqui(ix, _, _, charId, charValue, _, _, _, _, _),
            EquiType(charId, Date, _, _). 

        Value(ix, charId, valueFrom, IntNum) :-
            ValuaEqui(ix, _, _, charId, _, _, _, _, valueFrom, _), 
            EquiType(charId, IntNum, _, _).

        Value(ix, charId, valueFrom, DecimalNum) :-
            ValuaEqui(ix, _, _, charId, _, _, _, _, valueFrom, _), 
            EquiType(charId, DecimalNum, _, _).

    }

    def checkIntValue(x: String): Bool = match Int32.fromString(x) {
        case Ok(_) => true
        case Err(_) => false
    }

}