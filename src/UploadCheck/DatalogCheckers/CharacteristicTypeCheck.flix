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

use AssetLib/S4/FileIO/ClassList/Relations.{Characteristic};
use AssetLib/S4/FileIO/ClassList/Relations.Datatype; 
use AssetLib/S4/FileIO/ClassList/Relations.Datatype.{Text, IntNum, DecimalNum, Date};
use UploadCheck/EntityTypes/ValuaFloc.{ValuaFloc};
use UploadCheck/EntityTypes/ValuaEqui.{ValuaEqui};
use UploadCheck/Checkers/UniCharacteristic.{UniCharacteristic};
use UploadCheck/Checkers/UniCharacteristic.{equiToUniCharacteristic, flocToUniCharacteristic};

namespace UploadCheck/DatalogCheckers/CharacteristicTypeCheck {

    /// Change to a Bool check...

    rel TypeFail(ix: Int32, identifier: String, charId: String, value: String, valueType: Datatype)
   
    /// Note we can put together the steps of typechicking in a pipeline rather than
    /// define them as one monolithic set of Datalog rules
    
    pub def equiTypecheck[r](): #{TypeFail, UniCharacteristic, ValuaEqui, Characteristic | r} =
        typecheck() <+> equiToUniCharacteristic()

    pub def flocTypecheck[r](): #{TypeFail, UniCharacteristic, ValuaFloc, Characteristic | r} =
        typecheck() <+> flocToUniCharacteristic()

    
    def typecheck[r](): #{TypeFail, UniCharacteristic | r} = #{

        TypeFail(ix, identifier, charId, value, IntNum) :-
            UniCharacteristic(ix, identifier, charId, value, IntNum), if !checkIntValue(value).

        TypeFail(ix, identifier, charId, value, DecimalNum) :-
            UniCharacteristic(ix, identifier, charId, value, DecimalNum), if !checkDecimalValue(value).

        TypeFail(ix, identifier, charId, value, Date) :-
            UniCharacteristic(ix, identifier, charId, value, Date), if !checkDateValue(value).

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

}