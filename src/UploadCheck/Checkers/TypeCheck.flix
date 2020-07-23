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

use Text/Regex/Pattern.{irrefutablePattern};

use AssetLib/S4/FileIO/ClassList/Relations.{FlocCharacteristic, EquiCharacteristic};
use AssetLib/S4/FileIO/ClassList/Relations.Datatype; 
use AssetLib/S4/FileIO/ClassList/Relations.Datatype.{Text, IntNum, DecimalNum, Date};
use UploadCheck/EntityTypes/ValuaFloc.{ValuaFloc};
use UploadCheck/EntityTypes/ValuaEqui.{ValuaEqui};

namespace UploadCheck/Checkers/TypeCheck {



    rel TypeFail(ix: Int32, identifier: String, charId: String, value: String, valueType: Datatype)
    rel Value(ix: Int32, identifier: String, charId: String, value: String, valueType: Datatype)

    /// Note we can put together the steps of typechicking in a pipeline rather than
    /// define them as one monolithic set of Datalog rules
    
    pub def equiTypecheck[r](): #{ TypeFail, Value, ValuaEqui, EquiCharacteristic | r } =
        typecheck() <+> deriveEquiValues()

    pub def flocTypecheck[r](): #{ TypeFail, Value, ValuaFloc, FlocCharacteristic | r } =
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

 

    def deriveEquiValues[r](): #{ Value, ValuaEqui, EquiCharacteristic | r } =  #{

        Value(ix, equiId, charId, charValue, Text) :-
            ValuaEqui(ix, equiId, _, charId, charValue, _, _, _, _, _),
            EquiCharacteristic(charId, Text, _, _). 

        Value(ix, equiId, charId, charValue, Date) :-
            ValuaEqui(ix, equiId, _, charId, charValue, _, _, _, _, _),
            EquiCharacteristic(charId, Date, _, _). 

        Value(ix, equiId, charId, valueFrom, IntNum) :-
            ValuaEqui(ix, equiId, _, charId, _, _, _, _, valueFrom, _), 
            EquiCharacteristic(charId, IntNum, _, _).

        Value(ix, equiId, charId, valueFrom, DecimalNum) :-
            ValuaEqui(ix, equiId, _, charId, _, _, _, _, valueFrom, _), 
            EquiCharacteristic(charId, DecimalNum, _, _).

    }

    def deriveFlocValues[r](): #{ Value, ValuaFloc, FlocCharacteristic | r } =  #{

        Value(ix, floc, charId, charValue, Text) :-
            ValuaFloc(ix, floc, _, charId, charValue, _, _, _, _, _),
            FlocCharacteristic(charId, Text, _, _). 

        Value(ix, floc, charId, charValue, Date) :-
            ValuaFloc(ix, floc, _, charId, charValue, _, _, _, _, _),
            FlocCharacteristic(charId, Date, _, _). 

        Value(ix, floc, charId, valueFrom, IntNum) :-
            ValuaFloc(ix, floc, _, charId, _, _, _, _, valueFrom, _), 
            FlocCharacteristic(charId, IntNum, _, _).

        Value(ix, floc, charId, valueFrom, DecimalNum) :-
            ValuaFloc(ix, floc, _, charId, _, _, _, _, valueFrom, _), 
            FlocCharacteristic(charId, DecimalNum, _, _).

    }




}