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

namespace AutoLifting/Base/Datatypes {

    pub enum FixedOrPortable { 
        case Fixed
        case Portable
    }

    pub def showFixedOrPortable(x: FixedOrPortable): String =  match x { 
        case Fixed => "Fixed"
        case Portable => "Portable"
    }


    pub def readFixedOrPortable(s: String): Result[FixedOrPortable, System.Error] = 
        match String.trim(String.toUpperCase(s)) {
            case "FIXED" => Ok(Fixed)
            case "PORTABLE" => Ok(Portable)
            case _ => Err(System/Error.Generic("readFixedOrPortable"))
        }
        

    type alias S4TypeInfo = 
        { category: String 
        , s4Object: String
        , s4Class: String
        , fixedOrPortable: FixedOrPortable
        }



}