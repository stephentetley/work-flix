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


use AssetLib/FileIO/S4/ClassList/Relations.{Characteristic};
use AssetLib/FileIO/S4/ClassList/Relations.Datatype; 
use AssetLib/FileIO/S4/ClassList/Relations.Datatype.{Text, IntNum, DecimalNum, Date};
use UploadCheck/EntityTypes/ValuaFloc.{ValuaFloc};
use UploadCheck/EntityTypes/ValuaEqui.{ValuaEqui};

namespace UploadCheck/DatalogCheckers/UniCharacteristic {


    /// Characteristic extended with index and equiId 
    rel UniCharacteristic(ix: Int32, identifier: String, charId: String, value: String, valueType: Datatype)


 
    /// The actual "value" might either be CharacteristicValue (Text and Date) or ValueFrom (Int and Decimal)
    pub def equiToUniCharacteristic[r](): #{ UniCharacteristic, ValuaEqui, Characteristic | r } =  #{

        UniCharacteristic(ix, equiId, charId, charValue, Text) :-
            ValuaEqui(ix, equiId, _, charId, charValue, _, _, _, _, _),
            Characteristic(charId, Text, _, _). 

        UniCharacteristic(ix, equiId, charId, charValue, Date) :-
            ValuaEqui(ix, equiId, _, charId, charValue, _, _, _, _, _),
            Characteristic(charId, Date, _, _). 

        UniCharacteristic(ix, equiId, charId, valueFrom, IntNum) :-
            ValuaEqui(ix, equiId, _, charId, _, _, _, _, valueFrom, _), 
            Characteristic(charId, IntNum, _, _).

        UniCharacteristic(ix, equiId, charId, valueFrom, DecimalNum) :-
            ValuaEqui(ix, equiId, _, charId, _, _, _, _, valueFrom, _), 
            Characteristic(charId, DecimalNum, _, _).

    }


    /// The actual "value" might either be CharacteristicValue (Text and Date) or ValueFrom (Int and Decimal)
    pub def flocToUniCharacteristic[r](): #{ UniCharacteristic, ValuaFloc, Characteristic | r } =  #{

        UniCharacteristic(ix, floc, charId, charValue, Text) :-
            ValuaFloc(ix, floc, _, charId, charValue, _, _, _, _, _),
            Characteristic(charId, Text, _, _). 

        UniCharacteristic(ix, floc, charId, charValue, Date) :-
            ValuaFloc(ix, floc, _, charId, charValue, _, _, _, _, _),
            Characteristic(charId, Date, _, _). 

        UniCharacteristic(ix, floc, charId, valueFrom, IntNum) :-
            ValuaFloc(ix, floc, _, charId, _, _, _, _, valueFrom, _), 
            Characteristic(charId, IntNum, _, _).

        UniCharacteristic(ix, floc, charId, valueFrom, DecimalNum) :-
            ValuaFloc(ix, floc, _, charId, _, _, _, _, valueFrom, _), 
            Characteristic(charId, DecimalNum, _, _).

    }




}