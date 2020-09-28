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

namespace AutoLifting/Datatypes {

    pub enum FixedOrPortable { 
        case Fixed
        case Portable
    }

  
    type alias ChildNew = 
        { aibName: String
        , s4Name: String
        , pliReference: String
        , parentSaiReference: String
        }


    type alias S4TypeInfo = 
        { category: String 
        , s4Object: String
        , s4Class: String
        , fixedOrPortable: FixedOrPortable
        }

    pub def showS4TypeInfo(x: S4TypeInfo): String = 
        let fop = match x.fixedOrPortable { 
                    case Fixed => "Fixed"
                    case Portable => "Portable"
        };
        "<${x.category}, ${x.s4Object}, ${x.s4Class}, ${fop}>"


}