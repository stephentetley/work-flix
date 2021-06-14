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


use AssetLib/FileIO/S4/ClassList/Relations.{SelectionValue};


namespace UploadCheck/DatalogCheckers/SelectionValueCheck {

    pub def selectionValueCheck(db: #{SelectionValue, Restricted, RestrictedValue}, charname: String, value: String): Bool = 
        isRestricted(db, charname) and isRestrictedValue(db, charname, value)

    rel Restricted(charname: String)

    def isRestricted(db: #{SelectionValue, Restricted, RestrictedValue}, charname: String): Bool & Impure = 
        let rules = #{
            Restricted(name) :- SelectionValue(name, _).
        };
        let m = query (db <+> rules) select (x) from Restricted(x);
        Array.memberOf(charname, m)

    rel RestrictedValue(charname: String, value: String)

    def isRestrictedValue(db: #{SelectionValue, Restricted, RestrictedValue}, charname: String, value: String): Bool & Impure = 
        let rules = #{
            RestrictedValue(name, valu) :- SelectionValue(name, valu).
        };
        let m = query (db <+> rules) select (x, y) from RestrictedValue(x, y);
        Array.memberOf((charname, value), m)

}