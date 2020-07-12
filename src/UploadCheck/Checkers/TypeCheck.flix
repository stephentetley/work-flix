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
use UploadCheck/EntityTypes/ValuaFloc.{ValuaFloc};
use UploadCheck/EntityTypes/ValuaEqui.{ValuaEqui};

namespace UploadCheck/Checkers/TypeCheck {

    // Dummy while we see if this can be extracted from the host system...
    rel CharacteristicType(charId: String, datatype: Datatype, charLength: Int32, decimalPrec: Option[Int32])


    /// This will be read from file in due course
    /// EASTING and NORTHING are really ranges
    pub def tempTypeDb[r](): #{ CharacteristicType | r } = #{
        CharacteristicType("MANUFACTURERS_ASSET_LIFE_YR", IntNum, 5, None).
        CharacteristicType("AI2_AIB_REFERENCE", Text, 11, None).
        CharacteristicType("EASTING", IntNum, 5, None).
        CharacteristicType("NORTHING", IntNum, 5, None).
        CharacteristicType("VEPR_PV_VERIFICATION_DATE", Date, 10, None).
    }

    rel TypeFail(ix: Int32, identifier: String, charId: String, value: String, valueType: Datatype)
    rel Value(ix: Int32, identifier: String, charId: String, value: String, valueType: Datatype)

    /// Note we can put together the steps of typechicking in a pipeline rather than
    /// define them as one monolithic set of Datalog rules
    
    pub def equiTypecheck[r](): #{ TypeFail, Value, ValuaEqui, CharacteristicType | r } =
        typecheck() <+> deriveEquiValues()

    pub def flocTypecheck[r](): #{ TypeFail, Value, ValuaFloc, CharacteristicType | r } =
        typecheck() <+> deriveFlocValues()

    
    def typecheck[r](): #{ TypeFail, Value | r } = #{

        TypeFail(ix, identifier, charId, value, IntNum) :-
            Value(ix, identifier, charId, value, IntNum), if !checkIntValue(value).

        TypeFail(ix, identifier, charId, value, DecimalNum) :-
            Value(ix, identifier, charId, value, DecimalNum), if !checkDecimalValue(value).

        TypeFail(ix, identifier, charId, value, Date) :-
            Value(ix, identifier, charId, value, Date), if !checkDateValue(value).

    }

    /// Favour regex over Int32.fromString as the latter allows whitespace

    def regexInt(): Text/Regex.Pattern = irrefutablePattern("-?d+")

    def checkIntValue(x: String): Bool = 
        use Text/Regex.{matches};
        x.matches(regexInt())

    def regexDate(): Text/Regex.Pattern = irrefutablePattern("\d{2}\.\d{2}\.\d{4}")

    def checkDateValue(x: String): Bool = 
        use Text/Regex.{matches};
        x.matches(regexDate())

    def regexDecimal(): Text/Regex.Pattern = irrefutablePattern("-?\d+\.\d{+}")

    def checkDecimalValue(x: String): Bool = 
        use Text/Regex.{matches};
        x.matches(regexDecimal())

 

    def deriveEquiValues[r](): #{ Value, ValuaEqui, CharacteristicType | r } =  #{

        Value(ix, equiId, charId, charValue, Text) :-
            ValuaEqui(ix, equiId, _, charId, charValue, _, _, _, _, _),
            CharacteristicType(charId, Text, _, _). 

        Value(ix, equiId, charId, charValue, Date) :-
            ValuaEqui(ix, equiId, _, charId, charValue, _, _, _, _, _),
            CharacteristicType(charId, Date, _, _). 

        Value(ix, equiId, charId, valueFrom, IntNum) :-
            ValuaEqui(ix, equiId, _, charId, _, _, _, _, valueFrom, _), 
            CharacteristicType(charId, IntNum, _, _).

        Value(ix, equiId, charId, valueFrom, DecimalNum) :-
            ValuaEqui(ix, equiId, _, charId, _, _, _, _, valueFrom, _), 
            CharacteristicType(charId, DecimalNum, _, _).

    }

    def deriveFlocValues[r](): #{ Value, ValuaFloc, CharacteristicType | r } =  #{

        Value(ix, floc, charId, charValue, Text) :-
            ValuaFloc(ix, floc, _, charId, charValue, _, _, _, _, _),
            CharacteristicType(charId, Text, _, _). 

        Value(ix, floc, charId, charValue, Date) :-
            ValuaFloc(ix, floc, _, charId, charValue, _, _, _, _, _),
            CharacteristicType(charId, Date, _, _). 

        Value(ix, floc, charId, valueFrom, IntNum) :-
            ValuaFloc(ix, floc, _, charId, _, _, _, _, valueFrom, _), 
            CharacteristicType(charId, IntNum, _, _).

        Value(ix, floc, charId, valueFrom, DecimalNum) :-
            ValuaFloc(ix, floc, _, charId, _, _, _, _, valueFrom, _), 
            CharacteristicType(charId, DecimalNum, _, _).

    }




}